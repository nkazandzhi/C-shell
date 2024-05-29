mkdir -p "$DST/images"
mkdir -p "$DST/by-title"

while read FILE;do
	#echo $FILE
	TITLE=$(echo $(basename "$FILE") | sed -e 's/([^()]*)//g' | tr -s ' ' | rev | cut -c 5- | rev)
	#echo -n  "${TITLE} -> "
	
	ALBUM=$(echo $(basename "$FILE") | grep -o '([^()]*)' | tail -n 1 | tr -d '()' | tr -s ' ')
	if [ -z "$ALBUM" ];then
		ALBUM="misc"
	fi
	#echo "${ALBUM}"
	
	MOD_DATE=$(stat -c "%y" "$FILE" | awk '{print $1}')
	
	HASH=$(sha256sum "${FILE}" | awk '{print $1}' | cut -c 1-16)
	
	cp "$FILE" "$DST/images/$HASH.jpg"

	mkdir -p "${DST}/by-date/${MOD_DATE}/by-album/${ALBUM}/by-title" 2>/dev/null
	mkdir -p "${DST}/by-date/${MOD_DATE}/by-title" 2>/dev/null
	mkdir -p "${DST}/by-album/${ALBUM}/by-date/${MOD_DATE}/by-title" 2>/dev/null
	mkdir -p "${DST}/by-album/${ALBUM}/by-title" 2>/dev/null

	ln -sf "../../../../../images/${HASH}.jpg" "$DST/by-date/$MOD_DATE/by-album/${ALBUM}/by-title/${TITLE}.jpg"
	ln -sf "../../../images/${HASH}.jpg" "$DST/by-date/$MOD_DATE/by-title/${TITLE}.jpg"
	ln -sf "../../../../../images/${HASH}.jpg" "$DST/by-album/${ALBUM}/by-date/$MOD_DATE/by-title/${TITLE}.jpg"
	ln -sf "../../../images/${HASH}.jpg" "$DST/by-album/${ALBUM}/by-title/${TITLE}.jpg"
	ln -sf "../images/${HASH}.jpg" "$DST/by-title/${TITLE}.jpg"
	

done< <(find "$SRC" -type f -name "*.jpg")
