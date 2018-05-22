#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-18
# ------------------------------------------------

#set -x

LOCAL_PATH=$(pwd)

SSH_URL="ssh://android.intel.com/manifests -b android/master -m r0"

PRO="gordon_peak"
LUNCH_PRO="$PRO-userdebug"

PRODUCT_OUT=$LOCAL_PATH/out/target/product/$PRO
FLASHFILES=$PRODUCT_OUT/$PRO-flashfiles-eng.yingbin

FW="ifwi_gr_mrb_b1.bin"
IOC="ioc_firmware_gp_mrb_fab_e_slcan.ias_ioc"

make_tgts=();
make_tgt_cnt=0;

update_tgts=();
update_tgt_cnt=0;
	
function usage_help()
{
	echo "[options]"
	echo "	-- ba | flash | flashfiles:"
	echo "		make flashfiles"
	echo "	-- bb | boot | bootimage:"
	echo "		make bootimage"
	echo "	-- bs | sys | system | systemimage:"
	echo "		make systemimage"
	echo "	-- bt | tos | tosimage:"
	echo "		make tosimage"
	echo "	-- bv | vendor | vendorimage:"
	echo "		make vendorimage"
	echo "	-- fw:"
	echo "		update firmware"
	echo "	-- init:"
	echo "		repo init and sync source code"
	echo "	-- ioc:"
	echo "		update ioc"
	echo "	-- ro | rm_out:"
	echo "		rm out folder"
	echo "	-- rk | rm_kernel:"
	echo "		clean obj/kernel"
	echo "	-- rs | rm_soong:"
	echo "		clean out/soong"
	echo "	-- sync:"
	echo "		repo sync source code"
	echo "	-- ub | update_boot:"
	echo "		update bootimage"
	echo "	-- us | update_sys:"
	echo "		update systemimage"
	echo "	-- ut | update_tos:"
	echo "		update tosimage"
	echo "	-- uv | update_vendor:"
	echo "		update vendorimage"

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

function remove_path() {
	echo "start to remove " $1
	rm -rf $1
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

function set_make_tgts() {
	make_tgts[$make_tgt_cnt]=$1
	let make_tgt_cnt+=1

}

function make_images()
{
	setup_env
	for ((i=0; i < $make_tgt_cnt; i++))
	do
		var=${make_tgts[$i]}
		echo 'start to make' $var
		make $var -j4
	done

	echo "make all of targets done!"
}

function set_update_tgts() {
	update_tgts[$update_tgt_cnt]=$1
	let update_tgt_cnt+=1
}

function update_images()
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
			set_make_tgts flashfiles
		;;
		'bb' | 'boot' | 'bootimage')
			set_make_tgts bootimage
		;;
		'bs' | 'sys' | 'system' | 'systemimage')
			set_make_tgts systemimage
		;;
		'bt' | 'tos' | 'tosimage')
			set_make_tgts tosimage
		;;
		'bv' | 'vendor' | 'vendorimage')
			set_make_tgts vendorimage
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
			remove_path out/
		;;
		'rk' | 'rm_kernel')
			remove_path out/target/produce/$PRO/obj/kernel
		;;
		'rs' | 'rm_soong')
			remove_path out/soong
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

if [ $make_tgt_cnt != 0 ]; then
	make_images
fi

if [ $update_tgt_cnt != 0 ]; then
	update_images
fi
