#!/usr/bin/env bash

set -x

rm -f /root/.env > /dev/null 2>&1
echo 'export CONSUL_HOST={{ consul_host_address }}' | sudo tee -a /root/.env
echo 'export SERVICES="{{ services_list }}"' | sudo tee -a /root/.env

sudo bash -x /root/bootstrapServicePullStart.sh |& sudo tee -a /var/log/userdata-script.log
