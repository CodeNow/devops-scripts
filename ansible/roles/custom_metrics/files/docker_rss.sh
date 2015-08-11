#!/bin/bash
set -e

# don't run this if datadog is not installed
if [ ! -e /usr/bin/dd-agent ]; then exit 0; fi

docker_pid=$(ps ax | awk '/\/usr\/bin\/docker.+\-d.+/{ print $1 }')
docker_rss_value=$(echo 0 $(awk '/Rss/ {print "+", $2}' "/proc/$docker_pid/smaps") | bc)
data="bryan.docker.mem.rss:$docker_rss_value|g"

echo "$data" | nc -u -w 1 localhost 8125
