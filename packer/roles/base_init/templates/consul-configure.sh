#!/usr/bin/env bash

set -x

# consul
curl --silent -q -O https://releases.hashicorp.com/consul-template/0.11.1/consul-template_0.11.1_linux_amd64.zip
unzip consul-template_0.11.1_linux_amd64.zip
sudo install -c -m 755 consul-template /usr/local/bin || echo "Could not install consul."
rm -f consul*
