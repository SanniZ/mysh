#!/bin/bash

function help_menu()
{
    echo '-r'
    echo '  restart'
    echo '-s'
    echo '  setup sunpinyin'
    echo '-p'
    echo '  setup pinyin'
}

function ibus_restart()
{
    ibus restart
}

function ibus_setup()
{
    if [ $1 == 'sunpinyin' ]; then
        ibus engine sunpinyin
    else
        echo 'unknow, set default: sunpinyin'
        ibus engine sunpinyin
    fi
}

if [ $# == 0 ]; then
    help_menu
else
    while getopts 'rsh' opt
    do
        case ${opt} in
        r):
            ibus_restart
        ;;
        s):
            ibus_setup 'sunpinyin'
        ;;
        h):
            help_menu
        ;;
        esac
    done
fi
