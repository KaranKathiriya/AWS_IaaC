#!/bin/sh

#SECURITY GROUPS SHOULD ALLOW (PORTS: 22,80,443)

#######################################
###       Enable TLS On Server      ###
#######################################

sudo service httpd start
sudo yum install -y mod_ssl

#
#Generating Self Signed Dummy Certificate
#
cd /etc/pki/tls/certs
sudo ./make-dummy-cert localhost.crt

#
# Edit apache /etc/httpd/conf.d/ssl.conf file
#
sudo sed -i 's@SSLCertificateKeyFile /etc/pki/tls/private/localhost.key@#SSLCertificateKeyFile /etc/pki/tls/private/localhost.key@' /etc/httpd/conf.d/ssl.conf
sudo service httpd restart

#################################################
###       Become a Certificate Authority      ###
#################################################

#
# Generate private key
#
sudo openssl genrsa -des3 -out /etc/pki/tls/private/myCA.key 2048

#
# Generate root certificate
#
sudo openssl req -x509 -new -nodes -key /etc/pki/tls/private/myCA.key -sha256 -days 825 \
-out /etc/pki/tls/private/myCA.pem

#########################################
###       Create CA-signed certs      ###
#########################################

#
#Read Domain name
#
printf "Type the domain name ( i.e. - mydomain.com ) :"
read NAME

#
# Generate a private key
#
sudo openssl genrsa -out /etc/pki/tls/private/$NAME.key 2048

#
# Create a certificate-signing request
#
sudo openssl req -new -key /etc/pki/tls/private/$NAME.key -out /etc/pki/tls/private/$NAME.csr

#
#Create a config file for the extensions
#
sudo echo 'authorityKeyIdentifier=keyid,issuer'>/etc/pki/tls/private/$NAME.ext
sudo echo 'basicConstraints=CA:FALSE'>>/etc/pki/tls/private/$NAME.ext
sudo echo 'keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment'>>/etc/pki/tls/private/$NAME.ext
sudo echo 'subjectAltName = @alt_names'>>/etc/pki/tls/private/$NAME.ext
sudo echo '[alt_names]'>>/etc/pki/tls/private/$NAME.ext
sudo echo 'DNS.1 = '$NAME' # Be sure to include the domain name here'>>/etc/pki/tls/private/$NAME.ext
sudo echo 'DNS.2 = www.'$NAME' # Optionally, add additional domains '>>/etc/pki/tls/private/$NAME.ext

#
#Create the signed certificate
#
sudo openssl x509 -req -in /etc/pki/tls/private/$NAME.csr -CA \
/etc/pki/tls/private/myCA.pem -CAkey \
/etc/pki/tls/private/myCA.key -CAcreateserial \
-out /etc/pki/tls/private/$NAME.crt -days 825 -sha256 -extfile \
/etc/pki/tls/private/$NAME.ext

#
# Edit apache /etc/httpd/conf.d/ssl.conf file
#
sudo sed -i 's@SSLCertificateFile /etc/pki/tls/certs/localhost.crt@SSLCertificateFile /etc/pki/tls/private/'$NAME'.crt@' /etc/httpd/conf.d/ssl.conf
sudo sed -i 's@#SSLCertificateKeyFile /etc/pki/tls/private/localhost.key@SSLCertificateKeyFile /etc/pki/tls/private/'$NAME'.key@' /etc/httpd/conf.d/ssl.conf


sudo systemctl restart httpd