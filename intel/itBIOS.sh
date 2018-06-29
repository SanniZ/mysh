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
	'  fw'
	'    flash firmware'
	'  ioc'
	'    flash ioc'
)

opt_set_menu=(
	'  -f:'
	'	set ifwi file'
	'  -i:'
	'	set ioc file'
)

function print_opt_set_enum() {
	IFS=''
	for set in ${opt_set_menu[@]}
	do
		echo ${set}
	done
}

function usage_help() {
	IFS=''
	for help in ${help_menu[@]}
	do
		echo ${help}
	done
	print_opt_set_enum
}


function show_config_info() {
	echo '=================================='
	echo '  All of config info'
	echo '=================================='
	echo 'FW          :' $FW
	echo 'IOC         :' $IOC
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
		echo "start to flash $tgt"
		if [ $tgt == 'fw' ]; then
			sudo /opt/intel/platformflashtool/bin/ias-spi-programmer --write $FW
		elif [ $tgt == 'ioc' ]; then
			sudo /opt/intel/platformflashtool/bin/ioc_flash_server_app -s /dev/ttyUSB2 -grfabc -t $IOC
		fi
	done
	
	echo 'all of flash are done!!!'
}

index=1
opt_index=$OPTIND

if [ $# == 0 ]; then
	usage_help
	exit
else
	while getopts 'f:i:h' opt
	do
		case $opt in
		f)
			FW=$OPTARG
		;;
		i)
			IOC=$OPTARG
		;;
		h)
			print_opt_set_enum
			exit
		;;
		esac
	done

	for var in $@
	do
		if [ $index -lt $opt_index ]; then #it is opt args, do nothing.
			let index++
		else
			case $var in
			'cfg')
				show_config_info
			;;
			'fw')
				set_flash_tgts 'fw'
			;;
			'help')
				usage_help
				exit
			;;
			'ioc')
				set_flash_tgts 'ioc'
			;;
			*)
				echo "Found unknow cmd: $var"
				exit
			esac
		fi
	done
fi

# set IFS
IFS=' '

if [ $flash_tgt_cnt != 0 ]; then
	do_flash_tgts
fi
