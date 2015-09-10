#!/bin/bash
set -e

# don't run this if datadog is not installed
if [ ! -e /usr/bin/dd-agent ]; then exit 0; fi

# don't run this if docker is not installed
if [ ! -e /usr/bin/docker ]; then exit 0; fi

all_lines='0'

for id in $(docker ps -q); do
  file=$(docker inspect $id | awk 'match($0, /"LogPath": "(.+)",/, a) { print a[1]; }')
  lines=$(wc -l $file | awk '{ print $1 }')
  all_lines=$(echo $all_lines + $lines | bc)
done

data="bryan.docker.logs.lines:$all_lines|g"
echo "$data" | nc -u -w 1 localhost 8125
