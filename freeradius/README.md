# Utility scripts for freeradius on debian based systems
## install-radius.sh
This will guide you through the install and initial configuration of freeradius. The configuration sets up AP's, root CA, Server certification etc. It will also at the end ask to install EAPOL-TEST, in order to test a EAP-TLS connection.
#### create-eap-cfg.sh and create-sites-enabled-default.sh
These are helper scripts called by the 'install-radius.sh' script. You should not call them yourself, but they must be in the same directory as 'install-radius.sh'
### How to use
* Set cwd to the directory that contains 'install-radius.sh'.
* Follow the instructions in the terminal.
## add-user.sh
This will create a new user for the radius server by creating that users certificates.
### How to use
* Simply follow the instructions in the terminal.
* The user certificates will be copied to: "/home/$SUDO_USER/client-certs/${clientEmail}/"