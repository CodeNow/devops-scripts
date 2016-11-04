#!/bin/bash
# THIS FILE IS MANAGED BY ANSIBLE. PLEASE DO NOT MODIFY. MODIFICATIONS WILL NOT BE SAVED.
# AUTHOR: BRYAN KENDALL

docker run --rm {{ container_image }}:{{ container_tag }} bash -c " \
  /khronos/bin/cli.js --event {{ item.cron_event }} --job '{}' --host {{ cron_rabbit_host_address }} {{ cron_rabbit_auth }};"
