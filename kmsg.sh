#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-18
# ------------------------------------------------

#set -x

IFS=','

log_usr=false
log_kmsg=false

help_menu=(
	"====================================="
	"	grep log for kernel"
	"====================================="
	"[options]: [kmsg] [[usr] [string]] [cmd]"
	"  fpc | fp:"
	"    grep log for fpc or fingerprint"
	"  kmsg:"
	"    cat /pro/kmsg for log"
	"  trusty:"
	"    grep log for trusty"
	"  usr | user:"
	"    grep log for user special string" 
	)

function usage_help() {
	for ((i=0; i < ${#help_menu[*]}; i++))
	do
		echo ${help_menu[$i]}
	done
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
