#!/bin/bash

# Check if exactly two arguments are passed
if [ $# -ne 2 ]; then
    echo 'Wrong number of arguments'
    exit 1
fi

# Check if the first argument is a regular file
if [ ! -f "$1" ]; then
    echo 'First argument must be a regular file'
    exit 2
fi

# Check if the second argument is an empty directory
if [ ! -d "$2" ] || [ "$(find "$2" -mindepth 1 | wc -l)" -ne 0 ]; then
    echo 'Second argument must be an empty directory'
    exit 3
fi

touch "${2}/dict.txt"
NUM=1

while read LINE; do
	#NAME=$(cut -d ':' -f 1 <<< "$LINE" | cut -d '(' -f 1)
	NAME=$(echo $LINE|cut -d ':' -f 1 | sed -E "s/\(.*\)//" | awk '$1=$1')
	#echo $NAME

	if egrep "$NAME" <<< "${2}/dict.txt"; then 
		continue
	else
		echo "${NAME};${NUM}" >> "${2}/dict.txt"
		NUM=$(("$NUM"+1))
	fi

	echo "${LINE}" | cut -d ':' -f 2 >> "${2}/${NUM}.txt"
done < "$1"
