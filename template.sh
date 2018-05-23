#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-23
# ------------------------------------------------

#set -x

IFS=','

LOCAL_PATH=$(pwd)

opt_xxx=false

xxx_list=()
xxx_list_cnt=0

help_menu=(
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
}

function set_xxx_list() {
 	xxx_list[$xxx_list_cnt]=$1
 	let xxx_list_cnt+=1
}

function do_xxx_list() {
	for var in ${xxx_list[@]}
	do
		echo ${var}
	done
}
 
if [ $# == 0 ]; then
	usage_help
else
	for var in $@
	do
		case $var in
		'xxx' | 'xxxx')
			opt_xxx=true
		;;
		*)
			if [ $opt_xxx == true ]; then
				set_xxx_list $var
			else
				usage_help
			fi
		;;
		esac
	done
fi

if [ $opt_xxx == true ]; then
	do_xxx_list
fi
