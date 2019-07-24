#!/bin/bash

# Author : Byng.Zeng
# Copyright (C) Byng.Zeng


VERSION=1.0.0

ZEPHYR_DIR=$HOME/workspace/zephyr/master
OUT_DIR=$ZEPHYR_DIR/out


function build()
{
    USAGE=$(cat <<- EOF
	----------------------------------------
	usage:  build options
	----------------------------------------
	options:
	  name :
	    name of project
	  [path]:
	    path of project
	    no set if path is located in samples/.
	EOF
    )
    
    if [ $# == 0 ]; then
        echo "$USAGE"
        exit -1
    elif [ $# == 1 ]; then
        out=$OUT_DIR/$1
        src=$ZEPHYR_DIR/samples/$1
        rc=1
    elif [ $# -gt 1 ]; then
        out=$OUT_DIR/$1
        src=$2
        rc=2
    fi

    if [ ! -e $src ]; then
        echo "Error, no found source code."
        exit -1
    fi

    if [ -e $out ]; then
        rm -rf $out
    fi

    cmake -B $out -DBOARD=qemu_x86 $src
    
    return $rc
}

function run()
{
    USAGE=$(cat <<- EOF
	----------------------------------------
	usage:  run options
	----------------------------------------
	options:
	  name :
	    name of project
	EOF
    )
    
    if [ $# == 0 ]; then
        echo "$USAGE"
        exit -1
    else
        if [ ! -e $OUT_DIR/$1 ]; then
            echo "Error, no found $1!"
            exit -1
        fi
    fi

    cd $OUT_DIR/$1
    make run
}

function usage_help()
{
    USAGE=$(cat <<- EOF
	----------------------------------------
	  zephyr tools - $VERSION
	----------------------------------------
	  usage:  zephyr [Options]  

	Options:
	  -b | build :
	    build application.
	  -r | run   :
	    run application.
	  -s | src   :
	    set path of zephyr source code. 
	EOF
    )
    echo "$USAGE"
}

if [ $# == 0 ]; then
    usage_help
    exit -1
else
    while [ $# -gt 0 ]
    do
        case $1 in
	    -b | build)
	        shift
	        build $@
	        for index in $(seq $?)
	        do
	            shift
	        done
	        ;;
	    -r | run)
	        shift
	        run $@
	        shift
	        ;;
	    -s | src)
	        shift
	        if [ $# -gt 0 ]; then
	            ZEPHYR_DIR=$1
	            OUT_DIR=$ZEPHYR_DIR/out
	            shift
	        else
	            echo 'Error, no set path of src'
	            usage_help
	            exit -1
	        fi
	        ;;
	    *)
	        echo "Error, found unknown command $1"
	        usage_help
	        exit -1
	    esac
    done
fi
