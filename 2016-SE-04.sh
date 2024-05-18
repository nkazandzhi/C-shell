#!/bin/bash

if [ $# -ne 2 ];then
	echo "Wrong number of arguments!"
	exit 1
fi 

while read line;do
	FILE=$(basename "${line}")
	LINES=$(wc -l "${FILE}"| cut -d ' ' -f 1)
	if [ "${LINES}" -lt $1 ];then
		mv "${FILE}" a
	elif [ "${LINES}" -le $2 ] && [ "${LINES}" -ge $1 ];then
		mv "${FILE}" b
	else
		mv "${FILE}" c
	fi

done< <(find . -mindepth 1 -type f )
