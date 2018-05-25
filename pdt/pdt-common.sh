#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-25
# ------------------------------------------------

#set -x

IFS=','

LOCAL_PATH=$(pwd)

SSH_URL="ssh://android.intel.com/manifests -b android/master -m r0"

PDT="gordon_peak"
OPT="userdebug"
LUNCH_PDT="$PDT-$OPT"

USER="yingbin"

PRODUCT_OUT=/out/target/product/$PDT
FLASHFILES=$PRODUCT_OUT/$PDT-flashfiles-eng.$USER

FW="$FLASHFILES/ifwi_gr_mrb_b1.bin"
IOC="$FLASHFILES/ioc_firmware_gp_mrb_fab_e_slcan.ias_ioc"


help_menu=(
	"====================================="
	"    gordon_peak common command set"
	"====================================="
	"[options]"
	"	ba | flash | flashfiles:"
	"		make flashfiles"
	"	bb | boot | bootimage:"
	"		make bootimage"
	"	bs | sys | system | systemimage:"
	"		make systemimage"
	"	bt | tos | tosimage:"
	"		make tosimage"
	"	bv | vendor | vendorimage:"
	"		make vendorimage"
	"	ffw:"
	"		update firmware"
	"	ffs:"
	"		set path of flashfiles file"
	"	fioc:"
	"		update ioc"
	"	init:"
	"		repo init and sync source code"
	"	mmm:"
	"		mmm make dir"
	"	pdt:"
	"		set product"
	"	ro | rm_out:"
	"		rm out folder"
	"	rk | rm_kernel:"
	"		clean obj/kernel"
	"	rs | rm_soong:"
	"		clean out/soong"
	"	sync:"
	"		repo sync source code"
	"	ub | update_boot:"
	"		update bootimage"
	"	url:"
	"		ssh url path to pull source code"
	"	us | update_sys:"
	"		update systemimage"
	"	ut | update_tos:"
	"		update tosimage"
	"	uv | update_vendor:"
	"		update vendorimage"
	)

function usage_help() {
	IFS=''
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
}

function show_config_info() {
	echo '=================================='
	echo '  All of config info'
	echo '=================================='
	echo 'SSH URL     :' $SSH_URL
	echo 'PDT         :' $PDT
	echo 'OPT         :' $OPT
	echo 'LUNCH_PDT   :' $LUNCH_PDT
	echo 'USER        :' $USER
	echo 'PRODUCT_OUT :' $PRODUCT_OUT
	echo 'FLASHFILES  :' $FLASHFILES
	echo 'FW          :' $FW
	echo 'IOC         :' $IOC
}

set_opt_args_pending=null

function set_opt_args() {
	if [ $set_opt_args_pending == 'url' ]; then
		SSH_URL=$1
	elif [ $set_opt_args_pending == 'pdt' ]; then
		PDT=$1
		LUNCH_PDT="$PDT-$OPT"
		PRODUCT_OUT=/out/target/product/$PDT
		FLASHFILES=$PRODUCT_OUT/$PDT-flashfiles-eng.$USER
		FW="$FLASHFILES/ifwi_gr_mrb_b1.bin"
		IOC="$FLASHFILES/ioc_firmware_gp_mrb_fab_e_slcan.ias_ioc"
	elif [ $set_opt_args_pending == 'opt' ]; then
		OPT=$1
		LUNCH_PDT="$PDT-$OPT"
	elif [ $set_opt_args_pending == 'mmm' ]; then
		set_opt_tgts 'mmm' $1
	elif [ $set_opt_args_pending == 'fw' ]; then
		FW=$1
	elif [ $set_opt_args_pending == 'ioc' ]; then
		IOC=$1
	elif [ $set_opt_args_pending == 'ffs' ]; then
		FLASHFILES=$1
	fi

	set_opt_args_pending=null
}

function setup_env()
{
        device/intel/mixins/mixin-update
        . build/envsetup.sh
        lunch $LUNCH_PDT
}

function do_bios_tgts() {
	for tgt in $@
	do
		if [ $tgt == 'fw' ]; then
			echo 'update firmware...'
			sudo /opt/intel/platformflashtool/bin/ias-spi-programmer --write $FW
		elif [ $tgt == 'ioc' ]; then
			echo 'update IOC...'
			sudo /opt/intel/platformflashtool/bin/ioc_flash_server_app -s /dev/ttyUSB2 -grfabc -t $IOC
		fi
	done
}


function do_build_tgts()
{
	setup_env
	rm -rf out/.lock
	for tgt in $@
	do
		if [ $tgt == 'mmm' ]; then
			build_pending='mmm'
		elif [ $build_pending == 'mmm' ]; then
			build_pending=null
			echo 'mmm ' $tgt
			mmm $tgt
		else
			echo 'make' $tgt
			make $tgt -j4
		fi
	done
}

function do_code_tgts() {
	for tgt in $@
	do
		if [ $tgt == 'init' ]; then
			echo "init and sync source code........"
			repo init -u $SSH_URL
		elif [ $tgt == 'sync' ]; then
			echo "sync source code........"
			repo sync -j5
		fi
	done
}

function do_remove_tgts() {
	for tgt in $@
	do
		echo 'rm' $tgt
		rm -rf $tgt
	done
}


function do_update_tgts()
{
	avbtool=out/host/linux-x86/bin/avbtool
	TEST_KEY_PATH=external/avb/test/data

	for tgt in $@
	do
		echo "make_vbmeta_image $tgt.img"

		cp $PRODUCT_OUT/$tgt.img $FLASHFILES/$tgt.img

		$avbtool make_vbmeta_image --output $FLASHFILES/vbmeta.img \
			--include_descriptors_from_image $FLASHFILES/boot.img \
			--include_descriptors_from_image $FLASHFILES/system.img \
			--include_descriptors_from_image $FLASHFILES/vendor.img \
			--include_descriptors_from_image $FLASHFILES/tos.img \
			--key $TEST_KEY_PATH/testkey_rsa4096.pem --algorithm SHA256_RSA4096
	done
	
	adb wait-for-device
	adb reboot bootloader
	fastboot flashing unlock
	
	for tgt in $@
	do
		echo "fastboot flash $tgt $tgt.img"
		fastboot flash $tgt $FLASHFILES/$tgt.img
	done

	fastboot flash vbmeta $FLASHFILES/vbmeta.img
	fastboot flashing lock
	fastboot reboot
}




opt_tgts=()
opt_tgt_cnt=0
opt_tgt_pending=null

function set_opt_tgts() {
	for tgt in $@
	do
		opt_tgts[$opt_tgt_cnt]=$tgt
		let opt_tgt_cnt+=1
	done
}

function do_opt_tgts() {
	for tgt in ${opt_tgts[@]}
	do
		case $tgt in
		'build')
			opt_tgt_pending='build'
		;;
		'cfg')
			show_config_info
		;;
		'ffw')
			do_bios_tgts 'fw'
		;;
		'fioc')
			do_bios_tgts 'ioc'
		;;
		'help')
			usage_help
		;;
		'init')
			do_code_tgts 'init' 'sync'
		;;
		'mmm')
			opt_tgt_pending='mmm'
		;;
		'rm')
			opt_tgt_pending='rm'
		;;
		'sync')
			do_code_tgts 'sync'
		;;
		'update')
			opt_tgt_pending='update'
		;;
		*)
			case  $opt_tgt_pending in
			'build')
				do_build_tgts $tgt
			;;
			'mmm')
				do_build_tgts 'mmm' $tgt
			;;
			'rm')
				do_remove_tgts $tgt
			;;
			'update')
				do_update_tgts $tgt
			;;
			*)
				echo 'Found unknown pending opt:' $opt_tgt_pending
			;;
			esac
			opt_tgt_pending=null
		;;
		esac
	done
	
	echo 'all of opt done!!!'
}

function root_device()
{
	adb wait-for-device
	adb root
	adb wait-for-device
}


#=======================================
# main entry
#=======================================
if [ $# == 0 ]; then
	usage_help
else
	for var in $@
	do
		case $var in
		'ba' | 'flash' | 'flashfiles')
			set_opt_tgts 'build' 'flashfiles'
		;;
		'bb' | 'boot' | 'bootimage')
			set_opt_tgts 'build' 'bootimage'
		;;
		'bs' | 'sys' | 'system' | 'systemimage')
			set_opt_tgts 'build' 'systemimage'
		;;
		'bt' | 'tos' | 'tosimage')
			set_opt_tgts 'build' 'tosimage'
		;;
		'bv' | 'vendor' | 'vendorimage')
			set_opt_tgts 'build' 'vendorimage'
		;;
		'cfg')
			set_opt_tgts 'cfg'
		;;
		'ffw')
			set_opt_tgts 'ffw'
		;;
		'ffs')
			set_opt_args_pending='ffs'
		;;
		'fioc')
			set_opt_tgts 'fioc'
		;;
		'fw')
			set_opt_args_pending='fw'
		;;
		'help')
			set_opt_tgts 'help'
		;;
		'init')
			set_opt_tgts 'init'
		;;
		'ioc')
			set_opt_args_pending='ioc'
		;;
		'mmm')
			set_opt_args_pending='mmm'
		;;
		'pdt')
			set_opt_args_pending='pdt'
		;;
		'ro' | 'rm_out')
			set_opt_tgts 'rm' 'out/'
		;;
		'rk' | 'rm_kernel')
			set_opt_tgts 'rm' "out/target/produce/$PDT/obj/kernel"
		;;
		'rs' | 'rm_soong')
			set_opt_tgts 'rm' 'out/soong'
		;;
		'sync')
			set_opt_tgts 'sync'
		;;
		'ub' | 'update_boot')
			set_update_tgts 'update' 'boot'
		;;
		'url')
			set_opt_args_pending='url'
		;;
		'us' | 'update_sys')
			set_opt_tgts 'update' 'system'
		;;
		'ut' | 'update_tos')
			set_opt_tgts 'update' 'tos'
		;;
		'uv' | 'update_vendor')
			set_opt_tgts 'update' 'vendor'
		;;
		*)
			if [ $set_opt_args_pending != null ]; then
				set_opt_args $var
			else
				echo "Found unknown cmd($var) and return..."
				exit
			fi
		;;
		esac
	done
fi

#set IFS
IFS=' '

if [ $opt_tgt_cnt != 0 ]; then
	do_opt_tgts
fi
