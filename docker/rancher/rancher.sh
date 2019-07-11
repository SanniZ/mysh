#!/bin/bash
#
# ================================
# Author: Byng.Zeng
# Copyright (C) Byng.Zeng
# ================================

VERSION='1.2.2'

# get real location of rancher.sh
PWD=$(cd `dirname $(readlink -f $0)`; pwd)

USAGE_TIPS=$(cat <<- EOM
===============================================
  usage: rancher COMMAND - $VERSION

  Rancher OS tool
===============================================
Commands:
EOM
)

USAGE_RANCHEROS=$(cat <<- EOM
  -i | install   [n]  : install containers.
  -u | uninstall [n]  : uninstall containers.
  -s | start     [id] : start container.
  -t | stop      [id] : stop container.
  -l | list           : list of containers.
  -a | adb       [id] : connect to adb.
EOM
)

USAGE_UBUNTU=$(cat <<- EOM
  -c | connect  [IP]  : connect to rancherOS.
  -C | CONNECT  [IP]  : push rancher.sh and connect to rancherOS.
EOM
)

# check rancherOS.
# return true if it is rancherOS, other is false.
function check_rancherOS()
{
    if [ ! -z "$(uname -r | grep rancher)"  ]; then
        echo true
    else
        echo false
    fi
}


# connect to rancherOS
function connect_rancher()
{
    if [ !$(check_rancherOS) ]; then
        echo "Connect to $1"
        ssh rancher@$1
    fi
}


# push rancher.sh to rancherOS.
function push_rancher_sh()
{
    if [ !$(check_rancherOS) ]; then
        echo "Push rancher.sh to $1"
        scp $PWD/rancher.sh rancher@$1:/home/rancher
    fi
}


# run ./aic install
function aic_install()
{
    if [ $# -lt 1 ]; then
       ./aic install -d drm
    else
        ./aic install -d drm -n $1
    fi
}


# run ./aic uninstall
function aic_uninstall()
{
    if [ $# -lt 1 ]; then
        ./aic uninstall
	else
	    ./aic uninstall android$1
	fi
}


# run ./aic start
function aic_start()
{
    if [ $# -lt 1 ]; then
        ./aic start
    else
        ./aic start android$1
	fi
}


# run ./aic stop
function aic_stop()
{
    if [ $# -lt 1 ]; then
        ./aic stop
    else
        ./aic stop android$1
	fi
}


# run ./aic list
function aic_list()
{
    ./aic list
}


# create a pseudo-TTY to adb.
function connect_adb()
{
    docker exec -it android$1 sh
}



# print usage help.
function print_usage_help()
{
    echo "$USAGE_TIPS"
    if [ $(check_rancherOS) ]; then
        echo "$USAGE_RANCHEROS"
    else
        echo "$USAGE_UBUNTU"
    fi
}

# rancher default IP address.
rancherIP='10.239.92.135'


if [ $# == 0 ]; then  # No args, print usage help.
    print_usage_help
else
    while [ "$#" -gt 0 ]
    do
        case $1 in
        -h | help)  # print usage help.
            shift
            print_usage_help
        ;;
        -c | connect)  # connect to rancherOS.
            shift
            if [ "$#" -gt 0 ]; then
                rancherIP=rancher@$1
            fi
            shift
            connect_rancher ${rancherIP}
        ;;
        -C | CONNECT)  # push rancher.sh and connect to rancherOS.
            shift
            if [ "$#" -gt 0 ]; then
                rancherIP=$1
            fi
            shift
            push_rancher_sh ${rancherIP}
            connect_rancher ${rancherIP}
        ;;
        -s | start)  # start
            shift
            aic_start $@
        ;;
        -t | stop)  # stop
            shift
            aic_stop $@
        ;;
        -i | install)  # install
            shift
            aic_install $@
        ;;
        -u | uninstall)  # uninstall
            shift
            aic_uninstall $@
        ;;
        -l | list)  # list
            shift
            aic_list
        ;;
        -a | adb)
            shift
            index=0
            if [ "$#" -gt 0 ]; then
                index=$1
            fi
            echo "connect to android${index}"
            connect_adb ${index}
        ;;
        esac
        shift
    done
fi
