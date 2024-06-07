#!/bin/bash

if [ $# -le 2 ];then
	echo 'arguments'
	exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ];then
	echo 'first file either not regular file or readable'
	exit 2
fi

if [ ! -f "$2" ] || [ ! -r "$2" ];then 
	echo '..'
	exit 3
fi

if [ -z "$3" ];then 
	echo '..'
	exit 4
fi


STAR="$3"
FIRST_FILE="$1"
SECOND_FILE="$2"

FIRST_STAR=$(egrep "$3" "$FIRST_FILE" | cut -d ':' -f 2| rev | cut -c 12- | rev | tr -d ' ' | tr -d '\t')

SECOND_STAR=$(egrep "$3" "$SECOND_FILE" | cut -d ':' -f 2| rev | cut -c 12- | rev | tr -d ' ' | tr -d '\t')


if [ "$FIRST_STAR" -gt "$SECOND_STAR" ];then
	echo "$SECOND_FILE"
elif [ "$FIRST_STAR" -lt "$SECOND_STAR" ];then
	echo "$FIRST_FILE"
else
	echo "equal"
fi

exit 0
