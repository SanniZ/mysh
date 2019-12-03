#!/bin/bash

VERSION='1.0.3'

git_dir=$(cd `dirname $0`; pwd)

if [ $# == 0 ]; then
    res=$(bash ${git_dir}/git.sh -h)
    echo -e "$res[@]" | sed 's/git/mygit/g'
    exit -1
else
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
