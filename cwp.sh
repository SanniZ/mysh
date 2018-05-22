#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-18
# ------------------------------------------------

#set -x

LOCAL_PATH=$(pwd)

FW="pub/ifwi_gr_mrb_b1.bin"
IOC="pub/ioc_firmware_gp_mrb_fab_e.ias_ioc"


function usage_help() {
	echo '--env'
	echo '    setup make env.'
	echo '--f'
	echo '    flash all images.'
	echo '--fd'
	echo '    flash data images.'
	echo '--fw'
	echo '    update firmware'
	echo '--ioc'
	echo '    update ioc'
}

function update_fw() {
	echo 'update firmware...'
	sudo /opt/intel/platformflashtool/bin/ias-spi-programmer --write $LOCAL_PATH/$FW_FILE
}

function update_ioc() {
	echo 'update IOC...'
	sudo /opt/intel/platformflashtool/bin/ioc_flash_server_app -s /dev/ttyUSB2 -grfabc -t $LOCAL_PATH/$IOC
}

function setup_env() {
	make env
}

function flash_all() {
	make flash
}

function flash_data() {
	make flash_data
}


if [ $# == 0 ]; then
	usage_help
else
	for var in $@
		do
			case $var in
			'env')
				setup_env
			;;
			'f')
				flash_all
			;;
			'fd')
				flash_data
			;;
			'fw')
				update_fw
			;;
			'ioc')
				update_ioc
			;;
			*)
				usage_help
			esac
		done
fi
