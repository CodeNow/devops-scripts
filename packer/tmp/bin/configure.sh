#!/usr/bin/env bash

set -x

#Parameters to pass to apt:
APT_OPTS="""-q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" """

# Create docker FS:
sudo mkdir /docker
sudo chmod 755 /docker
sudo chown root.root /docker
#sed 's/\/mnt/\/docker/g' /etc/fstab > /tmp/fstab
#sudo umount /mnt
#sudo mv /tmp/fstab /etc/fstab
#sudo mount /docker

# Docker Init
sudo DEBIAN_FRONTEND=noninteractive apt-get ${APT_OPTS} install apt-transport-https ca-certificates
sudo DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee -a /etc/apt/sources.list.d/docker.list
printf "Package: docker-engine\nPin: version 1.10.2*\nPin-Priority: 1001\n" | sudo tee -a /etc/apt/preferences.d/docker-engine 

# NodeJS Init
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -

# Docker Install
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get ${APT_OPTS} install docker-engine

# NodeJS, build-essential, utilities
export PKGS="ansible build-essential colordiff git htop jq make nmap nodejs openjdk-7-jdk unzip"
sudo DEBIAN_FRONTEND=noninteractive apt-get ${APT_OPTS} upgrade
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove
sudo DEBIAN_FRONTEND=noninteractive apt-get ${APT_OPTS} install ${PKGS} || echo "Apt installation failure."

# ec2-metadata
curl --silent -q -O http://s3.amazonaws.com/ec2metadata/ec2-metadata
sudo install -c -m 755 ec2-metadata /usr/local/bin || echo "Could not install ec2-metadata."
rm ec2-metadata

# ec2-api-tools
curl --silent -q -O http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
unzip ec2-api-tools.zip 
sudo mv ec2-api-tools-1.7.5.1 /usr/local/ec2

sudo npm install -g bunyan

date > ${HOME}/.install.date

exit 0
