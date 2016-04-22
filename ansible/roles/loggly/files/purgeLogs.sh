#!/usr/bin/env bash

#
# This is to be run logs in {{ app_log_dir }}.
# Runs from crontab.
#

logdir=${1}

# We can compress anything older than 6 hours
find ${logdir} -mindepth 2 -type f -mmin +360 -name '*.log' -exec bzip2 -9 {} \; 

# We automatically purge anything > 1wk
find ${logdir} -maxdepth 2 -type f -mtime +7 -exec rm -f {} \; 
