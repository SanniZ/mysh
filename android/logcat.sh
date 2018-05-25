#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-18
# ------------------------------------------------

#set -x

IFS=','

log_usr=false

help_menu=(
	"====================================="
	"	grep log from logcat"
	"====================================="
	"[options]: [[usr] [string]] [cmd]"
	"  all:"
	"    grep log for all"
	"  fp | fpc:"
	"    grep log for fpc or fingerprint"
	"  usr | user:"
	"    grep log for user special string" 
	)

function usage_help() {
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
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
