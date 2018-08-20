#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-18
# ------------------------------------------------

#set -x

IFS=','

LOCAL_PATH=$(pwd)

SSH_URL="ssh://android.intel.com/h/hypervisor/manifests -b hypervisor/master"

FW="pub/ifwi_gr_mrb_b1.bin"
IOC="pub/ioc_firmware_gp_mrb_fab_e.ias_ioc"

# CPU=$(cat /proc/cpuinfo| grep "processor"| wc -l)


opt_set_menu=(
	'  -b:'
	'    set build command'
	'  -g:'
	'    set build_log=$OPTARG'
)

function print_opt_set_enum() {
	IFS=''
	for set in ${opt_set_menu[@]}
	do
		echo ${set}
	done
}


help_menu=(
	"====================================="
	"    CWP platform command set"
	"====================================="
	'  env'
	'    setup make env.'
	'  ba'
	'    build all images.'
	'  fa'
	'    flash all images.'
	'  fd'
	'    flash data images.'
)

function usage_help() {
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
	print_opt_set_enum
	pdt.sh help
	pdt.sh -h
}


make_tgts=()
make_tgt_cnt=0

function set_make_tgt() {
	for tgt in $@
	do
		make_tgts[$make_tgt_cnt]=$tgt
		let make_tgt_cnt+=1
	done
}

function do_make_tgts() {
	# clear screen
	reset

	if [ -e ${opt_build_log} ]; then
		mv ${opt_build_log} ${opt_build_log}.old
	fi

	for tgt in ${make_tgts[@]}
	do
		if [ ${opt_build_log} != null ]; then
			make $1 2>&1 | tee ${opt_build_log}
		else
			make $1
		fi
	done
}

undo_cmd_list=null
undo_cmd_cnt=0

function set_undo_cmd_list() {
	for tgt in $@
	do
		undo_cmd_list[$undo_cmd_cnt]=$tgt
		let undo_cmd_cnt+=1
	done
}


opt_build_cmd=null
opt_build_log=null

index=1

if [ $# == 0 ]; then
	usage_help
	exit
else
	# set cwp info
	set_undo_cmd_list -u $SSH_URL
	set_undo_cmd_list -F $FW
	set_undo_cmd_list -I $IOC

	# clear invalid info
	set_undo_cmd_list -L ' '
	set_undo_cmd_list -p ' '
	set_undo_cmd_list -o ' '
	set_undo_cmd_list -O ' '
	set_undo_cmd_list -S ' '

	while getopts "b:g:h" opt
	do
		case $opt in
		b)
			set_make_tgt $OPTARG
		;;
		g)
			opt_build_log=$OPTARG
		;;
		h)
			print_opt_set_enum
			exit
		;;
		esac
	done

	for var in $@
	do
		opt_index=$OPTIND
		if [ $index -lt $opt_index ]; then #it is opt args, do nothing.
			let index++
		else
			case $var in
			'env')
				set_make_tgt 'env'
			;;
			'ba')
				set_make_tgt 'all'
			;;
			'bd')
				set_make_tgt 'sos_dm'
			;;
			'make')
				set_make_tgt 'make'
			;;
			'bs')
				set_make_tgt 'sos'
			;;
			'bu')
				set_make_tgt 'uos'
			;;
			'fa')
				set_make_tgt 'flash_all'
			;;
			'fd')
				set_make_tgt 'flash_data'
			;;
			'fs')
				set_make_tgt 'flash_sos'
			;;
			'help')
				usage_help
				exit
			;;
			*)
				set_undo_cmd_list $var
			;;
			esac
		fi
	done
fi


# call gordonpeak-common
if [ ${undo_cmd_cnt} != 0 ]; then
	pdt.sh ${undo_cmd_list[@]}
fi

if [ ${make_tgt_cnt} != 0 ]; then
	do_make_tgts
fi
