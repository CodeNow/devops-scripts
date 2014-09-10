#!/usr/bin/env python

from fabric.api import *

env.user = "ubuntu"
env.use_ssh_config = True
env.newrelic_application_id = ""

env.hosts = [
  'd1',
  'd2',
  'd4',
  'dmag',
  'dgp2'
]

@parallel
def aufs():
  run('sudo apt-get install -y linux-image-extra-`uname -r`')
  run('sudo service docker restart')

@parallel
def setulimit():
  sudo('echo "fs.file-max=1048576" >> /etc/sysctl.conf')
  sudo('echo "* soft nofile 1048576" >> /etc/security/limits.conf')
  sudo('echo "* hard nofile 1048576" >> /etc/security/limits.conf')
  sudo('echo "root soft nofile 1048576" >> /etc/security/limits.conf')
  sudo('echo "root hard nofile 1048576" >> /etc/security/limits.conf')

@parallel
def ulimit():
  run('ulimit -n')

@parallel
def reboot():
  run('sudo reboot')

@parallel
def pull():
  with cd('/runnable/node-hello-world/'):
    run('git pull')

@parallel
def test():
  run('tmux new -d "/runnable/node-hello-world/parallel-test"')
  run('tmux ls')

@parallel
def check():
  run('tail -f /runnable/node-hello-world/data')

@parallel
def clean():

  run('sudo docker kill `sudo docker ps -q` || echo done')
  run('sudo docker rm `sudo docker ps -aq` || echo done')
  run('sudo docker rmi `sudo docker images -q` || echo done')
  run('sudo service docker stop || echo done ')
  run('sudo rm -rf /docker/* || echo done')
  run('sudo rm -rf /docker/.* || echo done')
  run('sudo reboot')

@parallel
def tail():
  run('sudo tail -f /var/log/upstart/docker.log')