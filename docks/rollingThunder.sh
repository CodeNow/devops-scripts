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
which aws > /dev/null 2>&1
if [ 0 -ne "${?}" ] ; then
    echo "Whatchu talkin' bout, Willis? Install AWS CLI."
    exit 1
fi

AWS=`which aws`
DOCKS=`which docks`
ORG_ID="" # lazy, I know.

BEAST_MODE=""
if [ ${#} -eq 3 ] ; then
    if [ "schwifty" == "${3}" ] ; then
        BEAST_MODE="enabled"
    else
        ORG_ID="${3}"
    fi
elif [ ${#} -lt 2 -o ${#} -gt 3 ] ; then
    usage
fi

# Let us assume that env and launchConfig are then expressed as arguments in the proper order.
ENV="${1}"
LAUNCH_CONFIG="${2}"

# Let us now contemplate our existence, and find out what the hell AMI our launch configuration uses.
AMI_ID=`${AWS} autoscaling describe-launch-configurations --launch-configuration-names "${LAUNCH_CONFIG}" | grep "ImageId" | awk '{print $2}' | sed 's/[\",]//g'`

# Functionly. Functionify. iFunction. Function Junction.
function dockGetOrgs() {
    ${DOCKS} asg list -e ${ENV} | \
        grep producgtion | \
        grep -v '^$' | \
        awk '{printf("%s ".$4);}'
}

# Pre-fabricate various `docks` queries to generate lists:
function dockGetOld() {
    MYORG="${1}"
    ${DOCKS} aws -e ${ENV} --org ${MYORG} | \
        grep -v "${AMI_ID}" | \
        grep running | \
        awk '{printf("%s ",$6);}'
}

function dockGetNew() {
    MYORG="${1}"
    ${DOCKS} aws -e ${ENV} --org ${MYORG} | \
        grep "${AMI_ID}" | \
        awk '{printf("%s ",$6);}'
}

function dockGetAll() {
    ${DOCKS} aws -e ${ENV} | \
        grep "${AMI_ID}" | \
        awk '{printf("%s ",$6);}'
}

function setLaunchConfig() {
    MYORGS="${1}"
    for org in ${MYORGS} ; do
        ${DOCKS} asg lc --org ${org} --lc ${LAUNCH_CONFIG} -e ${ENV}
    done
}

function seekAndDestroy() {
    MYDOCKS="${1}"
    for dock in ${MYDOCKS} ; do
        ( printf "y\n\n" | \
            ${DOCKS} unhealthy -e ${ENV} -i ${dock} )
    done
}

function hushHushKeepItDownNowVoicesCarry() {
    sleep 300
}

# TODO -
# grok per-org scaling group size
# some modulo math on scaling groups > 2
# recusion!

#
# Putting it together.
#

if [ "" != "${ORG_ID}" ] ; then
    ORGS=$(docksGetOrgs)
    setLaunchConfig ${ORGS}
else
    setLaunchConfig ${ORG_ID}
fi



