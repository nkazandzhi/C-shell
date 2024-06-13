#НЕ ТЕСТВАНА
src=$1
target=$2

if [ ! -d "$src" ]; then
		echo "Invalid Photoaparat"
		exit 1
fi

mkdir "$target"

photo_files=$(find "$src" -type f -name "*.jpg" -printf "%p %TY-%Tm-%Td_%.8TT\n" | sort -t ' ' -k 2 )

first_date=$(echo "$photo_files" | head -n 1 | cut -d ' ' -f 2 | cut -d '_' -f 1)
current_range="${first_date}_${first_date}"

previous_photo=$(echo "$photo_files" | head -n 1 | cut -d ' ' -f 1)
previous_date=$(echo "$photo_files" | head -n 1 | cut -d ' ' -f 2 | cut -d '_' -f 1)
photos_to_copy=""

function copy_files () {
		mkdir "${target}/$current_range"
		while IFS=' ' read -r file_name file_date; do
				cp "$file_name" "${target}/${current_range}/${file_date}.jpg"
		done < <(echo -e "$photos_to_copy" | sed -e '/^$/d')
		photos_to_copy=""
}

while IFS=' ' read -r photo_name photo_date; do
		prev_date_s=$(date -d "$previous_date" +"%s")		
		curr_date=$(echo "$photo_date" | cut -d '_' -f 1)
		curr_date_s=$(date -d "$curr_date" +"%s")
		diff_in_days=$(( ( "$curr_date_s" - "$prev_date_s") / (60*60*24) ))

		if [ $diff_in_days -eq 1 ]; then
				range_upper_bound=$(echo "$current_range" | cut -d '_' -f 2)
				next_date=$(date -d "$range_upper_bound + 1 day" + "%Y-%m-%d")
				current_range=$(echo "$current_range" | sed "s/(.*)_(.*)/\1_${next_date}/")
		elif [ $diff_in_days -gt 1 ]; then
				copy_files
				current_range="${curr_date}_${curr_date}"
		fi

		previous_date=$(echo "$photo_date" | cut -d '_' -f 1)
		previous_photo="$photo_name"
		photos_to_copy="${photos_to_copy}\n$photo_name ${photo_date}"
done < <(echo "$photo_files")

copy_files
