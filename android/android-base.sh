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

fastboot_tgts=();
fastboot_tgt_cnt=0;

help_menu=(
	"====================================="
	"    android command set"
	"====================================="
	'  fb | fastboot_reboot'
	'    fastboot reboot.'
	'  rb | reboot'
	'    adb reboot.'
	'  rbl | reboot_bootloader'
	'    adb reboot bootloader.'
	'  rcv | recovery'
	'    adb reboot recovery.'
	)

function usage_help() {
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
}


function set_adb_tgts() {
	adb_tgts[$adb_tgt_cnt]=$1
	let adb_tgt_cnt+=1
}

function do_adb_tgts()
{
	echo $adb_tgts
	for tgt in ${adb_tgts[@]}
	do
		echo 'start to run' ${tgt}
		adb ${tgt}
	done

	echo "all of adb targets done!"
}

function set_fastboot_tgts() {
	fastboot_tgts[$fastboot_tgt_cnt]=$1
	let fastboot_tgt_cnt+=1
}

function do_fastboot_tgts()
{
	echo $fastboot_tgts
	for tgt in ${fastboot_tgts[@]}
	do
		echo 'start to fastboot' ${tgt}
		fastboot ${tgt}
	done

	echo "all of fastboot targets done!"
}

if [ $# == 0 ]; then
	usage_help
else
	for var in $@
		do
			case $var in
			'fb' | 'fastboot_reboot')
				set_fastboot_tgts 'reboot'
			;;
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
	do_adb_tgts
fi

if [ $fastboot_tgt_cnt != 0 ]; then
	do_fastboot_tgts
fi
