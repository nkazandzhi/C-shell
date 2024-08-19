if [ $# -ne 1 ]; then
		echo "No arguments"
		exit 2
fi

if [ ! -d $1 ]; then
		echo "No dir"
		exit 2
fi

candidates_file=$(mktemp)
while IFS= read -r file; do
	counter_file=$(mktemp)
	while IFS= read -r line; do
		for word in $line; do
				if echo "$word" | grep -Eq "\b[a-z]+\b"; then
						extracted_word=$(echo "$word" | grep -Eo "\b${word}\b")
						if ! grep -Eq "^${extracted_word}-" "$counter_file"; then
									echo "${extracted_word}-0" >> "$counter_file"
						fi
						count=$(grep -E "^${extracted_word}-" "$counter_file" | cut -d '-' -f 2)
						count1=$(($count + 1))
						sed -iE "s/^${extracted_word}-${count}/${extracted_word}-${count1}/" "$counter_file"
				fi
		done
	done < <(cat "$file" | tr 'A-Z' 'a-z')
	while IFS='-' read -r word count; do
			if [ $count -ge 3 ]; then
					echo "${word}-${count}" >> "$candidates_file"
			fi
	done < "$counter_file"	
done < <(find "$1" -type f)

files_count=$(find "$1" -type f | wc -l)
stop_words=$(mktemp)
while IFS=' ' read -r word_files_count word; do
		if [ $(( $word_files_count * 2 )) -ge "$files_count" ]; then
				word_occurences_count=$(cat "$candidates_file" | awk -F '-' -v word=${word} '{if (word == $1) count+= $2} END {print count}')
				echo "${word}-${word_occurences_count}" >> "$stop_words"
		fi

done < <(cat "$candidates_file" | cut -d '-' -f 1 | sort | uniq -c | awk '{print $1,$2}')

cat "$stop_words" | sort -t '-' -k 2 -nr | head -n 10
