#!/bin/bash
# $1 should be image id to keep $2 = image name
echo "ARGS" $1 $2
for CONT in `docker ps --no-trunc -q `
do
  IMAGE_NAME=`docker inspect $CONT | grep Image | grep $2`
  if [[ $IMAGE_NAME ]]; then
    echo "image found $IMAGE_NAME"
    IMAGE_ID=`docker inspect $CONT | grep Image | grep -v $2 | awk -F\" '{print $4}'`
    if [[ "$IMAGE_ID" != "$1" ]]; then
      echo "stoping $IMAGE_ID does not match $1"
      docker kill $CONT
    fi
  fi
done