[[ $# -ne 2 ]] && echo "2 params expected" && exit 1
[[ ! -d $1 || ! -d $2 ]] && echo "the 2 params must be dirs" && exit 2

filesInSecond=$(find $2 -mindepth 1)
[[ ! -z $filesInSecond ]] && echo "2nd dir must be empty" && exit 3

files=$(find $1 -type f -printf '%P\n')
int i=1
while read file; do
	echo "iteration $i with file $file"
	i=$(($i+1))
	
	basename=$(basename "$file")
	dirname=$(dirname "$file")
	echo "$basename"
	echo "$dirname"

	if [[ $basename =~ ^\..+\.swp$ ]]; then
		actualName=$(echo "$basename" | sed -E 's/\.(.+)\.swp$/\1/g')

		realFile=$(echo "$files" | egrep "${actualName}$")
		[[ ! -z $realFile ]] && continue
	fi

	mkdir -p "$2"/"$dirname"
	cp "$1"/"$file" "$2"/"$dirname"
done < <(echo "$files")


#Second solution

target=$(echo "$1" ) #| rev | cut -d '/' -f 2- | rev)
empty_dir=$(echo "$2") #| rev | cut -d '/' -f 2- | rev)

files=$(find "$target" -type f)
echo '$files:'
cat "$files"
echo ''

for file in $files; do
		to_add="$file"
		if echo "$file" | grep -qE "\.swp$"; then
				regular_file=$(echo "$file" | rev | cut -d "." -f 2- | rev)
				file_dir=$(echo "$regular_file" | rev | cut -d "/" -f 2- | rev)
				file_name=$(echo "$regular_file" | rev | cut -d "/" -f 1 | rev | cut -b 2-)
				if echo "$files" | grep -qE "^${file_dir}/${file_name}$"; then
						echo "$file is a swap file"
						continue
				fi
		fi
		target_dir_len=$(( $(echo "$target" | wc -c) ))
		echo "target dir length: $target_dir_len"
		file_dir=$(echo "$file" | cut -b ${target_dir_len}- | rev | cut -d "/" -f 2- | rev)
		echo "file dir: $file_dir"
		file_name=$(echo "$file" | rev | cut -d "/" -f 1 | rev)
		echo "file name: $file_name"
		mkdir -p "${empty_dir}$file_dir"
		touch "${empty_dir}${file_dir}/${file_name}"
done

