#!/bin/bash
#Proverki
if [ $# -gt 2 ] || [ $# -lt 1 ]; then
	echo 'Wrong number of arguments.'
	exit 1
fi

if [ ! -d $1 ];then
	echo 'First argument must be a dir.'
	exit 2
fi

if [ $# -eq 2 ]; then
	if ! egrep -q '^[0-9]+$' <(echo "${2}");then
		echo 'Second argument must be an int'
		exit 3
	fi
fi

DIR="$1"

if [ $# -eq 2 ];then
NUM="$2"

find "${DIR}"  -printf "%n %p\n" | sort -t ' ' -k1 | awk -v num="$NUM" '$1 >= num {print $2}'

else

find "${DIR}" -xtype l

fi
