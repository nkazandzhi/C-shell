if [ $# -ne 2 ];then 
	echo ''
	exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ];then
	echo "$1 either not a regular file or not readable"
	exit 2
fi

if [ ! -d "$2" ];then
	echo "$2 not a dir"
	exit 3
fi

BAD="${1}"
DIR="${2}"

cat "$BAD"

while read FILE;do
	cat "$FILE"
	while read BWORD;do
		if egrep -w -q "$BWORD" "$FILE";then
			LENGTH=$(echo "$BWORD" | wc -c)
			REPLACE=""
			while [ "$LENGTH" -gt 1 ];do
				REPLACE+="*"
				LENGTH=$(($LENGTH-1))
			done
			sed -i "s/${BWORD}/${REPLACE}/g" "$FILE"
		fi
	done<"$BAD"
done< <(find "$DIR" -type f -name "*.txt")
exit 0
