#!/bin/bash


EAP_FILENAME="/etc/freeradius/3.0/mods-available/eap"
#INPUT_PASSWORD="TEST_PASS"


#sudo cp "${EAP_FILENAME}" "${EAP_FILENAME}".bakup

# clear previous content
echo -e "eap {\n" > "${EAP_FILENAME}"
# now append data
echo -e "   default_eap_type = tls\n" >> "${EAP_FILENAME}"
echo -e "   timer_expire = 60\n" >> "${EAP_FILENAME}"
echo -e "   ignore_unknown_eap_types = no\n" >> "${EAP_FILENAME}"
echo -e "   cisco_accounting_username_bug = no\n" >> "${EAP_FILENAME}"
echo -e '   max_sessions = ${max_requests}\n' >> "${EAP_FILENAME}"
echo -e "       tls-config tls-common {\n" >> "${EAP_FILENAME}"
echo -e "           private_key_password = ${INPUT_PASSWORD}" >> "${EAP_FILENAME}"
echo -e "           private_key_file = /etc/freeradius/3.0/certs/server.key" >> "${EAP_FILENAME}"
echo -e "           certificate_file = /etc/freeradius/3.0/certs/server.pem	" >> "${EAP_FILENAME}"
echo -e "           ca_file = /etc/freeradius/3.0/certs/ca.pem" >> "${EAP_FILENAME}"
echo -e '           ca_path = ${cadir}' >> "${EAP_FILENAME}"
echo -e '           cipher_list = "DEFAULT"' >> "${EAP_FILENAME}"
echo -e "           cipher_server_preference = no" >> "${EAP_FILENAME}"
echo -e '           tls_min_version = "1.2"' >> "${EAP_FILENAME}"
echo -e '           tls_max_version = "1.2"' >> "${EAP_FILENAME}"
echo -e '           ecdh_curve = ""' >> "${EAP_FILENAME}"
echo -e "               cache {" >> "${EAP_FILENAME}"
echo -e "                   enable = no" >> "${EAP_FILENAME}"
echo -e "                   lifetime = 24" >> "${EAP_FILENAME}"
echo -e "                       store {" >> "${EAP_FILENAME}"
echo -e "                           Tunnel-Private-Group-Id" >> "${EAP_FILENAME}"
echo -e "                       }" >> "${EAP_FILENAME}"
echo -e "                }" >> "${EAP_FILENAME}"
echo -e "                verify {" >> "${EAP_FILENAME}"
echo -e "                }" >> "${EAP_FILENAME}"
echo -e "                ocsp {" >> "${EAP_FILENAME}"
echo -e "                   enable = no" >> "${EAP_FILENAME}"
echo -e "                   override_cert_url = yes" >> "${EAP_FILENAME}"
echo -e '                   url = "http://127.0.0.1/ocsp/"' >> "${EAP_FILENAME}"
echo -e "                }" >> "${EAP_FILENAME}"
echo -e "       }" >> "${EAP_FILENAME}"
echo -e "       tls {" >> "${EAP_FILENAME}"
echo -e "           tls = tls-common" >> "${EAP_FILENAME}"
echo -e "       }" >> "${EAP_FILENAME}"
echo -e "       ttls {" >> "${EAP_FILENAME}"
echo -e "           tls = tls-common" >> "${EAP_FILENAME}"
echo -e "           default_eap_type = md5" >> "${EAP_FILENAME}"
echo -e "           copy_request_to_tunnel = no" >> "${EAP_FILENAME}"
echo -e "           use_tunneled_reply = no" >> "${EAP_FILENAME}"
echo -e '           virtual_server = "inner-tunnel"' >> "${EAP_FILENAME}"
echo -e "       }" >> "${EAP_FILENAME}"
echo -e "       peap {" >> "${EAP_FILENAME}"
echo -e "           tls = tls-common" >> "${EAP_FILENAME}"
echo -e "           default_eap_type = mschapv2" >> "${EAP_FILENAME}"
echo -e "           copy_request_to_tunnel = no" >> "${EAP_FILENAME}"
echo -e "           use_tunneled_reply = no" >> "${EAP_FILENAME}"
echo -e '           virtual_server = "inner-tunnel"' >> "${EAP_FILENAME}"
echo -e "       }" >> "${EAP_FILENAME}"
echo -e "       mschapv2 {" >> "${EAP_FILENAME}"
echo -e "       }" >> "${EAP_FILENAME}"
echo -e "}" >> "${EAP_FILENAME}"