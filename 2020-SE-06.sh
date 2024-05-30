#!/bin/bash

if [ $# -ne 3 ];then
	echo 'Wrong number of arguments'
	exit 1
fi

if [ ! -f $1 ] || [ ! -r $1 ];then
	echo 'First argument must be a readable regular file'
	exit 2
fi

if [ -z $2 ] || [ -z $3 ];then
	echo 'Second and third argumest must be  a non-zero string'
	exit 3
fi

FILE=${1}
KEY=${2}
VALUE=${3}

if egrep -q "\s*${KEY}\s*=" $FILE;then
	if egrep -q "\s*${KEY}\s*=\s*${VALUE}\s*#*" $FILE;then
		echo 'No changes'
		exit 0
	else
	CHANGE=$(egrep "\s*${KEY}\s*=" $FILE)
	FIRST_PART=$(mktemp)
	SECOND_PART=$(mktemp)
	
	COUNT=1
	while read LINE;do
		if [ "${LINE}" != "${CHANGE}" ];then
			COUNT=$(($COUNT+1))
			echo "${LINE}" >> "${FIRST_PART}"
		else
			break
		fi
	done <"$FILE"

	COUNT=$(($COUNT+1))

	COUNT_SP=1

	#NE RABOTI
	#while read LINE;do
	#	if [ ${COUNT_SP} -le ${COUNT} ];then
	#		COUNT_SP=$(($COUNT_SP+1))
	#	else
	#		echo "${LINE}" >> "${SECOND_PART}"
	#	fi
	#done < "$FILE"

	while read LINE;do
		echo "$LINE" >> "${SECOND_PART}"
	done< <(tail -n +$COUNT "$FILE") #vlizame redovete ot n-ti red do kraq
	
	DATE_=$(date)
	USER_=$(whoami)

	cat "${FIRST_PART}" > "$FILE"

	echo "# ${CHANGE} #edited at ${DATE_} by ${USER_}" >> "$FILE"
	echo "${KEY} = ${VALUE} #added at ${DATE_} by ${USER_}" >> "$FILE"

	cat "${SECOND_PART}" >> "$FILE"
	fi	
else
	DATE_=$(date)
	USER_=$(whoami)
	echo "${KEY} = ${VALUE} #added at ${DATE_} by ${USER_}" >> "$FILE"
fi

rm "$FIRST_PART"
rm "$SECOND_PART"
