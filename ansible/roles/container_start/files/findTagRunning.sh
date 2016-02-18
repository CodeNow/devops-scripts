#!/usr/bin/env bash

IMAGE_NAME="$1"
RUNNING_CONTAINERS=""

CONTAINERS=`docker ps | grep -v '^CONTAINER' | awk '{print $1}'`

if [ "" = "${CONTAINERS}" ] ; then
    exit 0
else
    for container in ${CONTAINERS} ; do
        docker inspect ${container} | grep -q ${IMAGE_NAME}
        if [ ${?} -eq 0 ] ; then
            if [ -z ${RUNNING_CONTAINERS} ] ; then
                RUNNING_CONTAINERS="${container}"
            else
                RUNNING_CONTAINERS="${RUNNING_CONTAINERS} ${container}"
            fi
        fi
    done
fi

echo "${RUNNING_CONTAINERS}"
