#!/bin/bash
# THIS FILE IS MANAGED BY ANSIBLE. PLEASE DO NOT MODIFY. MODIFICATIONS WILL NOT BE SAVED.
# AUTHOR: BRYAN KENDALL

docker run --rm {{ container_image }}:{{ container_tag }} {{ cron_log_canary_command }}
