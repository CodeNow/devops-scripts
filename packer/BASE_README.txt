Base Images:
============

1) Community Image Instance Details:
    a) Ubuntu "Trusty" LTS latest image
    b) 64-bit
    c) EBS backed
    d) HVM type virtualization

2) Instance type:
    a) build - t2.micro
    b) production - m4.large
    c) custom builds may use different machine types

3) Storage:
    a) root file system - 32GB, stock
    b) /docker file system, /dev/xvdb, 200GB, high inode-density, ext4fs


mkfs.ext4 -i 8192 /dev/xvdb 
mkdir /docker
printf "/dev/xvdb\t/docker\text4\tdefaults,nofail\t0\t2\n" | tee -a /etc/fstab
mount /docker

4) Networking:
    a) eth0
    b) build - any docks subnet
    c) security group - dock sg

5) Docker:

apt-get update
apt-get install apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | tee -a /etc/apt/sources.list.d/docker.list

