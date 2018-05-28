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

PRODUCT_OUT=out/target/product/$PDT
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

help_tgts=()
help_tgt_cnt=0

function set_help_tgt() {
	for tgt in $@
	do
		help_tgts[$help_tgt_cnt]=$tgt
		let help_tgt_cnt+=1
	done
}

function do_help_tgts() {
	for tgt in ${help_tgts[@]}
	do
		if [ $tgt == 'help' ]; then
			usage_help
		elif [ $tgt == 'cfg' ]; then
			show_config_info
		fi
	done
}

default_set_tgts=()
default_set_tgt_cnt=0

function set_default_tgt() {
	for tgt in $@
	do
		default_set_tgts[$default_set_tgt_cnt]=$tgt
		let default_set_tgt_cnt+=1
	done
}

function update_default_set() {
	pending_set=null
	for tgt in ${default_set_tgts[@]}
	do
		if [ $pending_set == null ]; then
			pending_set=$tgt
		else
			case $pending_set in
			'url')
				SSH_URL=$tgt
			;;
			'pdt')
				PDT=$tgt
				LUNCH_PDT="$PDT-$OPT"
				PRODUCT_OUT=/out/target/product/$PDT
				FLASHFILES=$PRODUCT_OUT/$PDT-flashfiles-eng.$USER
				FW="$FLASHFILES/ifwi_gr_mrb_b1.bin"
				IOC="$FLASHFILES/ioc_firmware_gp_mrb_fab_e_slcan.ias_ioc"
			;;
			'opt')
				OPT=$tgt
				LUNCH_PDT="$PDT-$OPT"
			;;
			'fw')
				FW=$FLASHFILES/$tgt
			;;
			'ioc')
				IOC=$FLASHFILES/$tgt
			;;
			'ffs')
				FLASHFILES=$tgt
			;;
			esac
			pending_set=null
		fi
	done
}

function setup_env()
{
        device/intel/mixins/mixin-update
        . build/envsetup.sh
        lunch $LUNCH_PDT
}

bios_tgts=()
bios_tgt_cnt=0

function set_bios_tgt() {
	for tgt in $@
	do
		bios_tgts[$bios_tgt_cnt]=$tgt
		let bios_tgt_cnt+=1
	done
}

function do_bios_tgts() {
	for tgt in ${bios_tgts[@]}
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

build_tgts=()
build_tgt_cnt=0
build_pending=null

function set_build_tgt() {
	for tgt in $@
	do
		build_tgts[$build_tgt_cnt]=$tgt
		let build_tgt_cnt+=1
	done
}

function do_build_tgts()
{
	setup_env
	rm -rf out/.lock
	for tgt in ${build_tgts[@]}
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

code_tgts=()
code_tgt_cnt=0

function set_code_tgt() {
	for tgt in $@
	do
		code_tgts[$code_tgt_cnt]=$tgt
		let code_tgt_cnt+=1
	done
}

function do_code_tgts() {
	for tgt in ${code_tgts[@]}
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

remove_tgts=()
remove_tgt_cnt=0

function set_remove_tgt() {
	for tgt in $@
	do
		remove_tgts[$remove_tgt_cnt]=$tgt
		let remove_tgt_cnt+=1
	done
}

function do_remove_tgts() {
	for tgt in ${remove_tgts[@]}
	do
		echo 'rm' $tgt
		rm -rf $tgt
	done
}


function root_device()
{
	adb wait-for-device
	adb root
	adb wait-for-device
}


update_tgts=()
update_tgt_cnt=0

function set_update_tgt() {
	for tgt in $@
	do
		update_tgts[$update_tgt_cnt]=$tgt
		let update_tgt_cnt+=1
	done
}

function do_update_tgts()
{
	avbtool=out/host/linux-x86/bin/avbtool
	TEST_KEY_PATH=external/avb/test/data

	for tgt in ${update_tgts[@]}
	do
		echo "make_vbmeta_image: $tgt.img"

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
	
	for tgt in ${update_tgts[@]}
	do
		echo "fastboot flash $tgt $tgt.img"
		fastboot flash $tgt $FLASHFILES/$tgt.img
	done

	fastboot flash vbmeta $FLASHFILES/vbmeta.img
	fastboot flashing lock
	fastboot reboot
}




pending_tgt=null

function do_pending_tgts() {
	if [ $pending_tgt == 'mmm' ]; then
		set_build_tgt $1 $2
	else
		set_default_tgt $1 $2
	fi
	
	pending_tgt=null
}


#=======================================
# main entry
#     Check all of args.
#     do nothing if found invalid args.
#=======================================
if [ $# == 0 ]; then
	usage_help
	exit
else
	for var in $@
	do
		case $var in
		'ba' | 'flash' | 'flashfiles')
			set_build_tgt 'flashfiles'
		;;
		'bb' | 'boot' | 'bootimage')
			set_build_tgt 'bootimage'
		;;
		'bs' | 'sys' | 'system' | 'systemimage')
			set_build_tgt 'systemimage'
		;;
		'bt' | 'tos' | 'tosimage')
			set_build_tgt 'tosimage'
		;;
		'bv' | 'vendor' | 'vendorimage')
			set_build_tgt 'vendorimage'
		;;
		'cfg')
			set_help_tgt 'cfg'
		;;
		'ffw')
			set_bios_tgt 'fw'
		;;
		'ffs')
			pending_tgt='ffs'
		;;
		'fioc')
			set_bios_tgt 'ioc'
		;;
		'fw')
			pending_tgt='fw'
		;;
		'help')
			set_help_tgt 'help'
		;;
		'init')
			set_code_tgt 'init'
		;;
		'ioc')
			pending_tgt='ioc'
		;;
		'mmm')
			pending_tgt='mmm'
		;;
		'pdt')
			pending_tgt='pdt'
		;;
		'ro' | 'rm_out')
			set_remove_tgt 'rm' 'out/'
		;;
		'rk' | 'rm_kernel')
			set_remove_tgt 'rm' "out/target/produce/$PDT/obj/kernel"
		;;
		'rs' | 'rm_soong')
			set_remove_tgt 'rm' 'out/soong'
		;;
		'sync')
			set_code_tgt 'sync'
		;;
		'ub' | 'update_boot')
			set_update_tgt 'boot'
		;;
		'url')
			pending_tgt='url'
		;;
		'us' | 'update_sys')
			set_update_tgt 'system'
		;;
		'ut' | 'update_tos')
			set_update_tgt 'tos'
		;;
		'uv' | 'update_vendor')
			set_update_tgt 'vendor'
		;;
		*)
			if [ $pending_tgt != null ]; then
				do_pending_tgts $pending_tgt $var
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

# do options
if [ $default_set_tgt_cnt != 0 ]; then
	update_default_set
fi

if [ $help_tgt_cnt != 0 ]; then
	do_help_tgts
fi

if [ $bios_tgt_cnt != 0 ]; then
	do_bios_tgts
fi

if [ $remove_tgt_cnt != 0 ]; then
	do_remove_tgts
fi

if [ $code_tgt_cnt != 0 ]; then
	do_code_tgts
fi

if [ $build_tgt_cnt != 0 ]; then
	do_build_tgts
fi

if [ $update_tgt_cnt != 0 ]; then
	do_update_tgts
fi
