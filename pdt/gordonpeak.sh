#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-24
# ------------------------------------------------

#set -x

IFS=','

LOCAL_PATH=$(pwd)

help_menu=('')

function usage_help() {
	pdt-common.sh help
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
}

undo_cmd_list=null
undo_cmd_cnt=0

function set_undo_cmd_list() {
	undo_cmd_list[$undo_cmd_cnt]=$@
	let undo_cmd_cnt+=1
}


# main
if [ $# == 0 ]; then
	usage_help
else
	for var in $@
	do
		case $var in
		'help')
			usage_help
		;;
		*)
			set_undo_cmd_list $var
		;;
		esac
	done

	# call gordonpeak-common
	if [ ${undo_cmd_list} != null ]; then
		pdt-common.sh ${undo_cmd_list[@]}
	fi
fi
