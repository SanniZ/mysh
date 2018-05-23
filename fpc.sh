#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-18
# ------------------------------------------------

#set -x

IFS=','

LOCAL_PATH=$(pwd)

SSH_URL="ssh://xfeng8-ubuntu2.sh.intel.com:29418/manifests -b master"

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

remove_tgts=();
remove_tgt_cnt=0;

help_menu=(
	"====================================="
	"    fpc gordon_peak command set"
	"====================================="
	"[options]:",
	"	ba | flash | flashfiles:"
	"		make flashfiles"
	"	bb | boot | bootimage:"
	"		make bootimage"
	"	bft | build_fpc_test:"
	"		build fpc_tee_test"
	"	bs | sys | system | systemimage:"
	"		make systemimage"
	"	bt | tos | tosimage:"
	"		make tosimage"
	"	bv | vendor | vendorimage:"
	"		make vendorimage"
	"	fw:"
	"		update firmware"
	"	fts | fpc_test_s:"
	"		run fpc_tee_test -s"
	"	fte | fpc_test_e:"
	"		run fpc_tee_test -e"
	"	init:"
	"		repo init and sync source code"
	"	ioc:"
	"		update ioc"
	"	pft | push_fpc_test:"
	"		push fpc_tee_test to /data"
	"	pp | push_patch:"
	"		push patch to gerrit"
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

function usage_help() {
	for help in ${help_menu[@]}
	do
		echo ${help}
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

function push_patch() {
	git push origin HEAD:refs/for/master
}

function setup_env()
{
        device/intel/mixins/mixin-update
        . build/envsetup.sh
        lunch $LUNCH_PRO
        rm -rf out/.lock
}

function set_build_tgts() {
	make_tgts[$make_tgt_cnt]=$1
	let make_tgt_cnt+=1
}

function build_tgts()
{
	#setup_env
	for tgt in ${make_tgts[@]}
	do
		echo 'start to make' $tgt
		make $tgt -j4
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
	
	for tgt in ${update_tgts[@]}
	do
		echo "fastboot flash $tgt $tgt.img now."
		fastboot flash $tgt $FLASHFILES/$tgt.img
	done

	fastboot flash vbmeta $FLASHFILES/vbmeta.img
	fastboot flashing lock
	fastboot reboot

	echo 'make all of targets done!'
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
		'bft' | 'build_fpc_test')
			build_fpc_test
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
		'fte' | 'fpc_test_e')
			fpc_test -e
		;;
		'fts' | 'fpc_test_s')
			fpc_test -s
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
		'pft' | 'push_fpc_test')
			push_fpc_test
		;;
		'pp' | 'push_patch')
			push_patch
		;;
		'ro' | 'rm_out')
			set_remove_tgts out/
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

if [ $make_tgt_cnt != 0 ]; then
	build_tgts
fi

if [ $update_tgt_cnt != 0 ]; then
	update_tgts
fi
