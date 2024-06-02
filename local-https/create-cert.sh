#!/bin/bash

sudo mkdir -p /etc/certs/

sudo chown -R $USER /etc/certs

# Create private key for certificate
openssl genrsa -out /etc/certs/home.key 2048

# Create a certificate signing request
openssl req -new -key /etc/certs/home.key -out home.csr -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=localhost"

# Sign the certificate with the CA
openssl x509 -req -in home.csr -CA /etc/certs/localCA.pem -CAkey /etc/certs/localCA.key -CAcreateserial -out /etc/certs/home.crt -days 500 -sha256 -extfile localhost.ext
