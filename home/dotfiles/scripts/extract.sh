#!/usr/bin/env bash

set -eu

# Extracts a compressed file

realpath() {
	[[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

archive=$1
real_archive=$(realpath $archive)

filename=$(basename "$archive")
[[ -z $2 ]] && target="${filename%.*}" || target=$2

[[ -f $target ]] && echo "$target already exists and is a file" && exit 1

mkdir -p $target
cd $target

if [ -f $real_archive ]; then
	case $real_archive in
	*.tar.xz) tar xpvf $real_archive ;;
	*.tar.bz2) tar xjf $real_archive ;;
	*.tar.gz) tar xzf $real_archive ;;
	*.bz2) bunzip2 $real_archive ;;
	*.rar) unrar x $real_archive ;;
	*.gz) gunzip $real_archive ;;
	*.tar) tar xf $real_archive ;;
	*.tbz2) tar xjf $real_archive ;;
	*.tgz) tar xzf $real_archive ;;
	*.zip) unzip $real_archive ;;
	*.Z) uncompress $real_archive ;;
	*) echo "'$archive' cannot be extracted via extract()" ;;
	esac
else
	echo "'$archive' is not a valid file"
fi
