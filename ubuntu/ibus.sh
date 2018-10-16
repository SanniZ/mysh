#!/bin/bash

function help_menu()
{
    echo '============================================'
    echo '          IBus command set'
    echo '============================================'
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
    echo '-a'
    echo '  add to database of wubi-love1.db'
    echo '-u'
    echo '  update database of wubi-love1.db'
}

function ibus_restart()
{
    ibus restart
}

function ibus_setup()
{
    ibus engine $1
}

function ibus_add_to_wubi_love98_db()
{
    txt=~/mysh/ubuntu/ibus-love98.txt
    
    echo '请输入词组：' && read key
    echo '请输入编码：' && read code

    sed -i '$d' $txt
    echo "$code	$key	1" >> $txt
    echo "END_TABLE" >> $txt
}

function ibus_update_wubi_love98_db()
{
    txt=~/mysh/ubuntu/ibus-love98.txt
    path_tables=/usr/share/ibus-table/tables

    ibus-table-createdb -s $txt -n wubi-love98.db
    sudo mv $path_tables/wubi-love98.db $path_tables/wubi-love98.db.bak
    sudo cp wubi-love98.db $path_tables/wubi-love98.db
    rm wubi-love98.db
    killall ibus-daemon
    ibus-daemon -d
}

if [ $# == 0 ]; then
    help_menu
else
    while getopts 'arLspgwvVuh' opt
    do
        case ${opt} in
        a):
            ibus_add_to_wubi_love98_db
        ;;
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
	u):
            ibus_update_wubi_love98_db
	;;
        h):
            help_menu
        ;;
        esac
    done
fi
