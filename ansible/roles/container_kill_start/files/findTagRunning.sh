#!/usr/bin/env bash

IMAGE_NAME="$1"
CONTAINER_NAME="$2"
CONTAINERS=`docker ps -a | grep -v '^CONTAINER' | awk '{print $1}'`

if [ "" = "${CONTAINERS}" ] ; then
    exit 0
else
    for container in ${CONTAINERS} ; do
        docker inspect "${container}" 2>/dev/null| grep -q '"Image": "'"${IMAGE_NAME}" &> /dev/null
        HAS_IMAGE=$?
        if [ ! -z "${CONTAINER_NAME}"  ] ; then
          docker inspect "${container}" 2>/dev/null| grep -q  "\"Name\": \"\/${CONTAINER_NAME}\"" > /dev/null 2>&1
          HAS_CONTAINER_NAME=$?
        else
          HAS_CONTAINER_NAME=0
        fi
        if [ ${HAS_IMAGE} -eq 0 ] && [ ${HAS_CONTAINER_NAME} -eq 0 ]; then
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
