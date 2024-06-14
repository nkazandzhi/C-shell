#!/bin/bash 

FILE="./example-wakeup"

if [ $# -ne 1 ];then
    echo "Usage: $0 <device_name>"
    exit 1
fi

if ! grep -q "$1" "$FILE";then 
    echo "No such device in file"
    exit 2
fi

LINE=$(grep "$1" "$FILE")
STATUS=$(echo "${LINE}" | awk '{print $3}')
if [ "$STATUS" == "*enabled" ];then
    FIRST_SECOND=$(echo "${LINE}" | awk '{print $1 " " $2}')
    FOURTH=$(echo "${LINE}" | awk '{print $4}')
    echo "Changing line: $LINE"
    echo "New line: $FIRST_SECOND *disabled $FOURTH"
    sed -i "s|\([[:space:]]*\)\($1\)[[:space:]]*\(S4\)[[:space:]]*\(\*enabled\)[[:space:]]*\(.*\)|\1\2 \3 *disabled \5|g" "$FILE"
    echo "Wakeup for device $1 has been disabled."
fi
