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


function push_fpc_test()
{
	echo 'start to push fpc_tee_test to /data/fpc_tee_test'
	root_device
	adb push out/target/product/gordon_peak/vendor/bin/fpc_tee_test /data/
	adb shell chmod a+x /data/fpc_tee_test
}

function fpc_test()
{
	echo "do fpc_tee_test $1"
	adb shell ./data/fpc_tee_test $1
}

fpc_tgts=()
fpc_tgt_cnt=0

function set_fpc_tgt() {
	for tgt in $@
	do
		fpc_tgts[$fpc_tgt_cnt]=$tgt
		let fpc_tgt_cnt+=1
	done
}

function do_fpc_tgts() {
	# clear screen
	#reset

	for tgt in ${fpc_tgts[@]}
	do
		if [ $tgt == 'build_test' ]; then
			build_fpc_test
		elif [ $tgt == 'test_e' ]; then
			fpc_test -e
		elif [ $tgt == 'test_s' ]; then
			fpc_test -s
		elif [ $tgt == 'push_test' ]; then
			push_fpc_test
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


if [ $# == 0 ]; then
	usage_help
else
	# set fpc url
	set_undo_cmd_list -u $SSH_URL

	for var in $@
	do
		case $var in
		'bt' | 'build_test')
			set_undo_cmd_list -m 'vendor/intel/hardware/fingerprint/fingerprint_tac/normal' mmm
		;;
		'te' | 'test_e')
			set_fpc_tgt 'test_e'
		;;
		'ts' | 'test_s')
			set_fpc_tgt 'test_s'
		;;
		'help')
			usage_help
		;;
		'pt' | 'push_test')
			set_fpc_tgt 'push_test'
		;;
		*)
			set_undo_cmd_list $var
		;;
		esac
	done
fi

# call gordonpeak-common
if [ ${undo_cmd_list} != null ]; then
	pdt.sh ${undo_cmd_list[@]}
fi

fi [ ${fpc_tgt_cnt} != 0 ]; then
	do_fpc_tgts
fi
