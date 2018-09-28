#!/bin/bash

function help_menu()
{
    echo '-r'
    echo '  restart'
    echo '-L'
    echo '  list engine'
    echo '-s'
    echo '  setup sunpinyin'
    echo '-p'
    echo '  setup pinyin'
    echo '-g'
    echo '  setup googlepinyin'
    echo '-w'
    echo '  setup wubi98'
    echo '-v'
    echo '  setup wubi-haifeng86'
    echo '-V'
    echo '  setup wubi-jidian86'
}

function ibus_restart()
{
    ibus restart
}

function ibus_setup()
{
    ibus engine $1
}

if [ $# == 0 ]; then
    help_menu
else
    while getopts 'rLspgwvVh' opt
    do
        case ${opt} in
        r):
            ibus_restart
        ;;
        L):
            ibus list-engine
        ;;
        s):
            ibus_setup 'sunpinyin'
        ;;
        p):
            ibus_setup 'pinyin'
        ;;
        g):
            ibus_setup 'googlepinyin'
        ;;
        w):
            ibus_setup 'wubi98'
        ;;
        v):
            ibus_setup 'wubi-haifeng86'
        ;;
        V):
            ibus_setup 'wubi-jidian86'
        ;;
        h):
            help_menu
        ;;
        esac
    done
fi
