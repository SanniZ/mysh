#!/bin/bash

# ------------------------------------------------
#  Author: Byng Zeng
#  Date:   2018-11-09
# ------------------------------------------------

#set -x

path_of_patch=none
path_of_code=none
path_of_prebuild=none
opt_for_patch=none

function help_menu()
{
	echo '===================================='
	echo '    FPC prebuild file patch set'
	echo '===================================='
	echo '-a'
	echo '  apply all of patches'
	echo '-g'
	echo '  get all of prebuild files'
	echo '-c xxx'
	echo '  xxx: root path of source code'
	echo '  if it is not set, default set to current path.'
echo '-p xxx'
	echo '  xxx: root path of patches'
	echo '-f xxx'
	echo '  xxx: root path of store prebuild files'
	echo '  if it is not set, default set to current path.'
}

# dirs of fingerprint patch.
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
		# path of patch and source code.
		p_patch=$path_of_patch/$dir
		p_code=$path_of_code/$dir
		if [[ -d $p_code  && -d $p_patch ]]; then
			echo "apply patch at: $p_code"
			# enter dir of source code
			cd $p_code
			# apply all of .patch under dir.
			git am $p_patch/*.patch
			echo ''
		else
			echo "Error, invalid path(source:$p_code patch:$p_patch) please check it"
			break
		fi
	done
}

# all of prebuild file.
files_of_prebuild=(
'system/etc/permissions/android.hardware.fingerprint.xml'
'system/framework/android.hardware.biometrics.fingerprint-V2.1-java.jar'
'system/framework/com.fingerprints.extension-V1.0-java.jar'
'system/framework/com.fingerprints.fmi.jar'
'system/framework/oat/x86/android.hardware.biometrics.fingerprint-V2.1-java.odex'
'system/framework/oat/x86/android.hardware.biometrics.fingerprint-V2.1-java.vdex'
'system/framework/oat/x86/com.fingerprints.extension-V1.0-java.odex'
'system/framework/oat/x86/com.fingerprints.extension-V1.0-java.vdex'
'system/framework/oat/x86_64/android.hardware.biometrics.fingerprint-V2.1-java.odex'
'system/framework/oat/x86_64/android.hardware.biometrics.fingerprint-V2.1-java.vdex'
'system/framework/oat/x86_64/com.fingerprints.extension-V1.0-java.odex'
'system/framework/oat/x86_64/com.fingerprints.extension-V1.0-java.vdex'
'system/lib/android.hardware.biometrics.fingerprint@2.1.so'
'system/lib/com.fingerprints.extension@1.0.so'
'system/lib/vndk/android.hardware.biometrics.fingerprint@2.1.so'
'system/lib/vndk/com.fingerprints.extension@1.0.so'
'system/lib64/android.hardware.biometrics.fingerprint@2.1.so'
'system/lib64/com.fingerprints.extension@1.0.so'
'system/lib64/vndk/android.hardware.biometrics.fingerprint@2.1.so'
'system/lib64/vndk/com.fingerprints.extension@1.0.so'
'vendor/bin/hw/android.hardware.biometrics.fpcfingerprint@2.1-service'
'vendor/etc/init/android.hardware.biometrics.fpcfingerprint@2.1-service.rc'
'vendor/etc/permissions/com.fingerprints.extension.xml'
'vendor/framework/com.fingerprints.extension.jar'
'vendor/lib/hw/com.fingerprints.extension@1.0-impl.so'
'vendor/lib64/hw/com.fingerprints.extension@1.0-impl.so'
)

function get_prebuild_files()
{
	for f in ${files_of_prebuild[@]}
	do
		if [ -e $path_of_prebuild/$f ]; then
			# get dir and create it.
			dir=${f%/*}
			mkdir -p $path_of_patch/$dir
			# copy file to output file.
			cp $path_of_prebuild/$f $path_of_patch/$dir
		else
			echo "Error, no found $path_of_prebuild/$f, please check it"
			break
		fi
	done
}

if [ $# == 0 ]; then 
	help_menu
else
	while getopts 'agc:f:p:' opt
	do
		case $opt in
		a)
			opt_for_patch='apply'
		;;
		g)
			opt_for_patch='get-prebuild'
		;;
		c)
			path_of_code=${OPTARG%*/}
		;;
		f)
			path_of_prebuild=${OPTARG%*/}
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

if [ $opt_for_patch != none ]; then
	# run apply patch
	if [[ $path_of_patch != none && $opt_for_patch == 'apply' ]]; then
		if [ $path_of_code == none ]; then
			path_of_code=$(pwd)
		fi

		git_apply_patch
	fi

	# run get prebuild file.
	if [[ $path_of_patch != none && $opt_for_patch == 'get-prebuild' ]]; then
		if [ $path_of_prebuild == none ]; then
			path_of_prebuild=$(pwd)
		fi

		get_prebuild_files
	fi
else
	echo 'Error, please input your option!'
	echo ''
	help_menu
fi