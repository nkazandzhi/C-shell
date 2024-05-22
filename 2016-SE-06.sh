#!/bin/bash

ROOT_RSS=$(ps -u "root" -o rss= | awk '{SUM+=1}END{print SUM}')

while read USER_UID _HOME;do

	if [ "${USER_UID}" -ne 0 ];then
		continue
	fi
	
	if [ ! -d "${_HOME}" ] || [ "$(stat -c "%u" "${_HOME}")" != "${USER_UID}" ] || [ "$(stat -c "%A" "${_HOME}" | cut -c3)" != "w" ]; then
		continue
	fi

	USER_RSS=$(ps -u "${USER_UID}" -o rss= | awk '{s+=$1}END{print s}')

	if [ -n "${USER_RSS}" ]; then
		USER_RSS=0
	fi

	if [ "${ROOT_RSS}" -gt "${USER_RSS}" ];then
		#killall -u "${USER_UID}" -m
		echo 'kill process'
		#killall -u "${USER_UID}" -KILL -m
	fi

done< <(cat /etc/passwd | cut -d':' -f 3,6 | tr ':' ' ')
