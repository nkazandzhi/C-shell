#!/bin/bash

if [ $# -ne 1 ];then
	echo 'Wrong number of arguments'
	exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ];then
	echo "$1 not file or not readable"
	exit 2
fi

WAKE_UP="/home/students/s62621/2022-SE-01/example-wakeup" 
CONFIG="$1"

sed -Ei 's/#.*$//g' "$CONFIG"

while read DEVICE D_STATUS;do
	if [ -z "$DEVICE" ];then
		continue
	fi
	
	if ! egrep -w -q "$DEVICE" "$WAKE_UP";then
		echo "$DEVICE not founf in the wake-up file"
	else
		C_STATUS=$(egrep -w "$DEVICE" "$WAKE_UP" | awk '{print $3}')

		if [ "$D_STATUS" == "$C_STATUS" ];then 
			continue
		else
			
			sed -Ei "s/(${DEVICE}.*)(\*${C_STATUS})(.*$)/\1${D_STATUS}\3/g" "$WAKE_UP"

		fi
	fi
done < "$CONFIG"

exit 0
