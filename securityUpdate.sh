#!/bin/bash


#############
# Functions #
#############

log () {
    if [[ $VERBOSE -eq 1 ]]; then
        echo -e "$@"
    fi

    date +"[%d-%m-%Y %H:%M:%S] $@" >> $LOGFILE
}

usage() {
cat << EOF
Tool for Security Patch Management.

Usage: $0 [options]

OPTIONS:
    -h      Display help
    -v      Be verbose
    -u      Update & Download only Security updates
    -f      Force Security Upgrade
    -s      Safe Security Upgrade (ask host server before, need to define --host and --port)
    -i      Ignore package during upgrade whose name contains one of this param, separated with ',' or '|' or ' '. Example : "mysql,apache"
    -l      Log file (Default : /var/log/securityUpgrades.log)
    -r      Host asked for sage upgrade
    -p      Remote host's port
EOF
}

check_pm () {
    ret=1

    # We ask $PM_HOST if we can launch security upgrade
    # If 0 we don't launch security upgrades
    # If pm is unreachable we don't take into consideration the pm server
    retpm=$(sleep 1 | telnet $PM_HOST $PM_PORT | tail -n 1)

    if [[ $retpm =~ ^-?[0-9]+$ ]] && [ "$retpm" -eq 0 ]
    then
        log "> Server $PM_HOST advice to don't apply upgrades"
        ret=0
    else
        log "> Server $PM_HOST advice to apply upgrade or is unreachable"
    fi

    return $ret
}

update () {
    log "> Execute Update && Download-Only"

    if [ "$DistroBase" = "Debian" ]
    then
        log "Update and download only packages"
        apt-get update && apt-get upgrade -y --download-only
    fi
}

upgrade () {

    log "> Execute Security Upgrade"
    # Execute Security Upgrade

    if [ "$DistroBase" = "Debian" ]
    then

        upgrade_list_full=$(DEBIAN_FRONTEND=noninteractive apt-get upgrade -s | grep -i -e '^Inst.*Security' | awk -F ' ' '{print $2}' )

        if [ -n "$IGNORE_PACKAGES" ]
        then
            upgrade_list=$(echo "$upgrade_list_full" | grep -Evi "$IGNORE_PACKAGES" | tr '\n' ' ' )
        else
            upgrade_list=$(echo "$upgrade_list_full" | tr '\n' ' ' )
        fi

        log "Security Upgrade - Install packages : $upgrade_list"

        DEBIAN_FRONTEND=noninteractive apt-get install -q -y --only-upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" $upgrade_list

    elif [ "$DistroBase" = "RedHat" ]
    then
        # Need to install yum-security before and update-minimal
        # Check if yum-security is installed
        yum list installed yum-plugin-security >/dev/null 2>&1

        if [ "$?" -ne 0 ]
        then
            log "Install Yum-Security"
            yum install yum-security
        fi

        log "Security Upgrade - Install security packages"
        yum update-minimal --security -y
    else
        log "Security Upgrade - Unsupported Operating System"
    fi

}

#############
# Variables #
#############

LOGFILE='/var/log/securityUpgrades.log'
PM_HOST=''
PM_PORT=''

UPDATE=0
FORCE_UPGRADE=0
SAFE_UPGRADE=0
VERBOSE=0
IGNORE_PACKAGES_PARAM=''
IGNORE_PACKAGES=''

OS=$(uname)

if [ "${OS}" = "Linux" ] ; then
    if [ -f /etc/debian_version ] ; then
        DistroBase='Debian'
    elif [ -f /etc/redhat-release ] ; then
        DistroBase='RedHat'
    fi
fi


# Retrive parameters

while getopts "hufsvi:r:p:l:" OPTION
do
    case $OPTION in
        h)
            usage
            exit 0
            ;;
        u)
            UPDATE=1
            ;;
        f)
            FORCE_UPGRADE=1
            ;;
        s)
            SAFE_UPGRADE=1
            ;;
        v)
            VERBOSE=1
            ;;
        i)
            IGNORE_PACKAGES_PARAM=$OPTARG
            ;;
        r)
            PM_HOST=$OPTARG
            ;;
        p)
            PM_PORT=$OPTARG
            ;;
        l)
            LOGFILE=$OPTARG
            ;;
     esac
done


# Enable Verbose mode

if [ "$1" = "-v" ]
then
    VERBOSE=1
fi


# Ignore package

if [ -n $IGNORE_PACKAGE_PARAM ]
then
    IGNORE_PACKAGES=$(echo "$IGNORE_PACKAGES_PARAM" | sed 's/[, ]/\|/g')
fi


########
# Core #
########

log "Security Patch Management Tool. Verbose mode.\n"

log "Run :\n"

if [ "$UPDATE" -eq 1 ]
then

    update

elif [ "$FORCE_UPGRADE" -eq 1 ]
then

    upgrade

elif [ "$SAFE_UPGRADE" -eq 1 ]
then

    if [ ! -z "$PM_HOST" ] && [ ! -z "$PM_PORT" ]
    then

        if ! check_pm
        then
            upgrade
        else
            log "Server $PM_HOST advice to don't apply upgrades. Don't do anything"
        fi
    else
        echo "Error : you should define host (-r) and port (-p) to use safe upgrade"
    fi

else
    usage
fi

exit 0
