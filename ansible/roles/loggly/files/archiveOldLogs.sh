#!/usr/bin/env bash

#
# This is to be run only for legacy logs in /var/log, not application logs in /var/log/runnable
#

if [ "root" != `whoami` ] ; then
    echo "It don't mean a thing if it ain't got that swing."
    exit 127
fi

LOGDIR=/var/log
ARCHDIR=/docker/archive
DATE=`date +%Y%m%d%H%m`

# these haven't been modified in > 24 hours, so "doing it live" should be OK:
echo "Compressing logs > 24h"
find ${LOGDIR} -maxdepth 2 -type f -mmin +1440 -name '*.log' -exec bzip2 -9 {} \; -print
echo "Restarting rsyslogd"
service rsyslog restart

# archive anything > 1wk
echo "Archiving logs > 1wk"
mkdir -p ${ARCHDIR} 2>&1
find ${LOGDIR} -maxdepth 2 -type f -mtime +6 -name '*z' | xargs tar jcvpf ${ARCHDIR}/log-archive-${DATE}.tbz 
echo "Purging logs > 1wk"
find ${LOGDIR} -maxdepth 2 -type f -mtime +6 -exec rm -f {} \; -print
