#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-22
# ------------------------------------------------

#set -x

IFS=','

LOCAL_PATH=$(pwd)


opt_set_menu=(
	'  -B:'
	'    set adb reboot bootloader'
	'  -c:'
	'    set adb reboot recovery'
	'  -i:'
	'    set fastboot image'
	'  -l:'
	'    set lock and unlock device'
	'  -p:'
	'    set flashfiles path'
	'  -r:'
	'    set reboot'
	'  -R:'
	'    set fastboot reboot'
	'  -w:'
	'    set waitting for device'
)

function print_opt_set_enum() {
	IFS=''
	for set in ${opt_set_menu[@]}
	do
		echo ${set}
	done
}


help_menu=(
	'===================================='
	'    fastboot command set'
	'===================================='
)

function usage_help() {
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
	print_opt_set_enum
}

adb_tgts=();
adb_tgt_cnt=0;

fastboot_tgts=();
fastboot_tgt_cnt=0;

function set_adb_tgts() {
	adb_tgts[$adb_tgt_cnt]=$1
	let adb_tgt_cnt+=1
}

function do_adb_tgts()
{
	for tgt in ${adb_tgts[@]}
	do
		if [ $tgt == 'wait' ]; then
			echo 'waitting for device...'
			adb wait-for-device
		else
			echo 'adb' ${tgt}
			adb ${tgt}
		fi
	done
}

opt_fastboot_lock=null

function do_fastboot_lock() {
	if [ ${opt_fastboot_lock} == 'unlock' ]; then
		echo 'unlock device!'
		opt_fastboot_lock='lock'
		fastboot flashing unlock
	elif [ ${opt_fastboot_lock} == 'lock' ]; then
		echo 'lock device!'
		opt_fastboot_lock=null
		fastboot flashing lock
	fi
}


function set_fastboot_tgts() {
	fastboot_tgts[$fastboot_tgt_cnt]=$1
	let fastboot_tgt_cnt+=1
}

function do_fastboot_tgts()
{
	# unlock device
	do_fastboot_lock

	for tgt in ${fastboot_tgts[@]}
	do
		if [ $tgt == 'reboot' ]; then
			fastboot reboot
		else
			tgt_img=${tgt}.img
			echo "fastboot ${tgt} ${flashfiles_path}/${tgt_img}"
			fastboot flash ${tgt} ${flashfiles_path}/${tgt_img}
		fi
	done

	# lock device
	do_fastboot_lock

	echo "all of fastboot targets done!"
}

flashfiles_path=null
fastboot_image=null

index=1
opt_index=$OPTIND

if [ $# == 0 ]; then
	usage_help
	exit
else
	while getopts 'Bchi:lp:rRw' opt
	do
		case $opt in
		B)
			set_adb_tgts 'reboot bootloader'
		;;
		c)
			set_adb_tgts 'reboot recovery'
		;;
		h)
			print_opt_set_enum
		;;
		i)
			set_fastboot_tgts $OPTARG
		;;
		l)
			opt_fastboot_lock='unlock'
		;;
		p)
			flashfiles_path=$OPTARG
		;;
		r)
			set_adb_tgts 'reboot'
		;;
		R)
			set_fastboot_tgts 'reboot'
		;;
		w)
			set_adb_tgts 'wait'
		;;
		esac
	done

	for var in $@
	do
		if [ $index -lt $opt_index ]; then #it is opt args, do nothing.
			let index++
		else
			case $var in
			help)
				usage_help
				exit
			;;
			*)
				echo "Found unknown cmd: $var"
				exit
			;;
			esac
		fi
	done
fi

if [ ${adb_tgt_cnt} != 0 ]; then
	do_adb_tgts
fi

if [ ${fastboot_tgt_cnt} != 0 ]; then
	do_fastboot_tgts
fi
