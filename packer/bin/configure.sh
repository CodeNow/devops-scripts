#!/usr/bin/env bash

set -x

export PKGS="make unzip openjdk-7-jdk jq nmap htop colordiff"

sudo apt-get update
sudo apt-get upgrade
sudo apt-get autoremove
sudo apt-get -y install ${PKGS} || echo "Apt installation failure."

curl -O https://releases.hashicorp.com/vault/0.4.1/vault_0.4.1_linux_amd64.zip
date > ${HOME}/.install.date

exit 0
