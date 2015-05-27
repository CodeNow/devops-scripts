#!/bin/bash
set -e

echo '########################################'
cat scripts/ca-request.txt
echo '########################################'

# generate key for ca
openssl genrsa -aes256 -out ca-key.pem 2048
chmod 400 ca-key.pem

# generate public key
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
chmod 400 ca.pem
