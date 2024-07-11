#!/bin/bash

echo "Installing VSFTPD.."
sudo apt install vsftpd

read -p "Enter a FTP server banner: " banner

sudo sed -i "s/#ftpd_banner=Welcome to blah FTP service./ftpd_banner=${banner}./" /etc/vsftpd.conf
sudo sed -i 's/#chroot_local_user=YES/chroot_local_user=YES/' /etc/vsftpd.conf
sudo sed -i 's/#idle_session_timeout=600/idle_session_timeout=600/' /etc/vsftpd.conf

read -p "Allow uploads? Y/n: " allowUploads
if [[ "${allowUploads}" != "n" ]]; then
	sudo sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf
fi

read -p "Enable TLS? Y/n: " enableTLS
if [[ "${enableTLS}" != "n" ]]; then
	echo "Installing openssl.."
	sudo apt install openssl

	# put all keys in its own directory
	mkdir ftpkeys
	mkdir ftpkeys/priv
	sudo chown root:root ftpkeys/priv
	mkdir ftpkeys/cert

	echo "Generating CA Private Key"
	cd ftpkeys/priv
	sudo openssl genpkey -algorithm RSA -out ftpca.key -aes256
	sudo chown root:root ftpca.key
	sudo chmod 600 ftpca.key
	cd ..

	echo "Creating self signed root certificate.."	
	cd cert
	sudo openssl req -x509 -new -nodes -key ../priv/ftpca.key -sha256 -days 3650 -out ftpca.crt
	cd ..

	echo "Generating ftp server's private key.."
	cd priv
	sudo openssl genpkey -algorithm RSA -out vsftpd.key
	sudo chown root:root vsftpd.key
	sudo chmod 600 vsftpd.key
	cd ..	
	
	echo "Creating Certificate Signing Request for the server"
	cd cert
	sudo openssl req -new -key ../priv/vsftpd.key -out ftp.csr

	echo "Signing the Server Certificate.."
	sudo openssl x509 -req -in ftp.csr -CA ftpca.crt -CAkey ../priv/ftpca.key -CAcreateserial -out ftp.crt -days 365 -sha256
	cd ..

	# move keys to home
	cd ..
	sudo mv ftpkeys /home/ftpkeys

	# Update vsftpd.conf to enable TLS
	sudo sed -i 's|rsa_cert_file=\/etc/ssl\/certs\/ssl-cert-snakeoil.crt|rsa_cert_file=\/home\/certs\/ftp.crt|' /etc/vsftpd.conf
	sudo sed -i 's/rsa_private_key_file=\/etc\/ssl\/private\/ssl-cert-snakeoil.pem/rsa_cert_file=\/home\/priv\/vsftpd.key/' /etc/vsftpd.conf
	sudo sed -i 's/ssl_enable=NO/ssl_enable=YES/' /etc/vsftpd.conf

	sudo su
	echo "allow_anon_ssl=NO" >> /etc/vsftpd.conf
	echo "force_local_data_ssl=YES" >> /etc/vsftpd.conf
	echo "force_local_logins_ssl=YES" >> /etc/vsftpd.conf
 	# If on debian12 then tls1.2 and 1.3 options doesnt exist - you have to remove line 69 - 72 and leave line 74 - 76 (tls 1.2 and 1.3 will be allowed implicitly)
	echo "ssl_tlsv1_3=YES" >> /etc/vsftpd.conf
	echo "ssl_tlsv1_2=YES" >> /etc/vsftpd.conf
 	echo "ssl_sslv1=NO" >> /etc/vsftpd.conf	
  	echo "ssl_tlsv1_1=NO" >> /etc/vsftpd.conf
  	# Turn of deprecated ssl/tls protocols
	echo "ssl_tlsv1=NO" >> /etc/vsftpd.conf
	echo "ssl_sslv3=NO" >> /etc/vsftpd.conf
	echo "ssl_sslv2=NO" >> /etc/vsftpd.conf
	
	exit
fi

while [[ true ]]; do
	read -p "Add a new FTP user? Y/n: " answer
	if [[ "${answer}" != "n" ]]; then
		./add-user.sh
	else
		break
	fi
done
