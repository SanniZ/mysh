#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-23
# ------------------------------------------------

#set -x

IFS=','

LOCAL_PATH=$(pwd)

opt_rm=false

rm_list=()
rm_list_cnt=0

help_menu=(
	"====================================="
	"    linux command set"
	"====================================="
	"[options]:[rm [file or folder]]"
	"  rm | remove"
	"    remove special string files."
	)

function usage_help() {
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
}

function set_remove_list() {
 	rm_list[$rm_list_cnt]=$1
 	let rm_list_cnt+=1
}

function do_remove_list() {
	for ((i = 0; i < ${rm_list_cnt}; i++))
	do
		rm -rf $LOCAL_PATH/${rm_list[$i]}
	done
}
 
if [ $# == 0 ]; then
	usage_help
else
	for var in $@
	do
		case $var in
		'rm' | 'remove')
			opt_rm=true
		;;
		*)
			if [ $opt_rm == true ]; then
				set_remove_list $var
			else
				usage_help
			fi
		;;
		esac
	done
fi

if [ $opt_rm == true ]; then
	do_remove_list
fi
