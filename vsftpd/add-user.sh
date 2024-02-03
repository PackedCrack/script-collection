#!/bin/bash

read -p "Enter Username: " username

read -p "Use a custom home directory location? Y/n: " makeCustomHome
if [[ "${makeCustomHome}" != "n" ]]; then
	echo -e "\nAvailable disk space:"
	df -h

	while [[ true ]]; do
		read -p "Enter home directory location: " homeDirectoryLocation
		read -p "User \"${username}\" will have its home directory at \"${homeDirectoryLocation}\". Is it correct? Y/n: " confirm
		if [[ "${confirm}" != "n" ]]; then
			break
		fi
	done

	if [[ "${homeDirectoryLocation}" != *"${username}" ]]; then
		homeDirectoryLocation="${homeDirectoryLocation}/${username}"
	fi

	if [[ ! -d "${homeDirectoryLocation}" ]]; then
		sudo mkdir -p "${homeDirectoryLocation}"
	fi

	sudo chown "${username}":"${username}" "${homeDirectoryLocation}"
	sudo chmod 550 "${homeDirectoryLocation}"

	uploadDir="${homeDirectoryLocation}/uploads"

	sudo adduser --home "${homeDirectoryLocation}" "${username}"
else 
	sudo adduser "${username}"
	uploadDir="/home/${username}/uploads"
fi


sudo mkdir "${uploadDir}"
sudo chown "${username}":"${username}" "${uploadDir}"
sudo chmod 770 "${uploadDir}"

sudo systemctl restart vsftpd
