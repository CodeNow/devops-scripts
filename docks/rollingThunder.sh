#!/usr/bin/env bash

#
# "headless" dock killer, uses docks-cli to roll through an environment and recycle (mark unhealthy) all docks
#
# Design notes: assumes this is being run with the purpose of upgrading a launch configuration for all the docks in an environment.
#
# Will operate in two modes: regular - with the expectation that the entire site will be refreshed within 7 hours or so; and "schwifty", 
# the "wham-bam-thank-you-ma'am" expedited version should we want to throw caution to the wind as Rick Sanchez would say and "get
# schwifty."
#
# The program will use simple recursion to scale-out a set percentage of an org until only instances with the new lauch config are 
# present. When an org is marked complete, Rolling Thunder(tm) will iterate through to the next org until all orgs are exhausted, then exit.
#

usage() {
    # KISS
    echo "${0} <env> <launchConfig> [ <orgId> | <schwifty> ]"
    exit 1
}

which docks > /dev/null 2>&1
if [ 0 -ne "${?}" ] ; then
    echo "Swing and a miss. Install 'docks-cli'."
    exit 1
fi

DOCKS=`which docks`

if [ ${#} -eq 3 ] ; then
    if [ "schwifty" == "${3}" ] ; then
        BEAST_MODE="enabled"
    else
        ORG_ID="${3}" # shou we test if this is an integer? nah.
    fi
elif [ ${#} -lt 2 -o ${#} -gt 3 ] ; then
    usage
fi

# Let us assume that env and launchConfig are then expressed as arguments in the proper order.
ENV="${1}"
LAUNCH_CONFIG="${2}"

