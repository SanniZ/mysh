#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-22
# ------------------------------------------------

#set -x

IFS=','

LOCAL_PATH=$(pwd)

adb_tgts=();
adb_tgt_cnt=0;


help_menu=(
	"====================================="
	"    android command set"
	"====================================="
	'  rb | reboot'
	'    adb reboot.'
	'  rbl | reboot_bootloader'
	'    adb reboot bootloader.'
	'  rcv | recovery'
	'    adb reboot recovery.'
	)

function usage_help() {
	for ((i=0; i < ${#help_menu[*]}; i++))
	do
		echo ${help_menu[$i]}
	done
}


function set_adb_tgts() {
	adb_tgts[$adb_tgt_cnt]=$1
	let adb_tgt_cnt=adb_tgt_cnt+1
}

function run_adb_tgts()
{
	echo $adb_tgts
	for ((i=0; i < $adb_tgt_cnt; i++))
	do
		cur_tgt=${adb_tgts[$i]}
		echo 'start to run' $cur_tgt
		adb $cur_tgt
	done

	echo "all of adb targets done!"
}

if [ $# == 0 ]; then
	usage_help
else
	for var in $@
		do
			case $var in
			'rb' | 'reboot')
				set_adb_tgts 'reboot'
			;;
			'rbl' | 'reboot_bootloader')
				set_adb_tgts 'reboot bootloader'
			;;
			'rcv' | 'recovery')
				set_adb_tgts 'recovery'
			;;
			*)
				usage_help
			esac
		done
fi

if [ $adb_tgt_cnt != 0 ]; then
	run_adb_tgts
fi
