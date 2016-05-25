#!/usr/bin/env bash

set -x

export PKGS="nginx nmap nodejs rsyslog rsyslog-gnutls htop colordiff screen"

sudo apt-get update
sudo apt-get upgrade
sudo apt-get autoremove
sudo apt-get -y install ${PKGS} || echo "Apt installation failure."

date > ${HOME}/.install.date

exit 0
