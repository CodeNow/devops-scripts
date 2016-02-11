#!/usr/bin/env bash

sudo mkfs.ext4 -b 8192 /dev/xvdb
sudo mkdir /docker
printf "/dev/xvdb\t/docker\text4\tdefaults,nofail\t0\t2\n" | sudo tee -a /etc/fstab
sudo mount /docker

##
## pass through
