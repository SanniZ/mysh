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

FW="ifwi_gr_mrb_b1.bin"
IOC="ioc_firmware_gp_mrb_fab_e_slcan.ias_ioc"


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
	"	fw:"
	"		update firmware"
	"	init:"
	"		repo init and sync source code"
	"	ioc:"
	"		update ioc"
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

update_config_set=null

build_mmm_path=null

function update_config_set() {
	if [ $update_config_set == 'url' ]; then
		SSH_URL=$1
	elif [ $update_config_set == 'pdt' ]; then
		PDT=$1
	elif [ $update_config_set == 'mmm' ]; then
		build_mmm_path=$1
		set_build_tgts mmm
	fi

	update_config_set=null
}

code_tgts=()
code_tgt_cnt=0

function set_code_tgts() {
	code_tgts[$code_tgt_cnt]=$1
	let code_tgt_cnt+=1
}

function do_code_tgts() {
	for tgt in ${code_tgts[@]}
	do
		if [ $tgt == 'init' ]; then
			echo "start to init and sync source code........"
			repo init -u $SSH_URL
			repo sync -j5
		elif [ $tgt == 'sync' ]; then
			echo "start to sync source code........"
			repo sync -j5
		fi
	done
	
	echo 'all of code done!!!'
}

remove_tgts=()
remove_tgt_cnt=0

function set_remove_tgts() {
	remove_tgts[$remove_tgt_cnt]=$1
	let remove_tgt_cnt+=1
}

function do_remove_tgts() {
	for tgt in ${remove_tgts[@]}
	do
		echo 'start to rm' $tgt
		rm -rf $tgt
	done
	
	echo 'all of remove are removed!!!'
}

bios_tgts=()
bios_tgt_cnt=0

function set_bios_tgts() {
	bios_tgts[$bios_tgt_cnt]=$1
	let bios_tgt_cnt+=1
}

function do_bios_tgts() {
	for tgt in ${bios_tgts[@]}
	do
		if [ $tgt == 'ifw' ]; then
			echo 'update firmware...'
			sudo /opt/intel/platformflashtool/bin/ias-spi-programmer --write $FLASHFILES/$FW
		elif [ $tgt == 'ioc' ]; then
			echo 'update IOC...'
			sudo /opt/intel/platformflashtool/bin/ioc_flash_server_app -s /dev/ttyUSB2 -grfabc -t $FLASHFILES/$IOC
		fi
	done
	
	echo "all of bios is done!"
}

function setup_env()
{
        device/intel/mixins/mixin-update
        . build/envsetup.sh
        lunch $LUNCH_PDT
}

build_tgts=()
build_tgt_cnt=0

function set_build_tgts() {
	build_tgts[$build_tgt_cnt]=$1
	let build_tgt_cnt+=1
}

function do_build_tgts()
{
	setup_env
	rm -rf out/.lock
	for tgt in ${build_tgts[@]}
	do
		if [ $tgt == 'mmm' ]; then
			mmm $build_mmm_path
		elif [ $tgt == 'mm' ]; then
			mm
		else
			echo 'start to make' $tgt
			make $tgt -j4
		fi
	done

	echo "all of make done!"
}

update_tgts=()
update_tgt_cnt=0

function set_update_tgts() {
	update_tgts[$update_tgt_cnt]=$1
	let update_tgt_cnt+=1
}

function do_update_tgts()
{
	avbtool=out/host/linux-x86/bin/avbtool
	TEST_KEY_PATH=external/avb/test/data

	for tgt in ${update_tgts[@]}
	do
		echo "start to rebuild $tgt.img"

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
	
	for tgt in ${update_tgts[@]}; do
		echo "fastboot flash $tgt $tgt.img now."
		fastboot flash $tgt $FLASHFILES/$tgt.img
	done

	fastboot flash vbmeta $FLASHFILES/vbmeta.img
	fastboot flashing lock
	fastboot reboot

	echo 'all of update done!'
}

function do_build_mmm_tgts() {
	set_build_tgts mmm
}

function root_device()
{
	adb wait-for-device
	adb root
	adb wait-for-device
}




if [ $# == 0 ]; then
	usage_help
else
	for var in $@
	do
		case $var in
		'ba' | 'flash' | 'flashfiles')
			set_build_tgts 'flashfiles'
		;;
		'bb' | 'boot' | 'bootimage')
			set_build_tgts 'bootimage'
		;;
		'bs' | 'sys' | 'system' | 'systemimage')
			set_build_tgts 'systemimage'
		;;
		'bt' | 'tos' | 'tosimage')
			set_build_tgts 'tosimage'
		;;
		'bv' | 'vendor' | 'vendorimage')
			set_build_tgts 'vendorimage'
		;;
		'cfg')
			show_config_info
		;;
		'fw')
			set_bios_tgts 'ifw'
		;;
		'help')
			usage_help
		;;
		'init')
			set_code_tgts 'init'
		;;
		'ioc')
			set_bios_tgts 'ioc'
		;;
		'mm')
			set_build_tgts 'mm'
		;;
		'mmm')
			update_config_set='mmm'
		;;
		'pdt')
			update_config_set='pdt'
		;;
		'ro' | 'rm_out')
			set_remove_tgts out/
		;;
		'rk' | 'rm_kernel')
			set_remove_tgts out/target/produce/$PDT/obj/kernel
		;;
		'rs' | 'rm_soong')
			set_remove_tgts out/soong
		;;
		'sync')
			set_code_tgts 'sync'
		;;
		'ub' | 'update_boot')
			set_update_tgts boot
		;;
		'url')
			update_config_set='url'
		;;
		'us' | 'update_sys')
			set_update_tgts system
		;;
		'ut' | 'update_tos')
			set_update_tgts tos
		;;
		'uv' | 'update_vendor')
			set_update_tgts vendor
		;;
		*)
			if [ $update_config_set != null ]; then
				update_config_set $var
			else
				echo "Found unknow cmd($var) and return..."
				exit
			fi
		;;
		esac
	done
fi

IFS=' '

if [ $bios_tgt_cnt != 0 ]; then
	do_bios_tgts
fi

if [ $code_tgt_cnt != 0 ]; then
	do_code_tgts
fi

if [ $remove_tgt_cnt != 0 ]; then
	do_remove_tgts
fi

if [ $build_tgt_cnt != 0 ]; then
	do_build_tgts
fi

if [ $update_tgt_cnt != 0 ]; then
	do_update_tgts
fi
