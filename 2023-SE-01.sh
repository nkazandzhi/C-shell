#!/bin/bash

if [ $# -ne 2 ];then
	echo "Wrong number of arguments!"
	exit 1
fi 

if [ ! -f $1 ];then
	echo "First paramether must be a file!"
	exit 2
fi

if [ ! -n $2 ];then
	echo "Second paramether must be a string!"
	exit 3
fi

HELP_FILE=$(mktemp)

egrep ",$2," "$1" >> "$HELP_FILE"


CONSTELATION=$(sort -t ',' -k 4 "$HELP_FILE" | uniq -c | sort -n | head -n 1 | awk '{print $2}')

STAR=$(egrep ${CONSTELATION} "$HELP_FILE" | sort -n -t ',' -k 7 | head -n 1|cut -d ',' -f 1 )

echo "$STAR"

rm "$HELP_FILE"
exit 0
