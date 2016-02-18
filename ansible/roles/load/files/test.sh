#!/bin/bash
for i in `seq 1 $CUR`; do
  CUR=1
  cd /runnable/node-hello-world
  echo "" > data
  for i in `seq 1 $CUR`; do
    ./load.sh &
  done

  for job in `jobs -p`; do
    wait $job
  done

  cat data
done