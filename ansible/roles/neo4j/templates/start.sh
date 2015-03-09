#!/bin/bash

limit=`ulimit -n`
if [ "$limit" -lt 40000 ]; then
    ulimit -n 40000;
fi

./bin/neo4j console
