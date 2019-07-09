#!/bin/bash

# author: Byng.Zeng
# 

VERSION='1.0.0'

DEFAULT_IP=10.239.92.135

function ssh_connect_rancher()
{
    ssh $1
}

function print_usage()
{
    echo '============================================'
    echo "     rancher command set - $VERSION"
    echo '============================================'
    echo '-s IP_adrr: ssh connect to rancher@IP_adrr'
}

if [ $# == 0 ]; then
    print_usage
else
    while [ "$#" -gt 0 ]
    do
        case $1 in
        -h)
            shift
            print_usage
        ;;
        -s | --ssh)
            shift
            if [ "$#" -lt 1 ]; then
                rancher_host=rancher@${DEFAULT_IP}
            else
                rancher_host=rancher@$1
            fi
            shift
            ssh_connect_rancher ${rancher_host}
        ;;
        esac
    done
fi
