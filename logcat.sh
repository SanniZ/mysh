#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-18
# ------------------------------------------------

#set -x

log_usr=false

function usage_help()
{
	echo "====================================="
	echo "	grep log from logcat"
	echo "====================================="
	echo "[options]: [[usr] [string]] [cmd]"

	echo "	-- all:"
	echo "		grep log for all"
	echo "	-- fp, fpc:"
	echo "		grep log for fpc or fingerprint"
	echo "	-- usr, user:"
	echo "		grep log for user special string" 
}

function log_grep() {
	if [ $1 == 'all' ]; then
		reset && adb wait-for-device && adb root && adb logcat
	else
		reset && adb wait-for-device && adb root && adb logcat | grep -iE --color $1
	fi
}

if [ $# == 0 ]; then
	usage_help
else
	for var in $@
	do
		case $var in
		'all')
			log_grep all
		;;
		'fp' | 'fpc')
			log_grep 'fpc|fingerprint'
		;;
		'usr' | 'user')
			log_usr=true
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
