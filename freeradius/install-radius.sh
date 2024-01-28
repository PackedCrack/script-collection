#!/bin/bash

# root will be required for this..
if [[ $(whoami) != 'root' ]]; then
  echo "The script must be run as root.."
  echo "Open a root terminal with \"sudo su\""
  exit
fi

# make sure we are up to date
apt update --yes
apt upgrade --yes


# install radius
echo "Installing freeradius..."
apt install freeradius --yes



# Not creating password users for TLS
### Create a user account
##while true; do
##  echo
##  echo "Creating a user..."
##  read -p "Enter a username: " username
##  read -p "Enter a password: " password
##  userEntry="${username}	Cleartext-Password := \"${password}\""
##  echo "$userEntry" >> /etc/freeradius/3.0/users
##
##  echo
##  read -p "Add another user? Y/n: " addMore
##  if [[ "$addMore" == "n" ]]; then
##    break
##  fi
##  if [[ "$addMore" == "no" ]]; then
##    break
##  fi
##done



# Add clients
while true; do
  # Take information about access point
  while true; do
    read -p "Enter the IP (CIDR notation 69.69.69.69/24) of the access point: " accessPointIP
    # Get the second and third last characters
    secondLastChar="${accessPointIP: -2:1}"
    thirdLastChar="${accessPointIP: -3:1}"

    # Check if either the second or third last character is '/'
    if [[ "$secondLastChar" == "/" || "$thirdLastChar" == "/" ]]; then
      break
    else
      echo "Invalid input. Enter the IP in CIDR notation with a '/'."
    fi
  done

  while true; do
      read -p "Enter the shared secret key (minimum 8 characters): " sharedSecret
      if [ "${#sharedSecret}" -ge 8 ]; then
          break
      else
          echo "I said atleast 8 characters...."
      fi
  done

  clientEntry="client custom_access_point {
          ipaddr = ${accessPointIP}
          secret = ${sharedSecret}
          limit {
                  max_connections = 16
                  lifetime = 0
                  idle_timeout = 30
          }
  }"
  # append the new client to freeradius' config..
  echo "$clientEntry" >> /etc/freeradius/3.0/clients.conf

  echo
  read -p "Add another client? Y/n: " moreClients
  if [[ "$moreClients" == "n" ]]; then
    break
  fi
  if [[ "$moreClients" == "no" ]]; then
    break
  fi
done



# Setup the ROOT CA
read -p "CA country name: " caCountryName
read -p "CA state or provice: " caState
read -p "CA locality name: " caLocalityName
read -p "CA organization name: " caOrganizationName
read -p "CA email: " caEmail
read -p "CA common name: " caCommonName
read -p "Default days: " defaultDays
read -p "Default CRL days: " defaultCRLDays

#read -p "Enter the IP address of the FTP server that holds the CRL: " crlFTPAddress
#read -p "Enter the filepath (started with \"/\") to where the CRL file is located: " crlFTPFilePath

while true; do
    read -p "CA input password: " caPasswordIn
    read -p "repeat password: " caPasswordRepeatedIn

  if [[ "$caPasswordIn" == "$caPasswordRepeatedIn" ]]; then
    break
  fi
  echo "The entered passwords did not match.. try again."
done

while true; do
    read -p "CA output password: " caPasswordOut
    read -p "repeat password: " caPasswordRepeatedOut

  if [[ "$caPasswordOut" == "$caPasswordRepeatedOut" ]]; then
    break
  fi
  echo "The entered passwords did not match.. try again."
done


sed -i "0,/input_password[[:space:]]*= whatever/s//input_password          = "${caPasswordIn}"/" /etc/freeradius/3.0/certs/ca.cnf
sed -i "0,/output_password[[:space:]]*= whatever/s//output_password          = "${caPasswordOut}"/" /etc/freeradius/3.0/certs/ca.cnf


sed -i "0,/default_days[[:space:]]*= 60/s//default_days   = ${defaultDays}/" /etc/freeradius/3.0/certs/ca.cnf
sed -i "0,/default_crl_days[[:space:]]*= 30/s//default_crl_days   = ${defaultCRLDays}/" /etc/freeradius/3.0/certs/ca.cnf

sed -i "0,/countryName[[:space:]]*= FR/s//countryName   = ${caCountryName}/" /etc/freeradius/3.0/certs/ca.cnf
sed -i "0,/stateOrProvinceName[[:space:]]*= Radius/s//stateOrProvinceName     = "${caState}"/" /etc/freeradius/3.0/certs/ca.cnf
sed -i "0,/localityName[[:space:]]*= Somewhere/s//localityName            = "${caLocalityName}"/" /etc/freeradius/3.0/certs/ca.cnf
sed -i "0,/organizationName[[:space:]]*= Example Inc./s//organizationName        = ${caOrganizationName}/" /etc/freeradius/3.0/certs/ca.cnf
sed -i "0,/emailAddress[[:space:]]*= admin@example.org/s//emailAddress            = "${caEmail}"/" /etc/freeradius/3.0/certs/ca.cnf
sed -i "0,/commonName[[:space:]]*= \"Example Certificate Authority\"/s//commonName              = \"${caCommonName}\"/" /etc/freeradius/3.0/certs/ca.cnf

# Mutate the ftpInfo and insert \ infront of each / so regex doesnt shit itself..
#tmpFTPInfo="${crlFTPAddress}${crlFTPFilePath}"
#for (( i=0; i<${#tmpFTPInfo}; i++ )); do
#    char="${tmpFTPInfo:i:1}"
#
#    if [[ $char == "/" ]]; then
#        crlFTPInfo+="\\/"
#    else
#        crlFTPInfo+="$char"
#    fi
#done
# has to be done multiple times because... 2 lines exists..
#sed -i '0,/crlDistributionPoints[[:space:]]*=[[:space:]]*URI:http:\/\/www.example.org\/example_ca.crl/s//crlDistributionPoints = URI:ftp:\/\/'"${crlFTPInfo}"'/' /etc/freeradius/3.0/certs/ca.cnf
#sed -i '0,/crlDistributionPoints[[:space:]]*=[[:space:]]*URI:http:\/\/www.example.org\/example_ca.crl/s//crlDistributionPoints = URI:ftp:\/\/'"${crlFTPInfo}"'/' /etc/freeradius/3.0/certs/ca.cnf



# Setup the server certificate config
read -p "Radius server hostname: " serverHostname
read -p "Radius server email: " serverEmail
read -p "Radius server common name: " serverCommonName

while true; do
    read -p "Server input password: " serverPasswordIn
    read -p "repeat password: " serverPasswordRepeatedIn

  if [[ "$serverPasswordIn" == "$serverPasswordRepeatedIn" ]]; then
    break
  fi
  echo "The entered passwords did not match.. try again."
done

while true; do
    read -p "Server output password: " serverPasswordOut
    read -p "repeat password: " serverPasswordRepeatedOut

  if [[ "$serverPasswordOut" == "$serverPasswordRepeatedOut" ]]; then
    break
  fi
  echo "The entered passwords did not match.. try again."
done


# The server and client certificates requires information about the CA...
sed -i "0,/countryName[[:space:]]*= FR/s//countryName   = ${caCountryName}/" /etc/freeradius/3.0/certs/server.cnf
sed -i "0,/stateOrProvinceName[[:space:]]*= Radius/s//stateOrProvinceName     = "${caState}"/" /etc/freeradius/3.0/certs/server.cnf
sed -i "0,/localityName[[:space:]]*= Somewhere/s//localityName            = "${caLocalityName}"/" /etc/freeradius/3.0/certs/server.cnf
sed -i "0,/organizationName[[:space:]]*= Example Inc./s//organizationName        = ${caOrganizationName}/" /etc/freeradius/3.0/certs/server.cnf
# client
sed -i "0,/countryName[[:space:]]*= FR/s//countryName   = ${caCountryName}/" /etc/freeradius/3.0/certs/client.cnf
sed -i "0,/stateOrProvinceName[[:space:]]*= Radius/s//stateOrProvinceName     = "${caState}"/" /etc/freeradius/3.0/certs/client.cnf
sed -i "0,/localityName[[:space:]]*= Somewhere/s//localityName            = "${caLocalityName}"/" /etc/freeradius/3.0/certs/client.cnf
sed -i "0,/organizationName[[:space:]]*= Example Inc./s//organizationName        = ${caOrganizationName}/" /etc/freeradius/3.0/certs/client.cnf


# Set server specific information
sed -i "0,/input_password[[:space:]]*= whatever/s//input_password          = "${serverPasswordIn}"/" /etc/freeradius/3.0/certs/server.cnf
sed -i "0,/output_password[[:space:]]*= whatever/s//output_password          = "${serverPasswordOut}"/" /etc/freeradius/3.0/certs/server.cnf
sed -i "0,/emailAddress[[:space:]]*= admin@example.org/s//emailAddress            = "${serverEmail}"/" /etc/freeradius/3.0/certs/server.cnf
sed -i "0,/commonName[[:space:]]*= \"Example Server Certificate\"/s//commonName              = \"${serverCommonName}\"/" /etc/freeradius/3.0/certs/server.cnf
sed -i "0,/DNS.1 = radius.example.com/s//DNS.1 = ${serverHostname}/" /etc/freeradius/3.0/certs/server.cnf



## Set up the eap-cfg
export INPUT_PASSWORD="${serverPasswordOut}"
./create-eap-cfg.sh
## Set up the sites-enabled default cfg
read -p "Enter the IP of the authorization/accounting server: " authAcctIP
export LISTEN_AUTH_ADDR="${authAcctIP}"
export LISTEN_ACCT_ADDR="${authAcctIP}"
./create-sites-enabled-default.sh


# Build certificates
echo "Building certificates..."
make -C /etc/freeradius/3.0/certs
# Modify read privileges for keys
chmod 644 /etc/freeradius/3.0/certs/server.pem | chmod 644 /etc/freeradius/3.0/certs/server.key
# disgusting regex aids to update the eap config
sed -i '0,/private_key_file = \/etc\/ssl\/private\/ssl-cert-snakeoil.key/s//private_key_file = \/etc\/freeradius\/3.0\/certs\/server.key/' /etc/freeradius/3.0/mods-enabled/eap
sed -i '0,/certificate_file = \/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/s//certificate_file = \/etc\/freeradius\/3.0\/certs\/server.pem/' /etc/freeradius/3.0/mods-enabled/eap
sed -i '0,/ca_file = \/etc\/ssl\/certs\/ca-certificates.crt/s//ca_file = \/etc\/freeradius\/3.0\/certs\/ca.pem/' /etc/freeradius/3.0/mods-enabled/eap
# Copy the self signed CA's public keys to the desktop..
cp /etc/freeradius/3.0/certs/ca.pem /home/$SUDO_USER/ca.pem
cp /etc/freeradius/3.0/certs/ca.der /home/$SUDO_USER/ca.der
echo "Copied CA public keys to home directory"


# Ask if we should start radius with the new settings..
echo
echo
read -p "FreeRADIUS has been installed and configured... Run it? Y/n: " userChoice
if [[ "$userChoice" == "n" ]]; then
  exit
fi
if [[ "$userChoice" == "no" ]]; then
  exit
fi

# make sure to restart the radius server if it is already running.. so it gets the new settings
systemctl stop freeradius
# start radius in a new terminal...
if which gnome-terminal > /dev/null; then
  gnome-terminal -- bash -c "freeradius -X; exec bash" &
elif which xfce4-terminal > /dev/null; then
  xfce4-terminal -e "bash -c 'freeradius -X; exec bash'" &
elif which konsole > /dev/null; then
  konsole -e "bash -c 'freeradius -X; exec bash'" &
elif which xterm > /dev/null; then
  xterm -e "bash -c 'freeradius -X; exec bash'" &
elif which terminator > /dev/null; then
  terminator -e "bash -c 'freeradius -X; exec bash'" &
else
  apt install konsole --yes
  konsole -e "bash -c 'freeradius -X; exec bash'" &
fi

sleep 1


# Ask if we should try the connection using EAPOL
echo
echo
read -p "Try PEAP-MSCHAPv2 authentication on localhost? Y/n: " userChoice
if [[ "$userChoice" == "n" ]]; then
  exit
fi
if [[ "$userChoice" == "no" ]]; then
  exit
fi


# Install eapol test so we can try eap authentication..
apt install eapoltest

chmod +x add-user.sh
./add-user.sh

read -p "Enter the email to connect with: " loginMail
read -p "Enter the output password: " keyOutPassword

eapolTestEnty="network={
	ssid=\"example\"
	key_mgmt=WPA-EAP
	eap=TLS
	identity=\"${loginMail}\"
  ca_cert=\"/home/$SUDO_USER/ca.pem\"
  client_cert=\"/home/user/$SUDO_SUER/client-certs/${loginMail}/${loginMail}.pem\"
  private_key=\"/home/user/$SUDO_SUER/client-certs/${loginMail}/${loginMail}.p12\"
	private_key_passwd=\"${keyOutPassword}\"
	eapol_flags=0
}"

touch /home/eapol-tls.cfg
echo "${eapolTestEnty}" >> /home/eapol-tls.cfg
eapol_test -c /home/eapol-tls.cfg -a 127.0.0.1 -s "${sharedSecret}"