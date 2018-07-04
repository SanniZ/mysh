#!/bin/bash

CPU=$(cat /proc/cpuinfo| grep "processor"| wc -l)

function makeImage() {
    echo "start to build image: $2"
    rm -rf out/.lock
    device/intel/mixins/mixin-update
    . build/envsetup.sh
    lunch $1
    make $2 -j$CPU
}

# $1: lunch option
# $2: build image
makeImage $1 $2
