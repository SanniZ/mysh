#!/bin/bash

#
# Auther   : Byng.Zeng
# Copyright: Byng.Zeng
#

VERSION=1.0.0


function repo_init() {
    repo init -u ssh://android.intel.com/manifests -b android/celadon -m r1
}

function repo_sync() {
    repo sync -c -j5
}


function build_tosimage() {
    # removed old obj.
    rm -rf out/target/product/celadon_ivi/obj/trusty/
    # build tos.img
    . build/envsetup.sh
    lunch celadon_ivi-userdebug
    make SPARSE_IMG=true tosimage -j8
}


function usage_help() {
    usage=$(cat <<- EOF
	=======================================
	         celadon -m r1 - $VERSION
	=======================================
	-b | build:  build tos.img
	-i | init :  repo init
	-s | sync :  repo sync
	EOF
    )
    echo "$usage"
}


if [ $# == 0 ]; then
    usage_help
else
    while [ $# -gt 0 ]
    do
        case $1 in
	-b | build)
            shift
            build_tosimage
        ;;
        -i | init)
            shift
            repo_init
	;;
        -s | sync)
            shift
            repo_sync
	;;
        *)
            usage_help
	    exit
        esac
    done
fi
