#!/usr/bin/env bash

#
# This is to be run logs in {{ app_log_dir }}.
# Runs from crontab.
#

LOGDIR=${1}

# We can compress anything older than 6 hours
find ${LOGDIR} -mindepth 2 -type f -mmin +360 -name '*.log' -exec bzip2 -9 {} \; 

# purge anything > 1wk
find ${LOGDIR} -maxdepth 2 -type f -mtime +6 -exec rm -f {} \; 
