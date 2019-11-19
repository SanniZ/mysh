#!/bin/bash

VERSION=1.0.0

CURDIR=$(pwd)


function usage_help()
{
    USAGE=$(cat <<- EOF
	----------------------------------------
	  mygit - $VERSION
	----------------------------------------
	  usage:  mygit options  

	options:
	  -p | push :
	    run push origin master.
	  -m | modified :
	    check modified files.
	  -u | unchecked :
	    check modified files.
	EOF
    )
    echo "$USAGE"
}

function push_origin_master()
{
    for d in $(ls $1)
    do
        dr=$1/$d
        res=$(find $dr -name .git | grep '.git')
        if [[ -z $res ]]; then
            continue
        fi
        echo "-----$dr-----"
        cd $dr
        res=$(git status | grep "modified:")
        if [[ ! -z $res ]]; then
            echo "found modified files!!!"
        else
            git push origin master # push to github.
        fi
    done
    # go back origin path.
    cd $CURDIR
}


function check_modified_files()
{
    for d in $(ls $1)
    do
        dr=$1/$d
        res=$(find $dr -name .git | grep '.git')
        if [[ -z $res ]]; then
            continue
        fi
        cd $dr
        res=$(git status | grep "modified:")
        if [[ ! -z $res ]]; then
            echo "-----$dr-----"
            echo "found modified files!!!"
        fi
    done
    # go back origin path.
    cd $CURDIR
}

function check_untracked_files()
{
    for d in $(ls $1)
    do
        dr=$1/$d
        res=$(find $dr -name .git | grep '.git')
        if [[ -z $res ]]; then
            continue
        fi
        cd $dr
        res=$(git status | grep "Untracked files:")
        if [[ ! -z $res ]]; then
            echo "-----$dr-----"
            echo "found untracked files!!!"
        fi
    done
    # go back origin path.
    cd $CURDIR
}

if [ $# == 0 ]; then
    usage_help
    exit -1
else
    while [ $# -gt 0 ]
    do
        case $1 in
	    -p | push)
	        shift
	        push_origin_master $GIT
	        ;;
	    -m | modified)
	        shift
	        check_modified_files $GIT
	        ;;
	    -u | unchecked)
	        shift
	        check_untracked_files $GIT
	        ;;
	    *)
	        echo "Error, found unknown command $1"
	        usage_help
	        exit -1
	    esac
    done
fi
