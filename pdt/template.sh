#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-23
# ------------------------------------------------

#set -x

IFS=','

LOCAL_PATH=$(pwd)

help_menu=(
	IFS=','
	"====================================="
	"    xxx command set"
	"====================================="
	"  xxx | xxxx"
	"    xxxxxxxxx."
)

opt_set_menu=(
	'  -x:'
	'    xxx.'
)

function print_opt_set_enum() {
	IFS=''
	for set in ${opt_set_menu[@]}
	do
		echo ${set}
	done
}

function usage_help() {
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
	print_opt_set_enum
}

function usage_help() {
	for help in ${help_menu[@]}
	do
		echo $help
	done
	pdt.sh help
}

undo_cmd_list=null
undo_cmd_cnt=0

function set_undo_cmd_list() {
	undo_cmd_list[$undo_cmd_cnt]=$@
	let undo_cmd_cnt+=1
}


xxx_tgts=()
xxx_tgt_cnt=0

function set_xxx_tgts() {
 	xxx_tgts[$xxx_tgt_cnt]=$1
 	let xxx_tgt_cnt+=1
}

function do_xxx_tgts() {
	for tgt in ${xxx_tgt[@]}
	do
		echo ${tgt}
	done
}

opt_set_cnt=0
opt_set_index=0

if [ $# == 0 ]; then
	usage_help
else
	while getopts 'xx:' opt
	do
		case $opt in
		h)
			print_opt_set_enum
			exit
		;;
		x)
			xxx $OPTARG
			let opt_set_index+=2
		;;
		esac
	done

	for var in $@
	do
		if [ ${opt_set_index} -lt ${opt_set_cnt} ]; then
			let opt_set_index+=1
		else
			case $var in
			'xxx' | 'xxxx')
				set_xxx_tgts 'xxx'
			;;
			*)
				set_undo_cmd_tgts $var
			;;
			esac
		fi
	done
fi

# call gordonpeak-common
if [ ${undo_cmd_list} != null ]; then
	pdt.sh ${undo_cmd_list[@]}
fi

if [ $xxx_list_cnt != 0 ]; then
	do_xxx_tgts
fi
