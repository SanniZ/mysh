#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-18
# ------------------------------------------------

#set -x

IFS=','

LOCAL_PATH=$(pwd)

SSH_URL="ssh://android.intel.com/manifests -b android/master -m r0"

PRO="gordon_peak_acrn"
LUNCH_PRO="$PRO-userdebug"

PRODUCT_OUT=$LOCAL_PATH/out/target/product/$PRO
FLASHFILES=$PRODUCT_OUT/$PRO-flashfiles-eng.yingbin

FW="ifwi_gr_mrb_b1.bin"
IOC="ioc_firmware_gp_mrb_fab_e_slcan.ias_ioc"

build_tgts=();
build_tgt_cnt=0;

update_tgts=();
update_tgt_cnt=0;

remove_tgts=();
remove_tgt_cnt=0;

help_menu=(
	"====================================="
	"    gordon_peak_acrn command set"
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
	"	us | update_sys:"
	"		update systemimage"
	"	ut | update_tos:"
	"		update tosimage"
	"	uv | update_vendor:"
	"		update vendorimage"
	)

function usage_help()
{
	for ((i=0; i < ${#help_menu[*]}; i++))
	do
		echo ${help_menu[$i]}
	done
}

function create_source_code() {
	echo "start to init and sync source code........"
	repo init -u $SSH_URL
	repo sync -j5
}

function sync_source_code() {
	echo "start to sync source code........"
	repo sync -j5
}

function set_remove_tgts() {
	remove_tgts[$remove_tgt_cnt]=$1
	let remove_tgt_cnt+=1
}

function remove_tgts() {
	echo 'do remove tgts'
	for tgt in ${remove_tgts[@]}
	do
		echo 'start to rm' $tgt
		rm -rf $tgt
	done
	
	echo 'all of targets are removed!!!'
}

function update_fw() {
	echo 'update firmware...'
	sudo /opt/intel/platformflashtool/bin/ias-spi-programmer --write $FLASHFILES/$FW
}

function update_ioc() {
	echo 'update IOC...'
	sudo /opt/intel/platformflashtool/bin/ioc_flash_server_app -s /dev/ttyUSB2 -grfabc -t $FLASHFILES/$IOC
}

function setup_env()
{
        device/intel/mixins/mixin-update
        . build/envsetup.sh
        lunch $LUNCH_PRO
        rm -rf out/.lock
}

function set_build_tgts() {
	build_tgts[$build_tgt_cnt]=$1
	let build_tgt_cnt+=1

}

function build_tgts()
{
	setup_env
	for ((i=0; i < $build_tgt_cnt; i++))
	do
		var=${build_tgts[$i]}
		echo 'start to make' $var
		make $var -j4
	done

	echo "make all of targets done!"
}

function set_update_tgts() {
	update_tgts[$update_tgt_cnt]=$1
	let update_tgt_cnt+=1
}

function update_tgts()
{
	avbtool=out/host/linux-x86/bin/avbtool
	TEST_KEY_PATH=external/avb/test/data

	for ((i=0; i < $update_tgt_cnt; i++))
	do
		var=${update_tgts[$i]}
		echo "start to rebuild $var.img"

		cp $PRODUCT_OUT/$var.img $FLASHFILES/$var.img

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
	
	for var in ${update_tgts[@]}; do
		echo "fastboot flash $var $var.img now."
		fastboot flash $var $FLASHFILES/$var.img
	done

	fastboot flash vbmeta $FLASHFILES/vbmeta.img
	fastboot flashing lock
	fastboot reboot

	echo 'make all of targets done!'
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
			set_build_tgts flashfiles
		;;
		'bb' | 'boot' | 'bootimage')
			set_build_tgts bootimage
		;;
		'bs' | 'sys' | 'system' | 'systemimage')
			set_build_tgts systemimage
		;;
		'bt' | 'tos' | 'tosimage')
			set_build_tgts tosimage
		;;
		'bv' | 'vendor' | 'vendorimage')
			set_build_tgts vendorimage
		;;
		'fw')
			update_fw
		;;
		'help')
			usage_help
		;;
		'init')
			create_source_code
		;;
		'ioc')
			update_ioc
		;;
		'ro' | 'rm_out')
			rset_remove_tgts out/
		;;
		'rk' | 'rm_kernel')
			set_remove_tgts out/target/produce/$PRO/obj/kernel
		;;
		'rs' | 'rm_soong')
			set_remove_tgts out/soong
		;;
		'sync')
			sync_source_code
		;;
		'ub' | 'update_boot')
			set_update_tgts boot
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
			echo "Found invalid args..."
			usage_help
		;;
		esac
	done
fi

if [ $remove_tgt_cnt != 0 ]; then
	remove_tgts
fi

if [ $build_tgt_cnt != 0 ]; then
	build_tgts
fi

if [ $update_tgt_cnt != 0 ]; then
	update_tgts
fi
