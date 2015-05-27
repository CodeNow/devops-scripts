#!/bin/bash

if [[ $1 = '' ]]; then
  echo 'script requires a host IP'
  exit 1
fi
HOST=$1

# generate server key
openssl genrsa -out "server-key-$HOST.pem" 2048
chmod 400 "server-key-$HOST.pem"

# generate host CSR
openssl req \
  -subj "/CN=$HOST" \
  -new \
  -key "server-key-$HOST.pem" \
  -out "server-$HOST.csr"
chmod 400 "server-$HOST.csr"

# put host IP in alternate names
echo "subjectAltName = IP:$HOST,IP:127.0.0.1" > "extfile-$HOST.cnf"

# generate host certificate
openssl x509 \
  -req \
  -days 365 \
  -in "server-$HOST.csr" \
  -CA ca.pem \
  -CAkey ca-key.pem \
  -CAcreateserial \
  -out "server-cert-$HOST.pem" \
  -extfile "extfile-$HOST.cnf"
chmod 400 "server-cert-$HOST.pem"

