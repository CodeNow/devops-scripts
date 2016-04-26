#!/usr/bin/env bash

#
# This is to be run only for legacy logs in /var/log, not application logs in /var/log/runnable
#

# we only want this run as root
if [ "root" != `whoami` ] ; then
    echo "${0}: ERROR - This script needs to be run as root."
    exit 127
fi

# legacy log path
logdir=/var/log
# store log archives here, purge manually
archdir=/docker/archive
datetime=`date +%Y%m%d%H%m`

# these logfiles haven't been modified in > 24 hours, so moving them without cleanup up filehandles first should be OK:
echo "Compressing logs > 24h"
find "${logdir}" -maxdepth 2 -type f -mmin +1440 -name '*.log' -exec bzip2 -9 {} \; -print
echo "Restarting rsyslogd"
# but we do need to clean the filehandles after, just in case
service rsyslog restart

# archive anything > 6h
echo "Archiving logs > 6h"
mkdir -p "${archdir}" 2>&1
find "${logdir}" -maxdepth 2 -type f -mtime +6 -name '*z' | xargs tar jcvpf "${archdir}"/log-archive-"${datetime}".tbz
echo "Purging logs > 1wk"
find "${logdir}" -maxdepth 2 -type f -mtime +6 -exec rm -f {} \; -print
