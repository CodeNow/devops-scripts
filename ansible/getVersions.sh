#!/bin/bash

consul=localhost:8500/v1

if [[ $1 != "" ]]; then
  consul=$1:8500/v1
fi

kv=$consul/kv

echo NODE_ENV: $(curl -s $kv/node/env | jq -r '.[0].Value' | base64 -d)

echo image-builder: $(curl -s $kv/image-builder/version | jq -r '.[0].Value' | base64 -d)
echo docker-listener: $(curl -s $kv/docker-listener/version | jq -r '.[0].Value' | base64 -d)
echo krain: $(curl -s $kv/krain/version | jq -r '.[0].Value' | base64 -d)
echo sauron: $(curl -s $kv/sauron/version | jq -r '.[0].Value' | base64 -d)
echo charon: $(curl -s $kv/charon/version | jq -r '.[0].Value' | base64 -d)
