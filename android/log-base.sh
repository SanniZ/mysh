#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-18
# ------------------------------------------------

#set -x

IFS=','

log_usr=false

log_type='logcat'
log_txt=null

help_menu=(
	"====================================="
	"	grep log from logcat"
	"====================================="
	"[options]: [[usr] [string]] [cmd]"
	"  all:"
	"    grep log for all"
	"  dmesg:"
	"    adb shell dmesg"
	"  fp | fpc:"
	"    grep log for fpc or fingerprint"
	"  logcat:"
	"    adb logcat"
	"  kmsg:"
	"    cat /pro/kmsg for log"
	"  usr | user:"
	"    grep log for user special string"
	"  trusty:"
	"    grep log for trusty"
	)

function usage_help() {
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
}

function log_grep() {
	reset && adb wait-for-device && adb root

	if [ $log_type == 'logcat' ]; then
		if [ $log_txt == null ]; then
			adb logcat
		else
			adb logcat | grep --color -iE $log_txt
		fi
	elif [ $log_type == 'dmesg' ]; then
		if [ $log_txt == null ]; then
			adb shell dmesg
		else
			adb shell dmesg | grep --color -iE $log_txt
		fi
	elif [ $log_type == 'kmsg' ]; then
		if [ $log_txt == null ]; then
			adb shell cat proc/kmsg
		else
			adb shell cat proc/kmsg | grep --color -iE $log_txt
		fi
	fi
}

if [ $# == 0 ]; then
	usage_help
	exit
else
	for var in $@
	do
		case $var in
		'dmesg')
			log_type='dmesg'
		;;
		'fp' | 'fpc')
			log_txt='fpc|fingerprint'
		;;
		'logcat')
			log_type='logcat'
		;;
		'kmsg')
			log_type='kmsg'
		;;
		'usr' | 'user')
			log_usr=true
		;;
		'trusty')
			log_txt='trusty'
		;;
		*)
			if [ $log_usr == true ]; then
				log_txt=$var
			else
				echo "Found invalid args:" $var
				exit
			fi
		;;
		esac	
	done
fi

log_grep
