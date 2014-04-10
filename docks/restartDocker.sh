WAIT_TIME_MIN=10 # time to wait after we take out of redis to restart
DOCKER_RESTART_TIME_MIN=10 #how log we should wait for box to restart
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

#now iterate through them and do the following
# 1. remove from redis  
# 2. wait 1 hr while checking if a server went down every min and abort if so
# 3. ssh into machine and reboot
# 4. wait till it is online and sudo pm2 restart
# 5. wait untill it is online and repeat


DOCKS=$(getAttachedDocklets)
NUM_DOCKS=`echo $DOCKS | wc -w`
echo "attached docklets: $DOCKS, num = $NUM_DOCKS"
CUR_NUM_DOCKS=$NUM_DOCKS
NUM_DOCKS_REDIS=$NUM_DOCKS
for DOCK in $DOCKS; do

	# continue only if number > 65000

	BOX_NUM=$(echo $DOCK | awk -F "." '{print $4}' | sed s/:.*//)
	PORT=`ssh ubuntu@docker-2-$BOX_NUM 'docker ps | head -n 2 | grep -o ".....->80" | sed s/-.*//'`
	if [[ "$PORT" -lt "65000" ]]; then
		echo "skiping $DOCK. at port=$PORT"
		continue
	fi
	echo "have to restart $DOCK. at port @ $PORT"

	# 1. remove from redis
	echo "removing $DOCK from redis, you have 5 seconds to quit"
	sleep 5
	rmAttachedDocklet $DOCK
	DOCKS_REDIS=$(getAttachedDocklets)
	NUM_DOCKS_REDIS=`echo $DOCKS_REDIS | wc -w`
	# make sure we removed
	if [[ "$(isDockeletInRedis $DOCK)" -eq "1"  ]]; then
		echo "error removing from redis! abourting num_docks-1=$((NUM_DOCKS-1)) in redis = $NUM_DOCKS_REDIS"
		exit 
	fi
	echo "dock: $DOCK removed from redis"
	echo $(date) " waiting for $WAIT_TIME_MIN min before restarting $DOCK. num docks in redis: $NUM_DOCKS_REDIS"
	# 2. wait 1 hr while ensuring rest of docks stay up
	for (( i = 0; i < $WAIT_TIME_MIN; i++ )); do
		TDOCKS=$(getAttachedDocklets)
		TNUM_DOCKS=`echo $TDOCKS | wc -w`
		#exit if another box goes down
		if [[ "$TNUM_DOCKS" -ne "$NUM_DOCKS_REDIS" ]]; then
			echo "some other docklet box went down!! abourting"
			exit 
		fi
		sleep 60
	done

	# 3. ssh into box and restart docker

	echo "killing current containers"
	ssh ubuntu@docker-2-$BOX_NUM 'docker kill `docker ps -q`'
	
	echo "restarting docker"
	ssh ubuntu@docker-2-$BOX_NUM 'sudo service docker stop'
	sleep 10  
	ssh ubuntu@docker-2-$BOX_NUM 'sudo service docker start'

	# 4. wait for box to come online
	# wait untill box registers itself
	echo "wait untill box comes back online"
	CNT=0
	while [[ "$(isDockeletInRedis $DOCK)" -ne "1" ]]; do
		sleep 60
		CNT=$((CNT + 1))
		if [[ "$CNT" -eq "DOCKER_UP_TIME_MIN" ]]; then
			echo "server did not register after $DOCKER_UP_TIME_MIN min, abourting"
			exit
		fi
	done
	echo "$DOCK is back up! moving on"
done