#!/usr/bin/env bash

. /root/.env || export setFatal="true"

die() {
    EXIT_CODE=$1
    EXIT_MESSAGE=$2
    echo $2 && exit $1
    return
}

CONTAINER_RUN_ARGS=
if [ "true" != "${setFatal}" ] ; then
    # do the things
    #
    # CONSUL_HOST="<consul server>"
    # SERVICES="<app name in Ansible>"
    for service in ${SERVICES} ; do
        curl -q -s http://${CONSUL_HOST}:8500/v1/kv/runnable/environment/${service} > /dev/null 2>&1
        CURL_RESULT="${?}"
        if [ 0 -eq ${CURL_RESULT} ] ; then
            TAGGED_VERSION=`curl -q -s http://${CONSUL_HOST}:8500/v1/kv/runnable/environment/${service} | sed 's/,/\n/g' | grep Value | sed 's/\\"//g' | awk -F: '{print $2}'| base64 --decode`
            docker pull registry.runnable.com/runnable/${service}:${TAGGED_VERSION}
            DOCKER_PULL_RESULT="${?}"
        else
            die 255 "Could not open http://${CONSUL_HOST}:8500/v1/kv/runnable/environment/${service}"
        fi
        curl -q -s http://${CONSUL_HOST}:8500/v1/kv/runnable/container_run/${service} > /dev/null 2>&1
        CONTAINER_RUN_RESULT="${?}"
        if [ 0 -eq ${CONTAINER_RUN_RESULT} ] ; then
            CONTAINER_RUN_ARGS=`curl -q -s http://${CONSUL_HOST}:8500/v1/kv/runnable/container_run/${service} | sed 's/,/\n/g' | grep Value | sed 's/\\"//g' | awk -F: '{print $2}'| base64 --decode` 
        fi
        docker ps | grep -q '${service}:' > /dev/null 2>&1
        DOCKER_RUNNING_RESULT="${?}"
        if [ 0 -eq ${DOCKER_RUNNING_RESULT} ] ; then
            DOCKER_CONTAINER=`docker ps | grep -q '${service}:' | awk '{print $1}'`
            docker kill ${DOCKER_CONTAINER}
            sleep 5
        fi
        docker run \
            --log-driver=syslog --log-opt syslog-facility=local7 --log-opt tag="${service}" \
            ${CONTAINER_RUN_ARGS} registry.runnable.com/runnable/${service}:${TAGGED_VERSION} || die -1 "something went wrong with 'docker run'."
    done
else
    # don't do the things, complain, exit
    die 1 "Could not open /root/.env!"
fi

