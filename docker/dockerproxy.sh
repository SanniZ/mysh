#!/bin/bash
#
# Auther   : Byng.Zeng
# Copyright: Byng.Zeng
#
VERSION='1.0.0'

SYSTEMD_DOCKER_PROXY_DIR=/etc/systemd/system/docker.service.d
TEMP_DIR=~/.docker.service.d.tmp #

# copy config files to /etc and restart docker
function update_proxy_config()
{
    #if [ -e ${SYSTEMD_DOCKER_PROXY_DIR} ]; then
    #    sudo rm -rf ${SYSTEMD_DOCKER_PROXY_DIR}
    #fi

    sudo mv ${TEMP_DIR} ${SYSTEMD_DOCKER_PROXY_DIR}

    sudo systemctl daemon-reload
    sudo systemctl restart docker
}


# delete old files.
function pre_config()
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

# create new config files.
function config_proxy()
{
    echo "[Service]" >> ${TEMP_DIR}/http-proxy.conf
    echo "Environment=\"HTTP_PROXY=http://child-prc.intel.com:913/\"" >> ${TEMP_DIR}/http-proxy.conf

    echo "[Service]" >> ${TEMP_DIR}/https-proxy.conf
    echo "Environment=\"HTTPS_PROXY=http://child-prc.intel.com:913/\"" >> ${TEMP_DIR}/https-proxy.conf

    echo "[Service]" >> ${TEMP_DIR}/ftp-proxy.conf
    echo "Environment=\"FTP_PROXY=http://child-prc.intel.com:913/\"" >> ${TEMP_DIR}/ftp-proxy.conf
}

pre_config ${TEMP_DIR}
config_proxy
update_proxy_config
