#!/bin/bash
sudo su
export CONSUL_HOSTNAME=10.4.5.144
DOCK_INIT_SCRIPT=/opt/runnable/dock-init/init.sh
bash $DOCK_INIT_SCRIPT >> /var/log/user-script-dock-init.log 2>&1
