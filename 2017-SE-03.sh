#!/bin/bash
if [ $(id -u) -ne 0 ];then
	echo "run as root"
	exit 1
fi

USERS=$(mktemp)
ps -e -o user= | sort | uniq > "$USERS"
RSS_SUM=0
AVG_RSS=0
PR_COUNT=0
while read USER;do
	USER_RSS_SUM=$(ps -u "$USER" -o rss= | awk '{SUM += $1}END{print SUM}')
	RSS_SUM=$((${USER_RSS_SUM}+${RSS_SUM}))
	PR_COUNT=$(($(ps -u "$USER" |tail -n +2 |  wc -l) + $PR_COUNT))

	ps -u "$USER" -o pid=,rss= | while read pid rss;do
	if [ ${rss} -gt $((2* ${AVG_RSS})) ];then 
		echo "Process with $pid PID should be killed"
		#kill -9 $pid
	fi
done
done < "$USERS"
echo "Processes count $PR_COUNT"
echo "RSS $RSS_SUM"
AVG_RSS=$((${RSS_SUM}/${PR_COUNT}))



rm "$USERS"
