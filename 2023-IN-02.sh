target_dir=$1

if [ ! -d "$target_dir" ]; then
		echo "Not a valid dir"
fi

files=$(find "$target_dir" -maxdepth 1 -type f -printf "%p %i\n")

temp_dir=$(mktemp -d)
inode_temp_dir=$(mktemp -d)

while IFS=' ' read -r file_name inode; do
		checksum=$(sha256sum "$file_name" | cut -d ' ' -f 1)
		echo "$file_name $inode" >> "${temp_dir}/${checksum}"

		echo "$file_name" >> "${inode_temp_dir}/${inode}"

done < <(echo "$files")

checksums=$(find "$temp_dir" -type f)

while IFS= read -r checksum; do
		count_per_inode=$(cat "$checksum" | cut -d ' ' -f 2 | sort | uniq -c)
		group_inodes=$(echo "$count_per_inode" | awk '{if ($1 > 1) print $2}')
		single_inodes=$(echo "$count_per_inode" | awk '{if ($1 == 1) print $2}')
		copies_count=$(echo "$single_inodes" | wc -l)
		
		if [ $copies_count -gt 1 ] && [ -z $group_inodes ]; then
				tail -n +2 "$checksum" | cut -d ' ' -f 1
		elif [ ! -z "$group_inodes" ]; then
				while IFS= read -r inode; do
						head -n 1 "$inode_temp_dir/$inode"
				done < <(echo "$group_inodes")

				if [ $copies_count > 1 ]; then
						while IFS= read -r inode; do
								cat "$inode_temp_dir/$inode"
						done < <(echo "$single_inodes")
				fi
		fi
		
		echo "Copies Count: $copies_count"
		echo "Groups: $group_inodes"
done < <(echo "$checksums")

#second

#!/bin/bash

[[ $# -ne 1 ]] && echo "1 param expected" && exit 1
[[ ! -d $1 ]] && echo "the 1st param must be a dir" && exit 2

files=$(find $1 -type f -printf '%i %n %p\n')

DIR=$(mktemp -d)
while read inode count name; do
	sha=$(sha256sum $name | cut -d ' ' -f 1)

	echo "$inode $count" >> $DIR/$sha
done < <(echo "$files")

files=$(find $DIR -type f)

while read sha; do
	file=$(cat $sha | sort -u)

	ones=$(echo "$file" | egrep " 1$" | cut -d ' ' -f 1)
	notOnes=$(echo "$file" | egrep -v " 1$" | cut -d ' ' -f 1)

	if [[ -z $notOnes ]]; then
		toDelete=$(echo "$ones" | tail -n +2)
		
		[[ -z $toDelete ]] && echo "File with inode number $ones is just 1" && continue

		while read inode; do
			find $1 -type f -inum "$inode"
		done < <(echo "$toDelete")
	elif [[ -z $ones ]]; then
		while read inode; do
			find $1 -type f -inum "$inode" | head -n 1
		done < <(echo "$notOnes")
	else
		while read inode; do
			find $1 -type f -inum "$inode"
		done < <(echo "$ones")

		while read inode; do
			find $1 -type f -inum "$inode" | head -n 1
		done < <(echo "$notOnes")
	fi
done < <(echo "$files")

rm -r $DIR
