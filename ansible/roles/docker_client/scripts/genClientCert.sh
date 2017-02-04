#!/bin/bash

if [[ $1 = '' ]]; then
  echo 'script requires a client name'
  exit 1
fi
CLIENT=./files/certs/$1

echo 'WARN: hard coded alpha-api-old gamma-services and beta-services for SWARM'
if [[ $2 = '' ]]; then
  echo 'script requires a client ip address'
  exit 1
fi

MAIN_HOST_IP_ADDRESS=$2

mkdir $CLIENT

# generate key for client
openssl genrsa -out "$CLIENT/key.pem" 2048
chmod 400 "$CLIENT/key.pem"

# generate CSR for client
openssl req \
  -subj '/CN=client' \
  -new \
  -key "$CLIENT/key.pem" \
  -out "$CLIENT/client.csr"

chmod 400 "$CLIENT/client.csr"

echo extendedKeyUsage=clientAuth,serverAuth > "$CLIENT/extfile.cnf"
echo subjectAltName=IP:127.0.0.1,DNS:localhost >> "$CLIENT/extfile.cnf"
echo subjectAltName=IP:10.4.0.221,IP:10.4.0.148,IP:10.8.4.40,IP:10.12.12.136,IP:10.8.5.63,IP:10.8.6.59,IP:10.4.6.251,IP:127.0.0.1,DNS:localhost,DNS:swarm-staging-codenow.runnableapp.com >> "$CLIENT/extfile.cnf"

# generate cert for client
openssl x509 \
  -req \
  -days 365 \
  -sha256 \
  -in "$CLIENT/client.csr" \
  -CA ca.pem \
  -CAkey ca-key.pem \
  -CAcreateserial \
  -out "$CLIENT/cert.pem" \
  -extfile "$CLIENT/extfile.cnf"

# set permissions for deploy
chmod 644 "$CLIENT/cert.pem"
chmod 644 "$CLIENT/key.pem"

# cleanup files we do not need
rm $CLIENT/extfile.cnf
rm $CLIENT/client.csr
