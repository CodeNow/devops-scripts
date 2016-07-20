#!/usr/bin/env bash

IMAGE_NAME="$1"
CONTAINERS=`docker ps -a | grep -v '^CONTAINER' | awk '{print $1}'`

if [ "" = "${CONTAINERS}" ] ; then
    exit 0
else
    for container in ${CONTAINERS} ; do
        docker inspect "${container}" 2>/dev/null| grep -q '"Image": "'"${IMAGE_NAME}": > /dev/null 2>&1
        if [ ${?} -eq 0 ] ; then
            if [ -z "${RUNNING_CONTAINERS}" ] ; then
                RUNNING_CONTAINERS="${container}"
            else
                RUNNING_CONTAINERS="${RUNNING_CONTAINERS} ${container}"
            fi
        fi
    done
fi

if [ ! -z "${RUNNING_CONTAINERS}" ] ; then
    echo "${RUNNING_CONTAINERS//['\t\r\n']}"
fi
