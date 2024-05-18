#!/bin/bash 

if [ $# -ne 2 ]; then
	echo "Wrong number of arguments!"
	exit 1
fi

touch help-file
find ~ -type f > help-file
FIRST=$(cat help-file | egrep "/$1\$")
SECOND=$(cat help-file | egrep "/$2\$")
echo "${FIRST}"
echo "${SECOND}"

if [ ! -f "$FIRST" ] || [ ! -f "$SECOND" ];then
	echo "Both arguments should be in your home directory!"
	exit 2
fi

FIRST_LINES=$(cat "${FIRST}" | wc -l)
SECOND_LINES=$(cat "${SECOND}"| wc -l)
echo "${FIRST_LINES}"
echo "${SECOND_LINES}"
WINNER=
NAME= 
if [ "${FIRST_LINES}" -gt "${SECOND_LINES}" ];then
	WINNER="${FIRST}"
	NAME=$1
else
	WINNER="${SECOND}"
	NAME=$2
fi

echo "${WINNER}"
echo "${NAME}"

cat "${WINNER}" | cut -d '-' -f 2- | sort > "${NAME}".songs
