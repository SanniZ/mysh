#!/bin/bash

VERSION='1.0.1'

CURDIR=$(pwd)


function git_help()
{
    HELPS=$(cat <<- EOF
	"----------------------------------------"
	"    git - $VERSION"
	"----------------------------------------"
	usage:  git options  
	options:
	  -p path : push to master of path.
	  -m path ex_file: get modified files of path.
	  -n path ex_file: get new files of path.
	EOF
    )
    echo -e "$HELPS"
}



function git_push_origin_master()
{
    if [ $# -lt 1 ]; then
        echo 'error, pls input path!!!'
        return
    fi

    gits=$(find $1 -type d -name .git | sed 's/\/.git//')
    for git in $gits
    do
        echo "-----$git-----"
        cd $git
        git push origin master # push to github.
    done
    # go back origin path.
    cd $CURDIR
}


function git_status_files()
{
    path=$1
    if [ $# -gt 2 ]; then
        ex=$2
        opt=$3
    else
        ex=None
        opt=$2
    fi
    # get all of git.
    gits=$(find ${path} -type d -name .git | sed 's/\/.git//g')
    # check all of git.
    for git in ${gits[@]}
    do
        cd ${git}  # switch to git path.
        fs=$(git status -s | grep ${opt})  # git status -s for status files.
        if [[ ${#fs} -gt 0 ]]; then  # check status files.
            if [ $opt == "M" ]; then  # modified files
                fs=$(echo -e ${fs} | sed 's/M /[Modified]:/g')
            elif [ $opt == "??" ]; then  # new files
                fs=$(echo -e ${fs} | sed 's/?? /[New]:/g')
            fi
            if [ ${#fs} -gt 0 ]; then
                pr_path=1
                for f in ${fs}  # print result.
                do
                    # filter exclude files.
                    if [ $ex != None ]; then
                        fx=$(echo -e $f | grep -E ${ex}) 
                        if [ ${#fx} -gt 0 ]; then
                            continue
                        fi
                    fi
                    # print path.
                    if [ ${pr_path} == 1 ]; then
                        echo "-----${git:${#GIT}+1:${#git}}-----"
                        pr_path=0
                    fi
                    # print result file.
                    echo $f | sed 's/:/: /'
                done
            fi
        fi
    done
    # go back origin path.
    cd $CURDIR
}


if [ $# == 0 ]; then
    git_help
else
    while [ $# -gt 0 ]
    do
        case $1 in
	    -p)
	        shift
            if [ $# -gt 0 ]; then
	            git_push_origin_master $1
                shift
            fi
	        ;;
	    -m)
	        shift
	        git_status_files $1 $2 "M"
            shift
            shift
	        ;;
	    -n)
	        shift
	        git_status_files $1 $2 "??"
            shift
            shift
	        ;;
	    *)
            shift
            git_help $@
            exit
	    esac
    done
fi
