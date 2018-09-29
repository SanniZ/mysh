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
	find $1 -type d -empty | xargs -I {} rm -rf {}
}

function rm_unuse_file()
{
	rm -rf $1/*.html
	rm -rf $1/index_files
	# delete size>32k files.
	find $1 -type f -size -32k | xargs -I {} rm -rf {}
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
		type_path=$src_path/$type
		if [ -d $type_path ]; then
			cd $type_path
			dirs=$(ls)

			# for all of dirs
			for dir in $dirs
			do
				# backup dir
				cp -r $src_path/$type/$dir $src_path/$type/$dir.bak
				
				dir_path=$src_path/$type/$dir
				if [ -d $dir_path ]; then
					# for all of .ziw
					cd $dir_path
					rename 's/ /_/g' *
					fs=$(find $dir_path -name "*.ziw")
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
							find $outp/index_files -type f -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | xargs -I {} mv -f {} $outp
						fi
						# remove invalid files.
				        rm_unuse_file $outp
					done
				fi
				
				#restore dir
				rm -rf $src_path/$type/$dir
				mv $src_path/$type/$dir.bak $src_path/$type/$dir
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
