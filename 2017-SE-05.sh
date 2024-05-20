#!/bin/bash

if [ $# -ne 2 ];then 
	echo 'Wrong number of arguments'
	exit 1
fi

if [ ! -d $1 ];then 
	echo 'First arg must be a directory'
	exit 2
fi

if [ -z $2 ];then 
	echo 'Second arg must be a non zero length string'
	exit 3
fi

find $1 -mindepth 1 -maxdepth 1 -printf "%f\n" | egrep "^vmlinuz-[0-9]+\.[0-9]+\.[0-9]+-${2}$" | sort -V -t'-' -k2 | tail -n 1
