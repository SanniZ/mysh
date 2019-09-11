#!/bin/bash

# Author : Byng.Zeng
# Copyright (C) Byng.Zeng

VERSION=1.0.0

function adb_connect() {
    adb connect $1:5555
}

function adb_disconnect() {
    adb disconnect $adb_tcp_ip
}

function adb_kill() {
    adb kill-server
}

function adb_get_tcp_port() {
    echo $adb_tcp_ip
}

function usage_help()
{
    USAGE=$(cat <<- EOF
	----------------------------------------
	  adb Tool - $VERSION
	----------------------------------------
	Options:
	  -c | connect:
	    run adb connect.
	  -d | disconnect:
	    run adb disconnet.
	  -k | kill:
	    kill adb
	  -t | tcp:
	    get adb tcp IP
	EOF
    )
    echo "$USAGE"
}

if [ $# == 0 ]; then
    usage_help
else
	while [ $# -gt 0 ]
	do
	    case $1 in
	    -c | connect)
	        shift
	        if [ -z $adb_tcp_ip ]; then
		        echo "run 'export adb_tcp_ip=xxx' to set adb tcp IP"
		    else
	            adb_connect $adb_tcp_ip
	        fi
	    ;;
	    -d | disconnect)
	        shift
	        if [ $adb_tcp_ip ]; then
	            adb_disconnect $adb_tcp_ip
	        fi
	    ;;
	    -k | kill)
	        shift
	        adb_kill
	    ;;
	    -t | tcp)
	        shift
	        adb_get_tcp_port
	    ;;
	    *)
	        usage_help
	        exit
	    esac
	done
fi
