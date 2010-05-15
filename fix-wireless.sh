#!/bin/bash

function printUsage {
    echo "Usage: fix-wireless.sh host-to-ping ssid password cnetworkmanager-path"
}

#if correct number of parameters not passed
if [ $1 = '' -o $2 = '' -o $3 = '' -o $4 = '' ]; then
    printUsage
    echo $1 
    echo $2 
    echo $3 
    echo $4
    exit 1
fi

if [ $1 = '--help'  -o $1 = '-h' ]; then
    printUsage
    exit 0
fi

# add ip / hostname that you want to ping for connectivity check( for e.g., google.com)
host=$1 
#how many pings
count=1

#wireless network name
ssid=$2 
#password for the above network
pass=$3 

#directory containing the cnetworkmanager executable
cnetpath=$4

#check for connectivity after this interval
sleepInterval="30m"
while true; do 
#ping to check connectivity
    ping -i 0.3 -c $count $host 
    #if ping exits with a non-zero status, then no connectivity
    if [[ $? != 0 ]]; then
        # does the executable exist/
        if [ ! -f "$cnetpath/cnetworkmanager" ]; then
            echo "cnetworkmanager executable does not exist in the dir $cnetpath"
            exit 1
        fi
        # if the executable is already running then, kill it
        pids=`pgrep "cnetworkmanager"`
        for pid in $pids; do
            kill -9 $pid
        done
        echo `date` Conn dropped, trying to reconnect.
        #just wpa-pass for now, if you need to use wep, change it here
        "$cnetpath/cnetworkmanager" -C "$ssid" --wpa-pass="$pass" 
    else 
       #all good
       sleep $sleepInterval
    fi
done
