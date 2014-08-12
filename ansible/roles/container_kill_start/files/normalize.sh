#!/bin/bash
# $1 should be image id to keep $2 = image name
for CONT in `docker ps --no-trunc -q `
do
  IMAGE_NAME=`docker inspect $CONT | grep Image | grep $2`
  if [[ $IMAGE_NAME ]]; then
    IMAGE_ID=`docker inspect $CONT | grep Image | grep -v $2 | awk -F\" '{print $4}'`
    if [[ "$IMAGE_ID" != "$1" ]]; then
      echo "kill"
      docker kill $CONT
      docker rm $CONT
    fi
  fi
done