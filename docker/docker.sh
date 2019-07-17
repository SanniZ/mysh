#!/bin/bash
#
# Auther   : Byng.Zeng
# Copyright: Byng.Zeng
#

VERSION=1.0.0


#############################################
# Functions
#############################################

# install docker to ubuntu host.
function install_docker()
{
    DOCKER='docker docker-compose docker.io docker-registry'

    read -p "Confirm to install docker [Y/n]:" opt
    opt=$(echo ${opt} | tr '[a-z]' '[A-Z]')
    if [[ ${opt} == 'Y' ]]; then
        sudo apt-get install $DOCKER -y
        echo "Installed docker to host."
    fi
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

# config proxy for docker.
function config_proxy()
{
    source dockerproxy.sh $@
}

# config docker
function config_docker()
{
    USAGE=$(cat <<- EOF

	  usage: docker -c options

	  options:
	  -p | --proxy | proxy  config:  config proxy of docker
	                        remove:  remove proxy of docker
	EOF
    )

    if [ $# == 0 ]; then
        echo "${USAGE}"
        exit -1
    else
        while [ $# -gt 0 ]
        do
            case $1 in
            -p | --proxy | proxy)
                shift
                if [[ $1 == 'config' ]]; then
                    shift
                    config_proxy -c -u
                    echo 'Configurated proxy of docker'
                elif [[ $1 == 'remove' ]]; then
                    shift
                    config_proxy -r -u
                    echo 'Removed proxy of docker'
                else
                    echo "${USAGE}"
                    exit -1
                fi
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

	usage: docker -r options

	Options:
	  -a:
	    remove all of images.
	  -n xxx:
	    remove xxx name of image.
	  -d xxx:
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
            -n)  # search by name of Repository
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
            -d)  # search by id of image
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
           -a)  # search all of images.
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
	  -c | --config | config:
	    config docker.
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
            install_docker
            ;;
        -u | --uninstall | uninstall)
            shift
            uninstall_docker
            ;;
        -c | --config | config)
            shift
            config_docker $@
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
        *)
            usage_help
            exit -1
        esac
        shift
    done
fi
