#!/usr/bin/env bash

set -x

# Create docker FS:
sudo mkfs.ext4 -i 8192 /dev/xvdb || echo "Error initializing /dev/xvdb!"
sudo mkdir -p /docker
printf "/dev/xvdb\t/docker\text4\tdefaults,nofail\t0\t2\n" | sudo tee -a /etc/fstab
sudo mount /docker

# Base packages
export PKGS="build-essential make unzip openjdk-7-jdk jq nmap htop colordiff git"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get autoremove
sudo apt-get -y install ${PKGS} || echo "Apt installation failure."

# Docker
sudo apt-get -y install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee -a /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get -y install docker-engine=1.10.2-0~trusty

# consul
curl --silent -q -O https://releases.hashicorp.com/consul-template/0.11.1/consul-template_0.11.1_linux_amd64.zip
unzip consul-template_0.11.1_linux_amd64.zip
sudo install -c -m 755 consul-template /usr/local/bin || echo "Could not install consul."
rm -f consul*

# vault
curl --silent -q -O https://releases.hashicorp.com/vault/0.4.1/vault_0.4.1_linux_amd64.zip
unzip vault_0.4.1_linux_amd64.zip
sudo install -c -m 755 vault /usr/local/bin || echo "Could not install vault."
rm -f vault*

# weave
curl --silent -q -O https://github.com/weaveworks/weave/releases/download/v1.4.6/weave
sudo install -c -m 755 weave /usr/local/bin || echo "Could not install weave."
rm -f weave

# ec2-metadata
curl --silent -q -O http://s3.amazonaws.com/ec2metadata/ec2-metadata
sudo install -c -m 755 ec2-metadata /usr/local/bin || echo "Could not install ec2-metadata."
rm ec2-metadata

# ec2-api-tools
curl --silent -q -O http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
unzip ec2-api-tools.zip 
sudo mv ec2-api-tools-1.7.5.1 /usr/local/ec2

sudo service docker restart
date > ${HOME}/.install.date

exit 0
