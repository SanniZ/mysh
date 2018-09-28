#!/bin/bash

#set -x


function menu_help()
{
	echo "==========================================="
	echo "      unzip all of images from *.ziw"
	echo "==========================================="
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
	rm -rf $1/*.html
	rm -rf $1/index_files
        # delete sepical size files.
	imgs=$(find $1 -size -32k -exec ls {} \;)
	rm -rf $imgs
}


function unzip_ziw()
{
	src_path=$1
	out_path=$2

	mkdir -p $out_path

	cd $src_path
	types=$(ls)

	# for types
	for type in $types
	do
		if [ -d $src_path/$type ]; then
			cd $src_path/$type
			$(rename 's/ /_/g' *)
                        dirs=$(ls)

			# for all of dirs
			for dir in $dirs
			do
				if [ -d $src_path/$type/$dir ]; then
					# for all of .ziw
					cd $src_path/$type/$dir
					$(rename 's/ /_/g' *)
					$(rename 's/！/_/g' *)
					fs=$(find $path -name "*.ziw")
		                        for f in $fs
					do
						# create output dir
						fname=$(basename $f .ziw)
						outp=$out_path/$type/$dir/$fname
						mkdir -p $outp
						# unzip .ziw
						unzip -Cq -d $outp $f
						# get png and jpg.
						if [ -e $outp/index_files ]; then
							fs=$(find $outp/index_files -type f -name "*.png" -o -name "*.jpg" -o -name "*.jpeg")
							mv -f $fs $outp
						fi
						# remove invalid files.
				                rm_invalid_file $outp
		                        done
                                fi
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
