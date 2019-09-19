#!/bin/bash

#
# Auther   : Byng.Zeng
# Copyright: Byng.Zeng
#

VERSION=1.0.0

function repo_init() {
    repo init -u ssh://android.intel.com/manifests -b android/celadon -m r2
}

function repo_sync() {
    repo sync -c -j5
}


function build_kf4aic() {
    . build/envsetup.sh
    lunch multidroid_nuc-userdebug
    ALLOW_MISSING_DEPENDENCIES=true make -j8 multidroid && aic-build
}


function usage_help() {
    usage=$(cat <<- EOF
	=======================================
	         celadon -m r2 - $VERSION
	=======================================
	-b | build:  build kf4aic.efi
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
            build_kf4aic
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
