#!/bin/bash
set -e

# don't run this if datadog is not installed
if [ ! -e /usr/bin/dd-agent ]; then exit 0; fi

docker_pid=$(ps ax | awk '/\/usr\/bin\/docker.+\-d.+/{ print $1 }')

docker_vmrss_value=$(awk '/VmRSS/{ print $2 }' /proc/$docker_pid/status)
data="bryan.docker.proc.vmrss:$docker_vmrss_value|g"
echo "$data" | nc -u -w 1 localhost 8125

docker_fdsize_value=$(awk '/FDSize/{ print $2 }' /proc/$docker_pid/status)
data="bryan.docker.proc.fdsize:$docker_fdsize_value|g"
echo "$data" | nc -u -w 1 localhost 8125

docker_vmsize_value=$(awk '/VmSize/{ print $2 }' /proc/$docker_pid/status)
data="bryan.docker.proc.vmsize:$docker_vmsize_value|g"
echo "$data" | nc -u -w 1 localhost 8125
