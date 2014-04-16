#!/bin/bash
WAIT_TIME_MIN=5 # time to wait after we take out of redis to restart
DOCKER_UP_TIME_MIN=60 #how log to wait for box to register in redis
alias getAttachedDocklets="ssh ubuntu@redis 'redis-cli -h 10.0.1.20 lrange frontend:docklet.runnable.com 0 -1' | grep -v docklets"


function rmAttachedDocklet #docklet
{
	ssh ubuntu@redis "redis-cli -h 10.0.1.20 lrem frontend:docklet.runnable.com 1 $1"
}

function isDockeletInRedis 
{
	RE=`ssh ubuntu@redis 'redis-cli -h 10.0.1.20 lrange frontend:docklet.runnable.com 0 -1' | grep $1`
	echo $RE
}

#first get list of docklets
DOCKLET_LIST=$(getAttachedDocklets)

DOCKS=$(getAttachedDocklets)
NUM_DOCKS=`echo $DOCKS | wc -w`
echo "attached docklets: $DOCKS, num = $NUM_DOCKS"
CUR_NUM_DOCKS=$NUM_DOCKS
NUM_DOCKS_REDIS=$NUM_DOCKS
for DOCK in $DOCKS; do

	# continue only if docker version is not this

	BOX_NUM=$(echo $DOCK | awk -F "." '{print $4}' | sed s/:.*//)
	VERSION=`ssh ubuntu@docker-2-$BOX_NUM 'docker version | grep 12a09a8 | wc -l'`
	if [[ "$VERSION" -eq "2" ]]; then
		echo "skiping $DOCK. at docker version=$VERSION"
		continue
	fi
	echo "have to restart $DOCK. at docker version @ $VERSION"

	# 1. remove from redis
	echo "removing $DOCK from redis, you have 5 seconds to quit"
	sleep 5
	rmAttachedDocklet $DOCK
	DOCKS_REDIS=$(getAttachedDocklets)
	NUM_DOCKS_REDIS=`echo $DOCKS_REDIS | wc -w`
	# make sure we removed
	if [[ "$(isDockeletInRedis $DOCK)" -eq "1"  ]]; then
		echo "error removing from redis! abourting num_docks-1=$((NUM_DOCKS-1)) in redis = $NUM_DOCKS_REDIS"
		return 
	fi
	echo "dock: $DOCK removed from redis"
	echo $(date) " waiting for $WAIT_TIME_MIN min before restarting $DOCK. num docks in redis: $NUM_DOCKS_REDIS"
	# 2. wait 1 hr while ensuring rest of docks stay up
	for (( i = 0; i < $WAIT_TIME_MIN; i++ )); do
		echo "$i out of $WAIT_TIME_MIN"
		TDOCKS=$(getAttachedDocklets)
		TNUM_DOCKS=`echo $TDOCKS | wc -w`
		#return if another box goes down
		if [[ "$TNUM_DOCKS" -ne "$NUM_DOCKS_REDIS" ]]; then
			echo "some other docklet box went down!!" 
		fi
		sleep 60
	done

	# 3. ssh into box and update docker
	echo "killing current containers"
	ssh ubuntu@docker-2-$BOX_NUM 'docker kill `docker ps -q`'
	
	echo "stoping docker"
	ssh ubuntu@docker-2-$BOX_NUM 'sudo service docker stop'
	echo "installing docker"
	ssh ubuntu@docker-2-$BOX_NUM 'cd dockworker && git pull'
	ssh ubuntu@docker-2-$BOX_NUM 'sudo cp /home/ubuntu/dockworker/bin/docker010 $(which docker)'
	sleep 10
	ssh ubuntu@docker-2-$BOX_NUM 'sudo service docker start'


	echo "waiting for docker to load"
	ssh ubuntu@docker-2-$BOX_NUM 'docker ps'
	ssh ubuntu@docker-2-$BOX_NUM 'docker version'

	echo "resetart pm2"
	ssh ubuntu@docker-2-$BOX_NUM 'sudo pm2 restart all'

	# 4. wait for box to come online
	# wait untill box registers itself
	echo "wait untill box comes back online"
	CNT=0
	while [[ "$(isDockeletInRedis $DOCK)" -ne "1" ]]; do
		echo "$CNT out of $DOCKER_UP_TIME_MIN"
		sleep 60
		CNT=$((CNT + 1))
		if [[ "$CNT" -eq "DOCKER_UP_TIME_MIN" ]]; then
			echo "server did not register after $DOCKER_UP_TIME_MIN min, abourting"
			return
		fi
	done
	echo "$DOCK is back up! moving on"
done