#!/bin/bash
#
# Auther   : Byng.Zeng
# Copyright: Byng.Zeng
#
VERSION='1.0.2'

SYSTEMD_DOCKER_PROXY_DIR=/etc/systemd/system/docker.service.d
TEMP_DIR=~/.docker.service.d.tmp #

# copy config files to /etc and restart docker
function update_proxy_config()
{
    systemctl daemon-reload
    systemctl restart docker

    echo 'Updated proxy for docker service'
}


# clean dirs of config.
function clean_config_dirs()
{
    list=(http-proxy.conf https-proxy.conf ftp-proxy.conf)

    if [ ! -e $1 ]; then
        mkdir $1
    fi

    for f in ${list[@]}
    do
        if [ -e $1/$f ]; then
            rm -rf $1/$f
        fi
    done
}

# remove proxy config files.
function remove_config_files()
{
    if [ -e ${SYSTEMD_DOCKER_PROXY_DIR} ]; then
        sudo rm -rf ${SYSTEMD_DOCKER_PROXY_DIR}
    fi

    echo 'Removed docker proxy config'
}

# create new config files.
function config_proxy()
{
    # remove old temp files.
    clean_config_dirs ${TEMP_DIR}

    # create temp config files.
    echo "[Service]" >> ${TEMP_DIR}/http-proxy.conf
    echo "Environment=\"HTTP_PROXY=http://child-prc.intel.com:913/\"" >> ${TEMP_DIR}/http-proxy.conf
    echo "[Service]" >> ${TEMP_DIR}/https-proxy.conf
    echo "Environment=\"HTTPS_PROXY=http://child-prc.intel.com:913/\"" >> ${TEMP_DIR}/https-proxy.conf
    echo "[Service]" >> ${TEMP_DIR}/ftp-proxy.conf
    echo "Environment=\"FTP_PROXY=http://child-prc.intel.com:913/\"" >> ${TEMP_DIR}/ftp-proxy.conf

    # remove docker proxy config dir.
    if [ -e ${SYSTEMD_DOCKER_PROXY_DIR} ]; then
        sudo rm -rf ${SYSTEMD_DOCKER_PROXY_DIR}
    fi
    # create new proxy config dir and files.
    sudo mv ${TEMP_DIR} ${SYSTEMD_DOCKER_PROXY_DIR}

    echo 'Set proxy for docker service'
}


function usage_help()
{
    USAGE=$(cat <<- EOF
	====================================================
	    Docker Proxy Configuration Tool - $VERSION
	====================================================

	Usage: aic install [OPTIONS]

	Options:
	-c | --config | config:
	    create docker proxy config files.
	-r | --remove | remove:
	    remove docker proxy config files.
	-u | --update | update:
	    update system config of docker service.
	EOF
    )
    echo "$USAGE"
}


# entrance.

if [ $# == 0 ]; then
    usage_help
    exit -1
else
    while [ $# -gt 0 ]
    do
        case $1 in
        -h | --help | help)
            shift
            usage_help
            exit -1
            ;;
        -c | --config | config)
            shift
            config_proxy
            ;;
        -r | --remove | remove)
            shift
            remove_config_files
            ;;
        -u | --update | update)
            shift
            update_proxy_config
            ;;
        *)
            shift
            usage_help
            exit -1
            ;;
        esac
    done
fi
