#!/bin/bash

if [ $# -ne 1 ];then
	echo 'Wrong number of args'
	exit 1
fi

if [ ! -f "$1" ] || [ ! -e "$1" ]; then
	echo "${1} is not a  regular file or doen not exist "
	exit 2
fi

helpfile=$(mktemp)
users=$(mktemp)
echo "$(cut -d ' ' -f 2 "$1" | sort -t ' ' -k1 | uniq -c | sort -rn | awk '{print $2}')" >> "$helpfile"

while read site;do
	http=$(egrep "$site" "$1" | egrep -w "HTTP/2.0" | wc -l )
	nonhttp=$(egrep "$site" "$1" | egrep -v -w "HTTP/2.0" | wc -l)
	echo "$site HTTP/2.0: ${http} non-HTTP/2.0: ${nonhttp}"
done< "$helpfile"

echo "$(cut -d ' ' -f 1,9 "$1" | awk '$2>302 {print $1}'| sort | uniq -c | sort -rn | head -n 5)"

rm "$helpfile"
rm "$users"

exit 0
