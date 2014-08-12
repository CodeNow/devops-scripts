#!/bin/bash
WAIT_TIME_MIN=5 # time to wait after we take out of redis to restart
alias getAttachedDocklets="ssh ubuntu@prod-redis 'redis-cli -h 10.0.1.20 lrange frontend:docklet.runnable.com 0 -1' | grep -v docklets"


function rmAttachedDocklet #docklet
{
	ssh ubuntu@prod-redis "redis-cli -h 10.0.1.20 lrem frontend:docklet.runnable.com 1 $1"
}

function isDockeletInRedis
{
	RE=`ssh ubuntu@prod-redis 'redis-cli -h 10.0.1.20 lrange frontend:docklet.runnable.com 0 -1' | grep -m 1 "$1" | wc -l`
	echo $RE
}

#first get list of docklets
DOCKS=(prod-dock1 prod-dock2 prod-dock3 prod-dock4 prod-dock5 prod-dock6 prod-dock7 prod-dock8 prod-dock9 prod-dock10 prod-dock11 prod-dock12)
# DOCKS=(prod-dock11 prod-dock12)

NUM_DOCKS=`echo ${DOCKS[*]} | wc -w`
echo "attached docklets: $DOCKS, num = $NUM_DOCKS"
CUR_NUM_DOCKS=$NUM_DOCKS
NUM_DOCKS_REDIS=$NUM_DOCKS

for DOCK in ${DOCKS[*]}; do

	BOX_IP=$(ssh ubuntu@$DOCK 'hostname' | sed s/ip-// | sed s/-/./g)
	REDIS_NAME=`echo http://$BOX_IP:4244`

	echo "estarting $DOCK"

	# 1. remove from redis
	rmAttachedDocklet $REDIS_NAME
	DOCKS_REDIS=$(getAttachedDocklets)
	NUM_DOCKS_REDIS=`echo $DOCKS_REDIS | wc -w`
	# make sure we removed
	if [[ "$(isDockeletInRedis $REDIS_NAME)" -eq "1"  ]]; then
		echo "error removing from redis! abourting num_docks-1=$((NUM_DOCKS-1)) in redis = $NUM_DOCKS_REDIS"
	fi
	echo "dock: $DOCK removed from redis"
	echo $(date) " waiting for $WAIT_TIME_MIN min before restarting $DOCK. num docks in redis: $NUM_DOCKS_REDIS"
	# 2. wait while ensuring rest of docks stay up
	for (( i = 0; i < $WAIT_TIME_MIN; i++ )); do
		echo "$i out of $WAIT_TIME_MIN"
		sleep 60
	done

	# 3. ssh into box and reboot
	echo "killing current containers"
	ssh ubuntu@$DOCK 'docker -H=127.0.0.1:4242 kill `docker -H=127.0.0.1:4242 ps -q`'

	echo "rebooting"
	ssh ubuntu@$DOCK 'sudo reboot'
	sleep 60
	ssh ubuntu@$DOCK 'docker -H=127.0.0.1:4242 ps'
done