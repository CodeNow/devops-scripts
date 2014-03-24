WAIT_TIME_MIN=60 # time to wait after we take out of redis to restart
DOCKER_RESTART_TIME_MIN=10 #how log we should wait for box to restart
DOCKER_UP_TIME_MIN=30 #how log to wait for box to register in redis
alias getAttachedDocklets="ssh ubuntu@redis 'redis-cli -h 10.0.1.20 lrange frontend:docklet.runnable.com 0 -1' | grep -v docklets"


function rmAttachedDocklet #docklet
{
	ssh ubuntu@redis "redis-cli -h 10.0.1.20 lrem frontend:docklet.runnable.com 1 $1"
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
CUR_NUM_DOCKS=$NUM_DOCKS
NUM_DOCKS_REDIS=$NUM_DOCKS
for DOCK in DOCKS; do
	# 1. remove from redis
	echo "removing $DOCK from redis, you have 5 seconds to quit"
	sleep 5
	rmAttachedDocklet $DOCK
	NUM_DOCKS_REDIS=$(getAttachedDocklets)
	# make sure we removed
	if [[ "$((NUM_DOCKS-1))" != "$NUM_DOCKS_REDIS" ]]; then
		echo "error removing from redis! abourting"
		exit 
	fi
	echo "dock: $DOCK removed from redis"
	echo "waiting for 1hr before restarting $DOCK. num docks in redis: $NUM_DOCKS_REDIS"
	# 2. wait 1 hr while ensuring rest of docks stay up
	for (( i = 0; i < $WAIT_TIME_MIN; i++ )); do
		TDOCKS=$(getAttachedDocklets)
		TNUM_DOCKS=`echo $DOCKS | wc -w`
		#exit if another box goes down
		if [[ "$TNUM_DOCKS" != "$NUM_DOCKS_REDIS" ]]; then
			echo "some other docklet box went down!! abourting"
			exit 
		fi
		sleep 60
	done

	# 3. ssh into box and reboot it
	$BOX_NUM=$(echo $DOCK | awk -F "." '{print $4}' | sed s/:.*//)
	ssh ubuntu@docker-2-$BOX_NUM 'sudo pm2 kill'
	ssh ubuntu@docker-2-$BOX_NUM 'sudo pm2 kill'
	ssh ubuntu@docker-2-$BOX_NUM 'sudo pm2 kill'
	ssh ubuntu@docker-2-$BOX_NUM 'sudo reboot'

	# 4. wait for box to come online and start pm2 services
	DONE=0
	for (( i = 0; i < $DOCKER_RESTART_TIME_MIN; i++ )); do
		sleep 60
		# ensure we have access again
		ssh ubuntu@docker-2-$BOX_NUM 'echo ABCDEFGHI'
		if [[ "$?" == "0" ]]; then
			TMP=$(ssh ubuntu@docker-2-$BOX_NUM 'echo ABCDEFGHI' | wc -w)
			if [[ "$TMP" == "1" ]]; then
				echo "starting start script"
				ssh ubuntu@docker-2-$BOX_NUM '/home/ubuntu/devops-scripts/docks/startDockletAndBouncer.sh'
				DONE=1
				break
			else
				echo "docker $DOCK did not restart . abourting"
				exit
			fi
		fi
	done

	# wait untill box registers itself
	DOCKS=$(getAttachedDocklets)
	CUR_NUM_DOCKS=`echo $DOCKS | wc -w`
	CNT=0
	while [[ "$NUM_DOCKS" != "$CUR_NUM_DOCKS" ]]; do
		DOCKS=$(getAttachedDocklets)
		CUR_NUM_DOCKS=`echo $DOCKS | wc -w`
		sleep 60
		CNT=$((CNT + 1))
		if [[ "$CNT" == "DOCKER_UP_TIME_MIN" ]]; then
			echo "server did not register after $DOCKER_UP_TIME_MIN min, abourting"
			exit
		fi
	done
	echo "$DOCK is back up! moving on"
done