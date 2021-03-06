#!/bin/bash
#
# Auther   : Byng.Zeng
# Copyright: Byng.Zeng
#

VERSION=1.0.1


#############################################
# Functions
#############################################

# install docker to ubuntu host.
function install_docker()
{
    USAGE=$(cat <<- EOF

	    usage: docker install [options]

	    Options:
	      -a | --apt | apt:
	        run 'sudo apt-get install docker'
	EOF
    )

    if [ $# -gt 0 ]; then
        while [ $# -gt 0 ];
        do
            case $1 in
            -a | --apt | apt)
                shift
                DOCKER='docker docker-compose docker.io docker-registry'

                read -p "Confirm to install docker [Y/n]:" opt
                opt=$(echo ${opt} | tr '[a-z]' '[A-Z]')
                if [[ ${opt} == 'Y' ]]; then
                    sudo apt-get install $DOCKER -y
                fi
                ;;
            *)
                echo ${USAGE}
                exit -1
            esac
        done
    else
        wget -qO- https://get.docker.com/ | sh
    fi

    echo "Installed docker to host."
}

# remove docker from ubuntu host
function uninstall_docker()
{
    DOCKER='docker docker-compose docker.io docker-registry'

    read -p "Confirm to remove docker [Y/n]:" opt
    opt=$(echo ${opt} | tr '[a-z]' '[A-Z]')
    if [[ ${opt} == 'Y' ]]; then
        sudo apt-get autoremove $DOCKER -y
        echo "Removed docker from host."
    fi
}


function config_docker_daemon()
{
    daemon_dns="{\"dns\":[\"10.248.2.5\",\"10.239.27.236\",\"172.17.6.9\"]}"
    daemon_tmp=.daemon.json.tmp
    daemon_json=/etc/docker/daemon.json

    if [ -e $daemon_tmp ]; then
        rm -rf $daemon_tmp
    fi
    echo ${daemon_dns} >> ${daemon_tmp}

    if [ -e ${daemon_json} ]; then
        sudo mv ${daemon_json} ${daemon_json}.old
    fi

    sudo mv ${daemon_tmp} ${daemon_json}
}

SYSTEMD_DOCKER_PROXY_DIR=/etc/systemd/system/docker.service.d
TEMP_DOCKER_PROXY_DIR=~/.docker.service.d.tmp #

function update_docker_proxy()
{
    sudo systemctl daemon-reload
    sudo systemctl restart docker.service
}

# remove proxy config files.
function remove_docker_proxy()
{
    if [ -e ${SYSTEMD_DOCKER_PROXY_DIR} ]; then
        sudo rm -rf ${SYSTEMD_DOCKER_PROXY_DIR}
    fi
}

# config proxy for docker.
function config_docker_proxy()
{
    list=(http-proxy.conf https-proxy.conf ftp-proxy.conf)

    # remove old temp files.
    if [ ! -e ${TEMP_DOCKER_PROXY_DIR} ]; then
        mkdir ${TEMP_DOCKER_PROXY_DIR}
    fi
    for f in ${list[@]}
    do
        if [ -e ${TEMP_DOCKER_PROXY_DIR}/$f ]; then
            rm -rf ${TEMP_DOCKER_PROXY_DIR}/$f
        fi
    done

    # create temp config files.
    echo "[Service]" >> ${TEMP_DOCKER_PROXY_DIR}/http-proxy.conf
    echo "Environment=\"HTTP_PROXY=http://child-prc.intel.com:913\" \"NO_PROXY=localhost,127.0.0.1,localaddress,.localdomain.com,10.*,192.168.*,*.intel.com\"" >> ${TEMP_DOCKER_PROXY_DIR}/http-proxy.conf
    echo "[Service]" >> ${TEMP_DOCKER_PROXY_DIR}/https-proxy.conf
    echo "Environment=\"HTTPS_PROXY=http://child-prc.intel.com:913\" \"NO_PROXY=localhost,127.0.0.1,localaddress,.localdomain.com,10.*,192.168.*,*.intel.com\"" >> ${TEMP_DOCKER_PROXY_DIR}/https-proxy.conf
    echo "[Service]" >> ${TEMP_DOCKER_PROXY_DIR}/ftp-proxy.conf
    echo "Environment=\"FTP_PROXY=http://child-prc.intel.com:913\" \"NO_PROXY=localhost,127.0.0.1,localaddress,.localdomain.com,10.*,192.168.*,*.intel.com\"" >> ${TEMP_DOCKER_PROXY_DIR}/ftp-proxy.conf

    # remove docker proxy config dir.
    if [ -e ${SYSTEMD_DOCKER_PROXY_DIR} ]; then
        sudo rm -rf ${SYSTEMD_DOCKER_PROXY_DIR}
    fi
    # create new proxy config dir and files.
    sudo mv ${TEMP_DOCKER_PROXY_DIR} ${SYSTEMD_DOCKER_PROXY_DIR}
}

# config docker
function docker_proxy()
{
    USAGE=$(cat <<- EOF

	  usage: docker -c options

	Options:
	  -c | --config | config :  install proxy of docker.
	  -r | --remove | remove :  remove  proxy of docker.
	  -u | --update | update :  update  proxy of docker.
	EOF
    )

    if [ $# == 0 ]; then
        echo "${USAGE}"
        exit -1
    else
        while [ $# -gt 0 ]
        do
            case $1 in
            -c | --config | config)
                shift
                config_docker_proxy
                echo 'Installed proxy of docker'
                ;;
            -r | --remove | remove)
                shift
                remove_docker_proxy
                echo 'Removed proxy of docker'
                ;;
           -u | --update | update)
                update_docker_proxy
                ;;
            *)
                echo "${USAGE}"
                exit -1
                ;;
            esac
        done
    fi
}

# list images of docker.
function list_image()
{
    echo "$(docker image list)"
}

#remove image of docker
function remove_image()
{
    rc=()
    Reps=()
    Tags=()
    Ids=()
    Opt=$1
    OptArg=0

    USAGE=$(cat <<- EOF

	usage: docker -r [Options]

	Options:
	  -a | --all | all
	    remove all of images.
	  -n | --name | name   xxx:
	    remove xxx name of image.
	  -d | --id | id       xxx:
	    remove xxx Image ID of image.
	EOF
    )

    if [ $# == 0 ]; then  # no args.
        echo "${USAGE}"
        exit -1
    else
        while [ $# -gt 0 ]
        do
            case $1 in
            -n | --name | name)  # search by name of Repository
                shift
                if [ $# -lt 1 ]; then  # no args.
                    echo "${USAGE}"
                    exit -1
                else  # get name.
                    OptArg=$1
                    rc=2
                    shift
                fi
                ;;
            -d | --id | id)  # search by id of image
                shift
                if [ $# -lt 1 ]; then  # no args.
                    echo "${USAGE}"
                    exit -1
                else  # get id.
                    OptArg=$1
                    rc=2
                    shift
                fi
                ;;
           -a | --all | all)  # search all of images.
                shift
                rc=1
                ;;
            *)
                echo "${USAGE}"
                exit -1
                ;;
            esac
        done
    fi

    # get all of Reps, Tags and Ids.
    IMGS=$(docker image list)
    Reps+=($(echo "${IMGS}"  | awk '{print $1}'))
    Tags+=($(echo "${IMGS}" | awk '{print $2}'))
    Ids+=($(echo "${IMGS}"  | awk '{print $3}'))

    # remove images.
    for index in $(seq $(expr ${#Reps[@]} - 1))
    do
        if [[ ${Opt} == '-n' ]]; then  # search by name.
            if [ ${Reps[$index]} != ${OptArg} ]; then
                continue
            fi
        elif [[ ${Opt} == '-d' ]]; then  # search by id.
            if [[ ${Ids[$index]} != ${OptArg} ]]; then
                continue

            fi
        fi
        # remove image.
        docker rmi ${Ids[$index]} -f
        echo "Removed image: ${Reps[$index]}:${Tags[$index]} ${Ids[$index]}"
    done

    return ${rc}
}


function usage_help()
{
    USAGE=$(cat <<- EOF
	==================================================
	    Docker Command Tools  - $VERSION
	==================================================
	usage:   docker.sh [options]

	Options:
	  -i | --install | install:
	    install docker at host.
	  -u | --uninstall | uninstall:
	    uninstall docker at host.
	  -p | --proxy | proxy:
	    config docker proxy.
	  -r | --rmi | rmi:
	    remove image of docker.
	  -l | --list | list:
	    list images of docker.
	EOF
    )

    echo "$USAGE"
}

#############################################
# Entrance
#############################################
if [ $# == 0 ]; then
    usage_help
    exit -1
else
    while [ $# -gt 0 ]
    do
        case $1 in
        -i | --install | install)
            shift
            install_docker $@
            ;;
        -u | --uninstall | uninstall)
            shift
            uninstall_docker $@
            ;;
        -p | --proxy | proxy)
            shift
            docker_proxy $@
            shift
            ;;
        -r | --rmi | rmi)
            shift
            remove_image $@
            for index in $(seq $?)
            do
                shift
            done
            ;;
        -l | --list | list)
            shift
            list_image
            ;;
        -d | --daemon | daemon)
            shift
            config_docker_daemon $@
            ;;
        *)
            usage_help
            exit -1
        esac
        shift
    done
fi
