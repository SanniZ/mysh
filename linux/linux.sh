#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-28
# ------------------------------------------------

#set -x

IFS=','

LOCAL_PATH=$(pwd)




help_menu=(
	'===================================='
	'    linux command set'
	'===================================='
)

opt_set_menu=(
	'  -r:'
	'    rm files.'
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

opt_rm_tgts=()
opt_rm_tgt_cnt=0

function set_remove_opt() {
 	opt_rm_tgts[$opt_rm_tgt_cnt]=$1
 	let opt_rm_tgt_cnt+=1
}

function do_remove_tgts() {
	for ((i = 0; i < ${opt_rm_tgt_cnt}; i++))
	do
		rm -rf ${opt_rm_tgts[$i]}
	done
}
 
if [ $# == 0 ]; then
	usage_help
else
	while getopts 'hr:' opt
	do
		case $opt in
		h)
			print_opt_set_enum
			exit
		;;
		r)
			set_remove_opt $OPTARG
		;;
		esac
	done
fi

if [ $opt_rm_tgt_cnt != 0 ]; then
	do_remove_tgts
fi
