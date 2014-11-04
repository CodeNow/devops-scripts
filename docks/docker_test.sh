##deps
function clean
{
  docker kill `docker ps -q` 2>&1 > /dev/null
  docker rm `docker ps -aq` 2>&1 > /dev/null
}
clean
service docker restart
clean

docker pull google/nodejs-hello
FAIL_COUNT=0
LOG_PATH=~/test.log

# start 100 containers without error
for I in `seq 1 100`; do
  docker run -dP google/nodejs-hello >> $LOG_PATH
  if [ $? -ne 0 ]; then
    FAIL_COUNT=$((FAIL_COUNT+1))
  fi
done
echo "start fail count $FAIL_COUNT"
clean

# ensure they can stay up for a min
sleep 60

# check urls
FAIL_COUNT=0

for I in `docker ps -q`; do
  ADDR=`docker port $I 8080`
  OUT=`curl $ADDR`
  if [[ "$OUT" != "Hello World" ]]; then
    FAIL_COUNT=$((FAIL_COUNT+1))
  fi
done
echo "curl fail count $FAIL_COUNT"
clean

# ensure we can kill process without error
FAIL_COUNT=0
for I in `docker ps -q`; do
  docker kill $I >> $LOG_PATH
  if [ $? -ne 0 ]; then
    FAIL_COUNT=$((FAIL_COUNT+1))
  fi
done
echo "kill fail count $FAIL_COUNT"
clean

# get logs of 100 instances without panic
for I in `seq 1 100`; do
  docker run -d ubuntu bash -c 'while true; do for i in `seq 1 10000000`; do echo 1234567890123456789012345678901234567890123456789012345678901234567890123456789 $RANDOM; done; done;' >> $LOG_PATH &
done

for I in `docker ps -q`; do
  docker logs -f $I >> ~/test &
  sleep 30 && docker kill $I >> $LOG_PATH &
done
grep panic /var/log/upstart/docker.log
clean