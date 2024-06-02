#!/bin/bash

sudo mkdir -p /etc/certs/

sudo chown -R $USER /etc/certs

# Create private key for the CA
openssl genrsa -out /etc/certs/localCA.key 2048

# Create a new CA certificate
openssl req -x509 -new -nodes -key /etc/certs/localCA.key -sha256 -days 1024 -out /etc/certs/localCA.pem -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=LocalCA"

# Add the CA to the system keychain
sudo security add-trusted-cert \
  -d \
  -r trustRoot \
  -k /Library/Keychains/System.keychain \
    /etc/certs/localCA.pem