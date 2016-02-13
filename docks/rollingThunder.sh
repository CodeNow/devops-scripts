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
ORG_ID=""
BATCHSIZE=1

BEAST_MODE=""
if [ ${#} -eq 3 ] ; then
    if [ "schwifty" == "${3}" ] ; then
        BEAST_MODE="enabled"
        BATCHSIZE=2100
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

# Get list of Orgs.
function dockGetOrgs() {
    ${DOCKS} asg list -e ${ENV} | \
        grep production | \
        grep -v '^$' | \
        awk '{printf("%s ".$4);}'
}

# fetch a batch docks to kill
function dockGetKillBatch() {
    MYORG="${1}"
    ${DOCKS} aws -e ${ENV} --org ${MYORG} | \
        grep -v "${AMI_ID}" | \
        grep running | \
        tail -${BATCHSIZE} | \
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

function getDesiredInstances() {
    MYORG="${1}"
    ${DOCKS} asg -e ${ENV} | \
        grep "${MYORG}" | \
        awk '{print $8}'
}

function calculateInstanceCountOffset() {
    MYCOUNT="${1}"
    if [ 4 -ge ${MYCOUNT} ] ; then
        echo 1
    else
        MYCOUNT=`expr ${MYCOUNT} / 4 + 1`
        echo ${MYCOUNT}
    fi
}

function scaleOutDesiredInstances() {
    MYORG="${1}"
    MYINSTCOUNT="${2}"
    ${DOCKS} asg scale-out --org ${MYORG} --number ${MYINSTCOUNT}
    return ${?}
}

function scaleInDesiredInstances() {
    MYORG="${1}"
    MYINSTCOUNT="${2}"
    ${DOCKS} asg scale-in --org ${MYORG} --number ${MYINSTCOUNT}
    return ${?}
}

function seekAndDestroy() {
    MYDOCKS="${1}"
    for dock in ${MYDOCKS} ; do
        ( printf "y\n\n" | \
            ${DOCKS} unhealthy -e ${ENV} -i ${dock} )
    done
}

function hushHushKeepItDownNowVoicesCarry() {
    MYINTERVAL=${1}
    sleep ${MYINTERVAL}
}

# psuedo-code:
#
# set launch config 
# get scaling group desired number
# scale out by 25%
# wait
# check for new docks ; if yes, continue
# if no, back off by x + ( x * .5 ) where initial x = 300. back off a maximum of 3 times before failing.
# skim first 25% of old docks list.
# restore original scaling group desired number.
# rinse, repeat.
# exit when docksGetOld returns an empty string.

# discussion - instead of concerning ourselves with the full list of matching docks (that is to say, docks that are not using the new AMI from
# our desired launch config, we simply pop N number of instances off the top of the stack where N is 1 if # of desired instances per the ASG is
# <= 4 or N is the integer result of ( number of desired instances / 4 + 1 ).
#
# the thinking behind this is that if we simply ask for the integer division result then we would only kill 1 dock per cycle for scaling groups of
# up to 7 desired instances, which seems wildly ineffient. on the other hand, it may be a corner case with a too clever by half solution to a
# non problem.
#
# either way, simply asking for a subset of total docks until none are returned is much more clean than maintaining an internal tally managed
# independantly from the results `docks` supply.
#
# Putting it together.
#

# Set the launch config
if [ "enabled" == "${BEASTMODE}" ] ; then
    KILLBATCH=$(docksGetAll)
    seekAndDestroy ${KILLBATCH}
else
    if [ "" != "${ORG_ID}" ] ; then
        ORGS=$(docksGetOrgs)
    else
        ORGS="${ORG_ID}"
    fi

    for org in ${ORGS} ; do
        # the needful
        DESIREDCOUNT=$(getDesiredInstances ${org})
        BATCHSIZE=$(calculateInstanceCountOffset ${DESIREDCOUNT})
        scaleOutDesiredInstances ${org} ${BATCHSIZE}
        INTERVAL=300
        NEWINSTANCESTATUS=1
        LASTNEWINSTANCES=""
        NEWINSTANCES=""
        KILLBATCH=""
        RETRY=0
        while [ ${NEWINSTANCESTATUS} ] ; do
            hushHushKeepItDownNowVoicesCarry ${INTERVAL}
            INTERVAL=`expr ${INTERVAL} + ${INTERVAL} / 2`
            NEWINSTANCES=$(dockGetNew ${org})
            if [ -z "${NEWINSTANCES}" ] ; then
                if [ ${INTERVAL} -le 1000 ] ; then
                    continue
                else
                    RETRYFAIL=1
                    break
                fi
            elif [ "${NEWINSTANCES}" == "${LASTNEWINSTANCES}" ] ; then
                if [ 3 -eq ${RETRY} ] ; then
                    RETRYFAIL=1
                    break
                else
                    RETRY=`expr ${RETRY} + 1`
                fi
            else
                KILLBATCH=$(dockGetKillBatch ${org})
                if [ -z "${KILLBATCH}" ] ; then
                    break
                else
                    seekAndDestroy ${KILLBATCH}
                fi
            fi
        done
        scaleInDesiredInstances ${org} ${BATCHSIZE}
    done
fi


