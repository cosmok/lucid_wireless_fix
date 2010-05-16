#!/bin/bash

function printUsage {
    echo "Usage: `basename $0` host-to-ping ssid password cnetworkmanager-path"
}

#if correct number of parameters not passed

if [ $# -lt 2 ]; then
    printUsage
    exit 0
elif [ $# != 4 ]; then
    printUsage
    exit 1
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
# does the executable exist/
if [ ! -f "$cnetpath/cnetworkmanager" ]; then
    echo "cnetworkmanager executable does not exist in the dir $cnetpath"
    exit 1
fi

#check for connectivity after this interval
sleepInterval="1m"
while true; do 
#ping to check connectivity
    ping -i 0.3 -c $count $host 
    #if ping exits with a non-zero status, then no connectivity
    if [[ $? != 0 ]]; then
        # if the executable is already running then, kill it
        pids=`pgrep "cnetworkmanager"`
        for pid in $pids; do
            echo "Killing $pid"
            kill -9 $pid
        done
        echo "`date` Conn dropped, trying to reconnect."
        #just wpa-pass for now, if you need to use wep, change it here
        #run this process in the background and wait for a state change
        "$cnetpath/cnetworkmanager" -C "$ssid" --wpa-pass="$pass" & 
    fi 
    echo "sleeping for $sleepInterval"
    sleep $sleepInterval
done
