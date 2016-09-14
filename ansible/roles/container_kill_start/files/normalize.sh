#!/bin/bash
# $1 should be image id to keep $2 = image name
for CONT in `sudo docker ps --no-trunc -q `
do
  IMAGE_NAME=`sudo docker inspect $CONT | grep Image | grep $2`
  if [[ $IMAGE_NAME ]]; then
    IMAGE_ID=`sudo docker inspect $CONT | grep Image | grep -v $2 | awk -F\" '{print $4}'`
    if [[ "$IMAGE_ID" != "$1" ]]; then
      echo "kill"
      sudo docker kill $CONT
      sudo docker rm $CONT
    fi
  fi
done
