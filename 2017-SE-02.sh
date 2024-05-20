#!/bin/bash 
if [ $(id -u) -ne 0 ];then
  echo 'Run as root'
  exit 5 #zashoto posledno go dobavih e 5
fi

if [ $# -ne 3 ];then
	echo 'Wrong number of arguments'
	exit 1
fi

if [ ! -d $1 ] || [ ! -d $2 ];then
	echo 'First and second param must be directories'
	exit 2
fi

if [ ! -n $3 ];then 
	echo 'Third param should be string'
	exit 3
fi

if [ $(find "$2" -mindepth 1|wc -l) -ne 0 ];then
	echo 'second dir mush be empty'
	exit 4
fi

FILES=$(mktemp)

find "${1}" -mindepth 1 | egrep "${3}" >"$FILES"

while read FILE;do
mv "${FILE}" "${2}"

done <"${FILES}"


rm "${FILES}"
