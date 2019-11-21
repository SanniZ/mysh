#!/bin/bash

VERSION='1.0.3'

if [ $# == 0 ]; then
    mygit_help
    exit -1
else
    git_dir=$(cd `dirname $0`; pwd)
    while [ $# -gt 0 ]
    do
        case $1 in
	    -p)
	        shift
	        bash ${git_dir}/git.sh -p $GIT
	        ;;
	    -m)
	        shift
	        bash ${git_dir}/git.sh -m $GIT "pyc|__pycache__"
	        ;;
	    -n)
	        shift
	        bash ${git_dir}/git.sh -n $GIT "pyc|__pycache__"
	        ;;
	    *)
            shift
            res=$(bash ${git_dir}/git.sh -h)
            echo -e "$res[@]" | sed 's/git/mygit/g'
	        exit
	    esac
    done
fi
