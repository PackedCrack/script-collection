#!/bin/bash

if [[ $(whoami) != 'root' ]]; then
  echo "The script must be run as root.."
  echo "Open a root terminal with \"sudo su\""
  exit
fi

# make backup
cp /etc/freeradius/3.0/certs/client.cnf /etc/freeradius/3.0/certs/client.cnf.backup


# Setup the server certificate config
read -p "User email: " clientEmail

while true; do
    read -p "User input password: " clientPasswordIn
    read -p "repeat password: " clientPasswordRepeatedIn

  if [[ "$clientPasswordIn" == "$clientPasswordRepeatedIn" ]]; then
    break
  fi
  echo "The entered passwords did not match.. try again."
done

while true; do
    read -p "User output password: " clientPasswordOut
    read -p "repeat password: " clientPasswordRepeatedOut

  if [[ "$clientPasswordOut" == "$clientPasswordRepeatedOut" ]]; then
    break
  fi
  echo "The entered passwords did not match.. try again."
done

# Set client specific information
sed -i "0,/input_password[[:space:]]*= whatever/s//input_password          = "${clientPasswordIn}"/" /etc/freeradius/3.0/certs/client.cnf
sed -i "0,/output_password[[:space:]]*= whatever/s//output_password          = "${clientPasswordOut}"/" /etc/freeradius/3.0/certs/client.cnf
sed -i "0,/emailAddress[[:space:]]*= user@example.org/s//emailAddress            = "${clientEmail}"/" /etc/freeradius/3.0/certs/client.cnf
sed -i "0,/commonName[[:space:]]*= user@example.org/s//commonName              = \"${clientEmail}\"/" /etc/freeradius/3.0/certs/client.cnf


cd /etc/freeradius/3.0/certs/
make client.pem


# Check if the directory exists
if [ ! -d "/home/$SUDO_USER/client-certs" ]; then
    mkdir /home/$SUDO_USER/client-certs
fi

mkdir /home/$SUDO_USER/client-certs/${clientEmail}

cp /etc/freeradius/3.0/certs/${clientEmail}.pem /home/$SUDO_USER/client-certs/${clientEmail}/${clientEmail}.pem
cp /etc/freeradius/3.0/certs/${clientEmail}.p12 /home/$SUDO_USER/client-certs/${clientEmail}/${clientEmail}.p12
echo "Copied client keys to home directory"


# restore original
rm /etc/freeradius/3.0/certs/client.cnf
cp /etc/freeradius/3.0/certs/client.cnf.backup /etc/freeradius/3.0/certs/client.cnf