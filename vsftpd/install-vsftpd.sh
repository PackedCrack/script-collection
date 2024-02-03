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


while [[ true ]]; do
	read -p "Add a new FTP user? Y/n: " answer
	if [[ "${answer}" != "n" ]]; then
		./add-user.sh
	else
		break
	fi
done