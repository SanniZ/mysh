#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-28
# ------------------------------------------------

#set -x

IFS=','

log_type=null
log_txt=null
log_file=null

help_menu=()

opt_set_menu=(
	'-c:'
	'	get logcat log'
	'-d:'
	'	get dmesg log'
	'-g:'
	'	save log'
	'-d:'
	'	get kmsg log'
	'-t:'
	'	set grep string'
)

function print_opt_set_enum() {
	IFS=''
	for help in ${opt_set_menu[@]}
	do
		echo ${help}
	done
}

function usage_help() {
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
	print_opt_set_enum
}

function do_grep_log() {
	# reset screen
	reset
	# waitting for device
	adb wait-for-device
	# root device.
	adb root

	if [ $log_type == 'logcat' ]; then
		if [ ${log_file} == null ]; then
			if [ $log_txt == null ]; then
				adb logcat
			else
				adb logcat | grep --color -iE $log_txt
			fi
		else
			if [ $log_txt == null ]; then
				adb logcat | tee $log_file
			else
				adb logcat | grep --color -iE $log_txt | tee $log_file
			fi
		fi
	elif [ $log_type == 'dmesg' ]; then
		if [ ${log_file} == null ]; then
			if [ $log_txt == null ]; then
				adb shell dmesg
			else
				adb shell dmesg | grep --color -iE $log_txt
			fi
		else
			if [ $log_txt == null ]; then
				adb shell dmesg | tee $log_file
			else
				adb shell dmesg | grep --color -iE $log_txt | tee $log_file
			fi
		fi
	elif [ $log_type == 'kmsg' ]; then
		if [ ${log_file} == null ]; then
			if [ $log_txt == null ]; then
				adb shell cat proc/kmsg
			else
				adb shell cat proc/kmsg | grep --color -iE $log_txt
			fi
		else
			if [ $log_txt == null ]; then
				adb shell cat proc/kmsg | tee $log_file
			else
				adb shell cat proc/kmsg | grep --color -iE $log_txt | tee $log_file
			fi
		fi
	fi
}


if [ $# == 0 ]; then
	usage_help
	exit
else
	while getopts 'cdg:hkt:' opt
	do
		case $opt in
		c)
			log_type='logcat'
		;;
		d)
			log_type='dmesg'
		;;
		g)
			log_file=$OPTARG
		;;
		h)
			print_opt_set_enum
		;;
		k)
			log_type='kmsg'
		;;
		t)
			log_txt=$OPTARG
		;;
		esac	
	done
fi

# do grep log.
if [ ${log_type} != null ]; then
do_grep_log
fi
