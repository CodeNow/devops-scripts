#!/usr/bin/env bash

set -x

# vault
curl --silent -q -O https://releases.hashicorp.com/vault/0.4.1/vault_0.4.1_linux_amd64.zip
unzip vault_0.4.1_linux_amd64.zip
sudo install -c -m 755 vault /usr/local/bin || echo "Could not install vault."
rm -f vault*
