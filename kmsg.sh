#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-18
# ------------------------------------------------

#set -x

log_usr=false
log_kmsg=false

function usage_help()
{
	echo "====================================="
	echo "	grep log for kernel"
	echo "====================================="
	echo "[options]: [kmsg] [[usr] [string]] [cmd]"

	echo "	-- fpc, fp:"
	echo "		grep log for fpc or fingerprint"
	echo "	-- kmsg:"
	echo "		cat /pro/kmsg for log"
	echo "	-- trusty:"
	echo "		grep log for trusty"
	echo "	-- usr, user:"
	echo "		grep log for user special string" 
}

function log_grep() {
	if [ $log_kmsg == false ]; then
		reset && adb wait-for-device && adb root && adb shell dmesg | grep -iE --color $1
	else
		reset && adb wait-for-device && adb root && adb shell cat /proc/kmsg | grep -iE --color $1
	fi
}

if [ $# == 0 ]; then
	usage_help
else
	for var in $@
	do
		case $var in
		'fp' | 'fpc')
			log_grep 'fpc|fingerprint'
		;;
		'kmsg')
			log_kmsg=true
		;;
		'usr' | 'user')
			log_usr=true
		;;
		'trusty')
			log_grep 'trusty'
		;;
		*)
			if [ $log_usr == true ]; then
				log_grep $var
			else
				echo "Found invalid args..."
				usage_help
			fi
		;;
		esac	
	done
fi
