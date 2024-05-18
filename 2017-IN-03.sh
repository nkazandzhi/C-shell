#!/bin/bash

if [ $(id -u) -ne 0 ];then
  echo "Run as root"
  exit 1
fi

USER_HOMES=$(mktemp)


cat /etc/passwd |  cut -d ':' -f 6 | tr ':' ' ' > "${USER_HOMES}"

LATEST_TIME=0
LATEST_USER=""
LATEST_FILE=""
#mislq, che trqbva da e head -n 1 nakraq, da vzemem file-a s nai-malko sekunndi (nai-skoro promenqn)
while read DIR; do
	if [ -d "$DIR" ];then 
		FILE=$(find "${DIR}" -type f -printf "%T@ %p\n" 2>/dev/null  | sort -n -t ' ' -k1 | tail -n 1)
	

	if [ -n "$FILE" ];then
		FILE_TIME=$(echo "$FILE" | cut -d ' ' -f 1 )
		FILE_PATH=$(echo "$FILE" | cut -d ' ' -f 2-)

		
		if [ $(echo "$FILE_TIME > $LATEST_TIME" | bc -l) -eq 1 ]; then 
			LATEST_TIME="$FILE_TIME"
			LATEST_USER=$(basename "${DIR}")
			LATEST_FILE="$FILE_PATH"
		fi
	fi
fi	

done < "${USER_HOMES}"

#results
if [ -n "$LATEST_USER" ] && [ -n "$LATEST_FILE" ];then
	echo "user: $LATEST_USER"
	echo "file: $LATEST_FILE"
else
	echo "no files in home directory."
fi

rm "${USER_HOMES}"
