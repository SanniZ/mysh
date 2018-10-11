#!/bin/bash

function config_aria2()
{
	conf="/etc/aria2/aria2.conf"

    if [ -e $conf ]; then
		rm -f $conf
	fi

	echo "#＝＝＝＝＝＝＝＝＝文件保存目录自行修改" >> $conf
	# 根据实际情况修存储位置
	echo "dir=/home/yingbin/Downloads/Aria2" >> $conf
	echo "disable-ipv6=true" >> $conf
	echo "" >> $conf
	echo "#打开rpc的目的是为了给web管理端用" >> $conf
	echo "enable-rpc=true" >> $conf
	echo "rpc-allow-origin-all=true" >> $conf
	echo "rpc-listen-all=true" >> $conf
	echo "#rpc-listen-port=6800" >> $conf
	echo "#断点续传" >> $conf
	echo "continue=true" >> $conf
	echo "input-file=/etc/aria2/aria2.session" >> $conf
	echo "save-session=/etc/aria2/aria2.session" >> $conf
	echo "" >> $conf
	echo "#最大同时下载任务数" >> $conf
	echo "max-concurrent-downloads=20" >> $conf
	echo "" >> $conf
	echo "save-session-interval=120" >> $conf
	echo "" >> $conf
	echo "# Http/FTP 相关" >> $conf
	echo "connect-timeout=120" >> $conf
	echo "#lowest-speed-limit=10K" >> $conf
	echo "#同服务器连接数" >> $conf
	echo "max-connection-per-server=10" >> $conf
	echo "#max-file-not-found=2" >> $conf
	echo "#最小文件分片大小, 下载线程数上限取决于能分出多少片, 对于小文件重要" >> $conf
	echo "min-split-size=10M" >> $conf
	echo "#单文件最大线程数, 路由建议值: 5" >> $conf
	echo "split=10" >> $conf
	echo "check-certificate=false" >> $conf
	echo "#http-no-cache=true" >> $conf
}

function get_aria2_ports()
{
	sudo lsof -i:6800
}

function kill_aria2_port()
{
    sudo kill -9 $1
}

function start_aria2()
{
	sudo aria2c --conf-path=/etc/aria2/aria2.conf
}

function help_menu()
{
	echo "==============================================="
	echo "          Aria2 command set"
	echo "==============================================="
	echo "-h"
	echo "  show help menu"
	echo "-c"
	echo "  config aria2"
	echo "-p"
	echo "  get current TCP ports"
	echo "-k PID"
	echo "  kill TCP port"
	echo "-s"
	echo "  start to run aria2"
}

if [ $# == 0 ]; then
	help_menu
else
	while getopts 'hcpk:s' opt
	do
		case $opt in
		h)
			help_menu
		;;
		c)
			config_aria2
		;;
		p)
			get_aria2_ports
		;;
		k)
			kill_aria2_port $OPTARG
		;;
		s)
			start_aria2
		;;
		esac
	done
fi
