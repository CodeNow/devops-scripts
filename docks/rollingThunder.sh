#!/usr/bin/env bash

# "headless" dock killer, uses docks-cli to roll through an environment and recycle (mark unhealthy) all docks
#
# Design notes: assumes this is being run with the purpose of upgrading a launch configuration for all the docks in an environment.
#
# Will operate in two modes: regular - with the expectation that the entire site will be refreshed within 7 hours or so; and "schwifty", 
# the "wham-bam-thank-you-ma'am" expedited version should we want to throw caution to the wind as Rick Sanchez would say and "get
# schwifty."

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
    awk '{printf("%s ",$4);}'
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
    if [ 0 -ne ${?} ] ; then
        echo "Failed to update launch configuration, bailing."
        exit 1
    fi
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
${DOCKS} asg scale-out -e ${ENV} --org ${MYORG} --number ${MYINSTCOUNT}
if [ 0 -ne ${?} ] ; then
    echo "Scale-out failed, bailing."
    exit 1
fi
}

function scaleInDesiredInstances() {
MYORG="${1}"
MYINSTCOUNT="${2}"
${DOCKS} asg scale-in -e ${ENV} --org ${MYORG} --number ${MYINSTCOUNT}
if [ 0 -ne ${?} ] ; then
    echo "Scale-in failed, bailing."
    exit 1
fi
}

function seekAndDestroy() {
MYDOCKS="${1}"
for dock in ${MYDOCKS} ; do
    ( printf "y\n\n" | \
        ${DOCKS} unhealthy -e ${ENV} -i ${dock} )
    MYEXIT=${?}
    if [ 0 -ne ${MYEXIT} ] ; then
        MYRETURN=${MYEXIT}
        # Nuclear option
        ( printf "y\n\y\n" | \
            ${DOCKS} kill -e ${ENV} -i ${dock} )
        continue
    fi
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

if [ "enabled" == "${BEASTMODE}" ] ; then
    # still need to loop through orgs and set LC -
    ORGS=$(dockGetOrgs)
    for org in ${ORGS} ; do
        setLaunchConfig ${org}
    done
    KILLBATCH=$(docksGetAll)
    seekAndDestroy ${KILLBATCH}
else
    if [ "" == "${ORG_ID}" ] ; then
        ORGS=$(dockGetOrgs)
    else
        ORGS="${ORG_ID}"
    fi

    for org in ${ORGS} ; do
        # the needful
        setLaunchConfig ${org}
        DESIREDCOUNT=$(getDesiredInstances ${org})
        BATCHSIZE=$(calculateInstanceCountOffset ${DESIREDCOUNT})
        LASTKILLBATCH=""
        KILLBATCH=$(dockGetKillBatch ${org})
        if [ "" != "${KILLBATCH}" ] ; then
            scaleOutDesiredInstances ${org} ${BATCHSIZE}
        else
            continue
        fi
        INTERVAL=300
        LASTNEWINSTANCES=""
        NEWINSTANCES=""
        RETRY=0
        RETRYFAIL=0
        # first loop scales the ASG out and tests for successful instantiation of new docks.
        while [ 1 ] ; do
            hushHushKeepItDownNowVoicesCarry ${INTERVAL}
            INTERVAL=`expr ${INTERVAL} + ${INTERVAL} / 2`
            NEWINSTANCES=$(dockGetNew ${org})
            if [ -z "${NEWINSTANCES}" ] ; then
                if [ ${INTERVAL} -le 1000 ] ; then
                    continue
                fi
            elif [ "${NEWINSTANCES}" == "${LASTNEWINSTANCES}" ] ; then
                # nothin references this yet
                if [ 3 -eq ${RETRY} ] ; then
                    echo "Exceeded maximum wait time for new instance, bailing."
                    exit 1
                else
                    RETRY=`expr ${RETRY} + 1`
                fi
            else
                break
            fi
        done
        INTERVAL=30
        # second loop whiddles down the "kill batch" list until all old instances have fallen off.
        while [ "" != "${KILLBATCH}" ] ; do
            LASTKILLBATCH="${KILLBATCH}"
            if [ "${LASTKILLBATCH}" == "${KILLBATCH}" ] ; then
                # backoff
                hushHushKeepItDownNowVoicesCarry ${INTERVAL}
                INTERVAL=`expr ${INTERVAL} + ${INTERVAL} / 2`
                if [ 120 -le ${INTERVAL} ] ; then
                    echo "Docks termination retry for ${KILLBATCH} exceeded, bailing."
                    exit 1
                fi
            else
                INTERVAL=30
            fi
            seekAndDestroy "${KILLBATCH}"
            hushHushKeepItDownNowVoicesCarry ${INTERVAL}
            KILLBATCH=$(dockGetKillBatch ${org})
        done
        scaleInDesiredInstances ${org} ${BATCHSIZE}
    done
fi
