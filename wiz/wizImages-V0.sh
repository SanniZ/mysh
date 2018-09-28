#!/bin/bash

#set -x


function menu_help()
{
	echo "-s"
	echo "  path of source files"
	echo "-o"
	echo "  path of output files."
}

function rm_empty_dir()
{
	find $1 -type d -empty | xargs rm -rf
}

function rm_invalid_file()
{
	rm -rf $outp/*.html
	rm -rf $outp/index_files
        # delete low size files.
	imgs=$(find $1 -size -32k -exec ls {} \;)
	rm -rf $imgs
}


function unzip_ziw()
{
	src_path=$1
	out_path=$2

	mkdir -p $out_path

	cd $src_path
	dirs=$(ls)

	for dir in $dirs
	do
		if [ -d $src_path/$dir ]; then
			cd $src_path/$dir
			list=$(find . -name *.ziw)
			for f in $list
			do
				sub_dir=$(basename $(dirname $f))
				#echo $sub_dir
				name=$(basename $f .ziw)
				outp=$out_path/$dir/$sub_dir/$name
				#echo $outp
				mkdir -p $outp
				unzip -Cq -d $outp $f
				if [ -e $outp/index_files ]; then
					fs=$(find $outp -type f -name "*.png" -o -name "*.jpg")
					mv -f $fs $outp
				fi
                                rm_invalid_file $outp
			done
		fi
	done
}


if [ $# == 0 ]; then
	menu_help
else
	while getopts 'o:s:' opt
	do
		case $opt in
		o)
			out=$OPTARG
		;;
		s)
			src=$OPTARG
		;;
		*)
			menu_help
			exit
		;;
		esac
	done

	if [[ -z $src || -z $out ]]; then
		menu_help
		exit
	fi

	unzip_ziw $src $out
        rm_empty_dir $out
fi
