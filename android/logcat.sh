#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-28
# ------------------------------------------------

#set -x

IFS=','

help_menu=()

opt_set_menu=(
	'-g:'
	'	save log'
	'-t:'
	'	set grep string'
)

function print_opt_set_enum() {
	IFS=''
	for help in ${opt_set_menu[@]}
	do
		echo ${help}
	done
}

function usage_help() {
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
	print_opt_set_enum
}


log_txt=null
log_file=null


while getopts 'g:ht:' opt
do
	case $opt in
	g)
		log_file=$OPTARG
	;;
	h)
		print_opt_set_enum
		exit
	;;
	t)
		log_txt=$OPTARG
	;;
	esac	
done


if [ ${log_file} == null ]; then
	if [ ${log_txt} == null ]; then
		log.sh -c
	else
		log.sh -c -t ${log_txt}
	fi
else
	if [ ${log_txt} == null ]; then
		log.sh -c -g ${log_file}
	else
		log.sh -c -t ${log_txt} -g ${log_file}
	fi
fi
