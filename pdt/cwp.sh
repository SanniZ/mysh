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

opt_build_log=null

opt_set_cnt=0
opt_set_index=0

help_menu=(
	"====================================="
	"    CWP platform command set"
	"====================================="
	'[options]'
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
	pdt.sh help
}


function make_opts() {
	# clear screen
	reset

	if [ $opt_build_log != null ]; then
		if [ -e $opt_build_log ]; then
			mv $opt_build_log ${opt_build_log}.old
		fi
		make $1 2>&1 | tee $opt_build_log
	else
		make $1
	fi
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

opt_set_menu=(
	'-b:'
	'	set build command'
	'-g:'
	'	set build_log=$OPTARG'
)

function print_opt_set_enum() {
	IFS=''
	for help in ${opt_set_menu[@]}
	do
		echo ${help}
	done
}


opt_build_cmd=null


if [ $# == 0 ]; then
	usage_help
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
			opt_build_cmd=$OPTARG
			let opt_set_cnt+=2
		;;
		g)
			opt_build_log=$OPTARG
			let opt_set_cnt+=2
		;;
		h)
			print_opt_set_enum
			let opt_set_cnt+=1
		;;
		esac
	done

	for var in $@
	do
		if [ $opt_set_index -lt $opt_set_cnt ]; then
			let opt_set_index+=1
		else
			case $var in
			'env')
				make_opts 'env'
			;;
			'ba')
				make_opts 'all'
			;;
			'bd')
				make_opts 'sos_dm'
			;;
			'bs')
				make_opts 'sos'
			;;
			'bu')
				make_opts 'uos'
			;;
			'fa')
				make_opts 'flash_all'
			;;
			'fd')
				make_opts 'flash_data'
			;;
			'fs')
				make_opts 'flash_sos'
			;;
			'help')
				usage_help
			;;
			'make')
				make_opts $opt_build_cmd
			;;
			*)
				set_undo_cmd_list $var
			;;
			esac
		fi
	done

	# call gordonpeak-common
	if [ ${undo_cmd_list} != null ]; then
		pdt.sh ${undo_cmd_list[@]}
	fi
fi
