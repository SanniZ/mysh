#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-18
# ------------------------------------------------

#set -x

IFS=','

LOCAL_PATH=$(pwd)

FW="pub/ifwi_gr_mrb_b1.bin"
IOC="pub/ioc_firmware_gp_mrb_fab_e.ias_ioc"


help_menu=(
	"====================================="
	"    CWP platform command set"
	"====================================="
	'  env'
	'    setup make env.'
	'  f'
	'    flash all images.'
	'  fd'
	'    flash data images.'
	'  fw'
	'    update firmware'
	'  ioc'
	'    update ioc'
	)

function usage_help() {
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
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
