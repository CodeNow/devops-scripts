#!/bin/bash

if [[ $1 = '' ]]; then
  echo 'script requires a client name'
  exit 1
fi
CLIENT=$1

# generate key for client
openssl genrsa -out "$CLIENT-key.pem" 2048
chmod 400 "$CLIENT-key.pem"

# generate CSR for client
openssl req \
  -subj '/CN=client' \
  -new \
  -key "$CLIENT-key.pem" \
  -out "$CLIENT-client.csr"
chmod 400 "$CLIENT-client.csr"

echo extendedKeyUsage = clientAuth > "$CLIENT-extfile.cnf"

# generate cert for client
openssl x509 \
  -req \
  -days 365 \
  -in "$CLIENT-client.csr" \
  -CA ca.pem \
  -CAkey ca-key.pem \
  -CAcreateserial \
  -out "$CLIENT-cert.pem" \
  -extfile "$CLIENT-extfile.cnf"
chmod 400 "$CLIENT-cert.pem"

