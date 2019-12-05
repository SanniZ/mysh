#!/bin/bash

VERSION='1.0.3'

git_dir=$(cd `dirname $0`; pwd)

mygit_help()
{
    HELPS=$(cat <<- EOF
	"----------------------------------------"
	"    mygit - $VERSION"
	"----------------------------------------"
	usage:  git options  
	options:
	  -p : push to master of path.
	  -m : get modified files of path.
	  -n : get new files of path.
	  -s : sync files.
	EOF
    )
    echo -e "$HELPS"
}


# entance.
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
	        bash ${git_dir}/git.sh -p $MYGIT
	    ;;
	    -m)
	        shift
	        bash ${git_dir}/git.sh -m $MYGIT "pyc|__pycache__"
	    ;;
	    -n)
	        shift
	        bash ${git_dir}/git.sh -n $MYGIT "pyc|__pycache__"
	    ;;
        -s)
            shift
            bash ${git_dir}/git.sh -s $MYGIT
        ;;
	    *)
            shift
            mygit_help
	        exit
	    esac
    done
fi