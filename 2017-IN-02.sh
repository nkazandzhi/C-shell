#!/bin/bash

if [ $# -ne 1 ]; then
	echo 'Wrong number of arguments!'
	exit 1
fi

if ! $(id -u "$1" &>/dev/null); then
	echo 'Invalid username'
	exit 2
fi

#if [ $(id -u) -ne 0 ]; then
#	echo 'Run as root'
#	exit 3
#fi

NUMBERPROCESSES=$(ps -u "$1" -o pid=,cmd= | wc -l)
echo "${1} has $NUMBERPROCESSES processes. "

USERS=$(mktemp)
ps -eo user= | sort | uniq > "${USERS}"

echo "Users that have more processes than ${1}:"

while read USER; do
	#a
	UP=$(ps -u "${USER}" -o pid= | wc -l)
	#echo "${UP}, ${NUMBERPROCESSES}, ${USER}"
	if [ "${UP}" -gt "${NUMBERPROCESSES}" ]; then
		echo "${USER}"
	fi
done < "${USERS}"

	#b
PROCESSES=$(mktemp)
ps -eo pid=,etimes= > "${PROCESSES}"
ALLPROCESSES=$(cat "$PROCESSES" | wc -l)
SUM=0
AVG=$(awk '{SUM += $2}END{print int(SUM/NR)}' "${PROCESSES}")
echo "The average is: $AVG"

	#c
FOOPR=$(mktemp)
ps -u "$1" -o pid=,etimes= > "${FOOPR}"
while read pid time; do
	if [ "${time}" -gt $(("${AVG}" * 2)) ]; then
		#kill -15 pid
		#sleep 2 
		#kill -9 pid
		echo "Process with ${pid} PID should be killed because is twice as big as the average. "
	fi
done < "${FOOPR}"


rm "${USERS}"
rm "${PROCESSES}"
rm "${FOOPR}"
