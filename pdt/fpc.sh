#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-18
# ------------------------------------------------

#set -x

IFS=','

LOCAL_PATH=$(pwd)

SSH_URL='ssh://xfeng8-ubuntu2.sh.intel.com:29418/manifests -b master'

help_menu=(
	IFS=','
	"====================================="
	"    fpc extra command set"
	"====================================="
	"[options]:",
	"	bft | build_fpc_test:"
	"		build fpc_tee_test"
	"	fts | fpc_test_s:"
	"		run fpc_tee_test -s"
	"	fte | fpc_test_e:"
	"		run fpc_tee_test -e"
	"	pft | push_fpc_test:"
	"		push fpc_tee_test to /data"
	)

function usage_help() {
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
	pdt.sh help
}


function build_fpc_test()
{
	echo 'start to build fpc_test'
	setup_env
	mmm vendor/intel/hardware/fingerprint/fingerprint_tac/normal
}

function push_fpc_test()
{
	echo 'start to push fpc_tee_test to /data/fpc_tee_test'
	root_device
	adb push out/target/product/gordon_peak/vendor/bin/fpc_tee_test /data/
	adb shell chmod a+x /data/fpc_tee_test
}

function fpc_test()
{
	echo "do fpc_tee_test " $1
	adb shell ./data/fpc_tee_test $1
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


if [ $# == 0 ]; then
	usage_help
else
	# set fpc url
	set_undo_cmd_list -u $SSH_URL

	for var in $@
	do
		case $var in
		'bft' | 'build_fpc_test')
			build_fpc_test
		;;
		'fte' | 'fpc_test_e')
			fpc_test -e
		;;
		'fts' | 'fpc_test_s')
			fpc_test -s
		;;
		'help')
			usage_help
		;;
		'pft' | 'push_fpc_test')
			push_fpc_test
		;;
		'pp' | 'push_patch')
			push_patch
		;;
		*)
			set_undo_cmd_list $var
		;;
		esac
	done

	# call gordonpeak-common
	if [ ${undo_cmd_list} != null ]; then
		pdt.sh ${undo_cmd_list[@]}
	fi
fi
