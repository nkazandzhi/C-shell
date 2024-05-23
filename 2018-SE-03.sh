#!/bin/bash

if [ $# -ne 2 ];then
	echo 'Wrong number of arguments'
	exit 1
fi

if [ ! -f "$1" ] || [ ! -f "$2" ];then
	echo 'Both arguments must be regular files'
	exit 2
fi

if [ ! -r "$1" ];then
	echo 'First argument not readable'
	exit 3
fi


if [ ! -w "$2" ];then
	echo "Cant write to file "$2""
	exit 4
fi

FILE=$(mktemp)
cut -d ',' -f 2- "$1" | sort | uniq > "$FILE"

while read LINE;do
	if [ $(egrep "$LINE" "$1" | wc -l ) -gt 1 ];then
		egrep ",${LINE}$" "$1" | sort -n -t',' -k 1 | head -n 1 >> "$2" 
	else
		egrep ",${LINE}$" "$1" >> "$2"
	fi

done <"${FILE}"

rm "$FILE"

exit 0
