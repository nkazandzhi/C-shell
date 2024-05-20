#!/bin/bash
if [ $# -gt 2 ] && [ $# -le 1 ];then
	echo 'Wrong number of arguments'
	exit 1
fi

if [ ! -d $1 ];then
	echo 'First arg must be a dir'
	exit 2
fi

if [ $# -eq 2 ];then
	
	if [ ! -f $2 ];then
		echo 'Second arg must be a regular file'
		exit 3
	fi

fi

SLINKS=$(mktemp)
OUTPUT=$(mktemp)
COUNT=0

find "$1" -type l > "${SLINKS}"

while read SYMLINK;do
	DEST=$(readlink "${SYMLINK}")
	if [ -e "${DEST}" ];then
		echo "${SYMLINK} -> ${DEST}" >> "${OUTPUT}"
	else
		COUNT=$(("$COUNT"+1))
	fi

done<"${SLINKS}"

if [ $# -eq 2 ];then
	cat "${OUTPUT}" >> "${2}"
	echo "Broken symlinks: ${COUNT}" >> "${2}"
else
	cat "${OUTPUT}"
	echo "Broken symlinks: ${COUNT}"
fi

rm "${SLINKS}"
rm "${OUTPUT}"
