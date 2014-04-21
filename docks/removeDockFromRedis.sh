#!/bin/bash
if [[ $# -ne 3 ]]; then
  echo "useage: rmAttachedDocklet <server> <key> <value_to_rm>"
  exit
fi
SERVER="$1"
KEY="$2"
VALUE="$3"
echo "removing $3 from $SERVER. key $2. you have 5 seconds to stop"
sleep 5
HOST=$(ssh ubuntu@$SERVER "hostname" | sed s/ip-// | sed s/-/\\./g)
ssh ubuntu@$SERVER "redis-cli -h $HOST lrem $KEY 1 $VALUE" 