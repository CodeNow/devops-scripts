#!/usr/bin/env bash

. /root/.env || export setFatal="true"

die() {
    # debug = exit
    # prod = halt
    DIECMD="exit"
    # DIECMD=halt
    local EXIT_CODE=${1}
    local EXIT_MESSAGE=${2}
    if [ "exit" = "${DIECMD}" ] ; then
        echo ${2} && ${DIECMD} ${1}
    else
        echo ${2} && ${DIECMD}
    fi
    return
}

fix_logs() {
    local SVC=${1}
    SRC="/etc/rsyslog.d/21-rotated-docker.conf"
    DST="/etc/rsyslog.d/21-rotated-${SVC}.conf"
    sed "s/docker_engine/${SVC}/g" ${SRC} > ${DST}
}

test_curl() {
    local SVC=${1}
    curl -q -s http://${CONSUL_HOST}:8500/v1/kv/runnable/environment/${SVC} > /dev/null 2>&1
    echo ${?}
}

test_container_run_config() {
    local SVC=${1}
    curl -q -s http://${CONSUL_HOST}:8500/v1/kv/runnable/container_run/${SVC} > /dev/null 2>&1
    echo ${?}
}

test_docker_running() {
    local SVC=${1}
    docker ps | grep -q "${SVC}:" > /dev/null 2>&1
    echo ${?}
}

# Wait until docker engine is up:
TRIES=0
MAXTRIES=10
BACKOFF=10
while [ ${MAXTRIES} -gt ${TRIES} ] ; do
    TRIES=`expr ${TRIES} + 1`
    docker ps > /dev/null 2>&1
    DOCKER_ENGINE="${?}"
    if [ 0 -eq ${DOCKER_ENGINE} ] ; then
        break
    else
        WAIT=`expr ${MAXTRIES} \* ${TRIES}`
        sleep ${WAIT}
    fi
done
if [ ${MAXTRIES} -eq ${TRIES} ] ; then
    die 128 "Docker engine did not start!"
fi
CONTAINER_RUN_ARGS=
if [ "true" != "${setFatal}" ] ; then
    # do the things
    #
    # CONSUL_HOST="<consul server>"
    # SERVICES="<app name in Ansible>"
    for service in ${SERVICES} ; do
        CURL_RESULT="$(test_curl ${service})"
        if [ 0 -eq ${CURL_RESULT} ] ; then
            TAGGED_VERSION=`curl -q -s http://${CONSUL_HOST}:8500/v1/kv/runnable/environment/${service} | sed 's/,/\n/g' | grep Value | sed 's/\\"//g' | awk -F: '{print $2}'| base64 --decode`
            docker pull registry.runnable.com/runnable/${service}:${TAGGED_VERSION}
            DOCKER_PULL_RESULT="${?}"
        else
            die 255 "Could not open http://${CONSUL_HOST}:8500/v1/kv/runnable/environment/${service}"
        fi
        CONTAINER_RUN_RESULT="$(test_container_run_config ${service})"
        if [ 0 -eq ${CONTAINER_RUN_RESULT} ] ; then
            CONTAINER_RUN_ARGS=`curl -q -s http://${CONSUL_HOST}:8500/v1/kv/runnable/container_run/${service} | sed 's/,/\n/g' | grep Value | sed 's/\\"//g' | awk -F: '{print $2}'| base64 --decode`
        fi
        DOCKER_RUNNING_RESULT="$(test_docker_running ${service})"
        if [ 0 -eq ${DOCKER_RUNNING_RESULT} ] ; then
            DOCKER_CONTAINER=`docker ps | grep -q '${service}:' | awk '{print $1}'`
            docker kill ${DOCKER_CONTAINER}
            sleep 5
        fi
        TRIES=0
        MAXTRIES=3
        BACKOFF=30
        while [ ${MAXTRIES} -gt ${TRIES} ] ; do
            TRIES=`expr ${TRIES} + 1`
            docker run \
                --log-driver=syslog --log-opt syslog-facility=local7 --log-opt tag="${service}" \
                ${CONTAINER_RUN_ARGS} registry.runnable.com/runnable/${service}:${TAGGED_VERSION}
            DOCKER_RUN_RESULT="${?}"
            if [ 0 -eq ${DOCKER_RUN_RESULT} ] ; then
                break
            else
                WAIT=`expr ${BACKOFF} \* ${TRIES}`
                sleep ${WAIT}
            fi
        done
        if [ ${MAXTRIES} -eq ${TRIES} ] ; then
            die -1 "Docker failed to start ${service}:${TAGGED_VERSION}"
        fi
    done
else
    # don't do the things, complain, exit
    die 1 "Could not open /root/.env!"
fi


