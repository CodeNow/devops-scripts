#!/usr/bin/env bash

NAME="$1"

docker service ps ${NAME} > /dev/null 2>&1
EC=${?}
if [ 0 == ${EC} ] ; then
    echo OK
fi

exit
