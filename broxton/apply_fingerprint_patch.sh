#!/bin/bash

path_of_patch=none
path_of_code=none

function help_menu()
{
	echo '===================================='
	echo '    apply patch of fingerprint'
	echo '===================================='
	echo '-c:'
	echo '  path of source code'
	echo '-p:'
	echo '  path of patches'
}

dirs_of_patch=(
'device/intel/mixins'
'device/intel/sepolicy'
'kernel/bxt'
'kernel/config-lts/v4.9'
'packages/services/Car'
'trusty/app/sand'
'trusty/app/keymaster'
'trusty/device/x86/sand'
'trusty/lk/trusty'
'trusty/platform/sand'
'vendor/intel/fw/evmm'
'vendor/intel/hardware/fingerprint'
'vendor/intel/hardware/storage'
)

function git_apply_patch()
{
	for dir in ${dirs_of_patch[@]}
	do
		p_patch=$path_of_patch/$dir
		p_code=$path_of_code/$dir
		cd $p_code
		git am $p_patch/*.patch
	done
}

if [ $# == 0 ]; then 
	help_menu
else
	while getopts 'c:p:' opt
	do
		case $opt in
		c)
			path_of_code=${OPTARG%*/}
		;;
		p)
			path_of_patch=${OPTARG%*/}
		;;
		*)
			help_menu
			exit
		;;
		esac
	done
fi

if [[ $path_of_patch != none && $path_of_code != none ]]; then
	git_apply_patch
else
	help_menu
fi
