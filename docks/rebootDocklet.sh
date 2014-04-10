WAIT_TIME_MIN=10 # time to wait after we take out of redis to restart
DOCKER_RESTART_TIME_MIN=10 #how log we should wait for box to restart
DOCKER_UP_TIME_MIN=30 #how log to wait for box to register in redis

DOCK=$1


alias isDockeletInRedis="ssh ubuntu@redis 'redis-cli -h 10.0.1.20 lrange frontend:docklet.runnable.com 0 -1' | grep $DOCK"

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


# 1. remove from redis
echo "removing $DOCK from redis, you have 5 seconds to quit"
sleep 5
rmAttachedDocklet $DOCK
DOCKS_REDIS=$(getAttachedDocklets)
NUM_DOCKS_REDIS=`echo $DOCKS_REDIS | wc -w`
# make sure we removed
if [[ "$((NUM_DOCKS-1))" -ne "$NUM_DOCKS_REDIS" ]]; then
	echo "error removing from redis! abourting num_docks-1=$((NUM_DOCKS-1)) in redis = $NUM_DOCKS_REDIS"
	return 
fi
echo "dock: $DOCK removed from redis"
echo $(date) " waiting for 1hr before restarting $DOCK. num docks in redis: $NUM_DOCKS_REDIS"
# 2. wait 1 hr while ensuring rest of docks stay up
for (( i = 0; i < $WAIT_TIME_MIN; i++ )); do
	TDOCKS=$(getAttachedDocklets)
	TNUM_DOCKS=`echo $TDOCKS | wc -w`
	#exit if another box goes down
	if [[ "$TNUM_DOCKS" -ne "$NUM_DOCKS_REDIS" ]]; then
		echo "some other docklet box went down!! abourting"
		return 
	fi
	sleep 60
done

# 3. ssh into box and reboot it
BOX_NUM=$(echo $DOCK | awk -F "." '{print $4}' | sed s/:.*//)
echo "trying to kill pm2. if hangs press ctrl+c and we will try 2 more times"
ssh ubuntu@docker-2-$BOX_NUM 'sudo pm2 kill'
echo "trying to kill pm2. if hangs exit and we will try 1 more times"
ssh ubuntu@docker-2-$BOX_NUM 'sudo pm2 kill'
echo "trying to kill pm2. if hangs exit and we will continue"
ssh ubuntu@docker-2-$BOX_NUM 'sudo pm2 kill'
ssh ubuntu@docker-2-$BOX_NUM 'sudo reboot'

# 4. wait for box to come online and start pm2 services
DONE=0
for (( i = 0; i < $DOCKER_RESTART_TIME_MIN; i++ )); do
	sleep 60
	# ensure we have access again
	ssh ubuntu@docker-2-$BOX_NUM 'echo ABCDEFGHI'
	if [[ "$?" -eq "0" ]]; then
		TMP=$(ssh ubuntu@docker-2-$BOX_NUM 'echo ABCDEFGHI' | wc -w)
		if [[ "$TMP" -eq "1" ]]; then
			echo "starting start script"
			ssh ubuntu@docker-2-$BOX_NUM '/home/ubuntu/devops-scripts/docks/startDockletAndBouncer.sh production'
			DONE=1
			break
		else
			echo "docker $DOCK did not restart . abourting"
			return
		fi
	fi
done

# wait untill box registers itself
CNT=0
while [[ "$(isDockeletInRedis)" -ne "1" ]]; do
	sleep 60
	CNT=$((CNT + 1))
	if [[ "$CNT" -eq "DOCKER_UP_TIME_MIN" ]]; then
		echo "server did not register after $DOCKER_UP_TIME_MIN min, abourting"
		return
	fi
done
echo "$DOCK is back up! moving on"