#!/bin/bash

love98_txt=~/mysh/ubuntu/ibus-love98.txt
tables_path=/usr/share/ibus-table/tables

function help_menu()
{
    echo '============================================'
    echo '          IBus command set'
    echo '============================================'
    echo '-r'
    echo '  restart'
    echo '-L'
    echo '  list engine'
    echo '-P'
    echo '  setup sunpinyin'
    echo '-p'
    echo '  setup pinyin'
    echo '-g'
    echo '  setup googlepinyin'
    echo '-S'
    echo '  setup wubi98'
    echo '-B'
    echo '  setup wubi-haifeng86'
    echo '-b'
    echo '  setup wubi-jidian86'
    echo '-a'
    echo '  add to database of wubi-love1.db'
    echo '-u'
    echo '  update database of wubi-love1.db'
    echo '-v'
    echo '  vim wubi-love98.txt'
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
    echo '请输入词组：' && read key
    echo '请输入编码：' && read code

    sed -i '$d' $love98_txt
    echo "$code	$key	1" >> $love98_txt
    echo "END_TABLE" >> $love98_txt
}

function ibus_update_wubi_love98_db()
{
    echo 'update ibus wubi_love98_db...'
    ibus-table-createdb -s $love98_txt -n wubi-love98.db
    sudo mv $tables_path/wubi-love98.db $tables_path/wubi-love98.db.bak
    sudo cp wubi-love98.db $tables_path/wubi-love98.db
    rm wubi-love98.db
    #echo 'restart ibus-daemon now...'
    killall ibus-daemon
    ibus-daemon -d
}

function ibus_vim_wubi_love98_txt()
{
   vim $love98_txt +
}

if [ $# == 0 ]; then
    help_menu
else
    while getopts 'arLPpgSBbuhv' opt
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
        P):
            ibus_setup 'sunpinyin'
        ;;
        p):
            ibus_setup 'pinyin'
        ;;
        g):
            ibus_setup 'googlepinyin'
        ;;
        S):
            ibus_setup 'wubi98'
        ;;
        B):
            ibus_setup 'wubi-haifeng86'
        ;;
        b):
            ibus_setup 'wubi-jidian86'
        ;;
        u):
            ibus_update_wubi_love98_db
        ;;
        v):
            ibus_vim_wubi_love98_txt
        ;;
        h):
            help_menu
        ;;
        esac
    done
fi
