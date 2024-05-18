#!/bin/bash

if [ $# -ne 3 ]; then
	echo "Wrong number of arguments!"
	exit 1
fi

if [ ! -f "$1" ] && [ ! -r "$1" ]; then 
	echo "First argument must be a file!"
	exit 2
fi

if [ ! -n "$2" ] && [ ! -n "$3" ]; then
	echo "Arguments 2 and 3 must be string"
	exit 3
fi

FILE="$1"
KEY_1="$2"
KEY_2="$3"

VALUE_1=$(grep -w "${KEY_1}" "${FILE}" | cut -d '=' -f 2)
VALUE_2=$(grep -w  "${KEY_2}" "${FILE}" | cut -d '=' -f 2)

NEWWORD=""

# Read the lines into arrays
read -a STRING_2 <<< "$VALUE_2"

for word in "${STRING_2[@]}"; do

    # Check if the word is not in VALUE_1
	if ! egrep -q "${word}" <(echo "${VALUE_1}"); then
        # Append the word to NEWWORD
        NEWWORD+="$word "
    fi
done

sed -i -E "s/${KEY_2}=${VALUE_2}/${KEY_2}=${NEWWORD}/" "${FILE}"
