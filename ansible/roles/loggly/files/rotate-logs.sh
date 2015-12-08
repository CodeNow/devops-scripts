#!/usr/bin/env bash

find /var/log -type f -name '*.log.*z' -mtime +3 -exec rm -f {} \;
bzip2 -9 /var/log/*.log.+([0-9])

