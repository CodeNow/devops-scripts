#!/usr/bin/env bash

if [ -l "/usr/bin/node" -o -l "/usr/sbin/node" ] ; then
    apt-get remove -y node
    rm /usr/bin/node > /dev/null 2>&1
    rm /usr/sbin/node > /dev/null 2>&1
fi

################################################################################
# Installs node 4.x on Ubuntu 14.04 LTS
# See: https://nodejs.org/en/download/package-manager/
################################################################################
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
apt-get install -y nodejs build-essential jq

################################################################################
# Install utility packages via npm
################################################################################
npm install -g bunyan nvm json 
