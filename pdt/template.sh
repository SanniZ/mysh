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
	"[options]:[rm [file or folder]]"
	"  xxx | xxxx"
	"    xxxxxxxxx."
	)

function usage_help() {
	for help in ${help_menu[@]}
	do
		echo $help
	done
	pdt-common.sh help
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

if [ $# == 0 ]; then
	usage_help
else
	for var in $@
	do
		case $var in
		'xxx' | 'xxxx')
			set_xxx_tgts 'xxx'
		;;
		*)
			set_undo_cmd_tgts $var
		;;
		esac
	done
	
	if [ $xxx_list_cnt != 0 ]; then
		do_xxx_tgts
	fi
	
	# call gordonpeak-common
	if [ ${undo_cmd_list} != null ]; then
		pdt-common.sh ${undo_cmd_list[@]}
	fi
fi
