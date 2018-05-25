#!/bin/bash

# ------------------------------------------------
#  Author: Byng.Zeng
#  Date:   2018-05-25
# ------------------------------------------------

#set -x

IFS=','

LOCAL_PATH=$(pwd)

FW="pub/ifwi_gr_mrb_b1.bin"
IOC="pub/ioc_firmware_gp_mrb_fab_e.ias_ioc"


help_menu=(
	"====================================="
	"    Intel platform command set"
	"====================================="
	'  ffw'
	'    flash firmware'
	'  fioc'
	'    flash ioc'
	'  fw'
	'    config firmware.'
	'  ioc'
	'    config ioc'
	)

function usage_help() {
	IFS=''
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
}

update_config_set=null

function show_config_info() {
	echo '=================================='
	echo '  All of config info'
	echo '=================================='
	echo 'FW          :' $FW
	echo 'IOC         :' $IOC
}

update_config_set=null

function update_config_set() {
	if [ $update_config_set == 'fw' ]; then
		FW=$1
	elif [ $update_config_set == 'ioc' ]; then
		IOC=$1
	fi

	update_config_set=null
}

flash_tgts=()
flash_tgt_cnt=0

function set_flash_tgts() {
	flash_tgts[$flash_tgt_cnt]=$1
	let flash_tgt_cnt+=1
}

function do_flash_tgts() {
	for tgt in ${flash_tgts[@]}
	do
		echo 'start to flash' $tgt
		if [ $tgt == 'fw' ]; then
			sudo /opt/intel/platformflashtool/bin/ias-spi-programmer --write $FW
		elif [ $tgt == 'ioc' ]; then
			sudo /opt/intel/platformflashtool/bin/ioc_flash_server_app -s /dev/ttyUSB2 -grfabc -t $IOC
		fi
	done
	
	echo 'all of flash are done!!!'
}



if [ $# == 0 ]; then
	usage_help
else
	for var in $@
		do
			case $var in
			'cfg')
				show_config_info
			;;
			'ffw')
				set_flash_tgts 'fw'
			;;
			'fioc')
				set_flash_tgts 'ioc'
			;;
			'fw')
				update_config_set='fw'
			;;
			'ioc')
				update_config_set='ioc'
			;;
			*)
				if [ $update_config_set != null ]; then
					update_config_set $var
				else
					echo "Found unknow cmd($var) and return..."
					exit
				fi
			esac
		done
fi

# set IFS
IFS=' '

if [ $flash_tgt_cnt != 0 ]; then
	do_flash_tgts
fi
