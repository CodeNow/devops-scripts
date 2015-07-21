#!/bin/bash
set -e
if [[ $1 = '' ]]; then
  echo 'script requires a host IP'
  exit 1
fi
HOST=$1
if [[ $2 = '' ]]; then
  echo 'script requires cert path'
  exit 1
fi
CERT_PATH=$2
# generate server key
openssl genrsa -out "$CERT_PATH/server-key-$HOST.pem" 2048
chmod 400 "$CERT_PATH/server-key-$HOST.pem"

# generate host CSR
openssl req \
  -subj "/CN=$HOST" \
  -new \
  -key "$CERT_PATH/server-key-$HOST.pem" \
  -out "$CERT_PATH/server-$HOST.csr"
chmod 400 "$CERT_PATH/server-$HOST.csr"

# put host IP in alternate names
echo "subjectAltName = IP:$HOST,IP:127.0.0.1,DNS:localhost" > "$CERT_PATH/extfile-$HOST.cnf"

# generate host certificate
openssl x509 \
  -req \
  -days 365 \
  -in "$CERT_PATH/server-$HOST.csr" \
  -CA $CERT_PATH/ca.pem \
  -CAkey $CERT_PATH/ca-key.pem \
  -CAcreateserial \
  -out "$CERT_PATH/server-cert-$HOST.pem" \
  -extfile "$CERT_PATH/extfile-$HOST.cnf" \
  -passin file:$CERT_PATH/pass
chmod 400 "$CERT_PATH/server-cert-$HOST.pem"
