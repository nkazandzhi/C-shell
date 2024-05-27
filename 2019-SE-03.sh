#!/bin/bash

if [ $# -ne 1 ];then
	echo 'Wrong number of arguments'
	exit 1
fi

if [ ! -d $1 ]; then 
	echo 'Must be a dir'
	exit 2

fi

touch helpFile
mkdir -p extracted

while read line;do
	if [ $(egrep $(sha256sum $line) helpFile) ];then 
		continue
	fi

	if [ ! $(egrep "[[:alnum:]]{64} $line" helpFile) ];then
		echo "$(sha256sum $line)" >> helpFile
	else
		sed -i -r "S|^[[:alnum:]]{64} ${line}$|$(sha256sum $line|g)" helpFile
	fi

	if [ $(tar -tf $line | grep "meow.txt") ];then
		temp_dir=$(mktemp -d)
		tar -xvf $line -C "$temp_dir"

		while read file;do
			name=$(basename $line|cut -d'_' -f1)
			timestamp=$(basename $line | cut -d'-' -f2 | cut -d'.' -f1)
			mv "$file" "extracted/${name}_${timestamp}.txt"
		done < <(find "$temp_dir" -name "meow.txt")

		rm -rf "$temp_dir"
	fi
done < <(find "$1" -type f | egrep "^[^_]*_report-[0-9]*.tgz$")

exit 0
