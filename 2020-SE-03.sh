#!/bin/bash
#NE E NAPULNO VQRNA
if [ $# -ne 2 ];then
	echo 'Wrong number of arguments'
	exit 1
fi

if [ ! -d "$1" ] || [ ! -d "$2" ];then
	echo "$1 and $2 must be directories"
	exit 2
fi

repository="$1"
package="$2"

if ! find ${repository} -type f -name 'db' | grep -q '.' || ! find ${repository} -type d -name 'packages' | grep -q '.' ;then
	echo 'invalid stucture for repository'
	exit 3
fi

if ! find ${package} -type f -name 'version' | grep -q '.' || ! find ${package} -type d -name 'tree' | grep -q '.' ;then
	echo 'invalid stucture for package'
	exit 3
fi

package_version=$(cat $(find "$package" -type f -name 'version'))
#echo $package_version

PVS="$(basename "$package")-$package_version" #Package Version Structure
#echo $PVS

db=$(find ${repository} -type f -name 'db') #db="${repository}/db"
packages=$(find ${repository} -type d -name 'packages') #packages="${repository}/packages
#echo $db
#echo "This is $packages"
tree="$package/tree"

tar cfvJ "file.tar" "$tree" . > /dev/null 2>&1 
checksum=$(sha256sum "file.tar" | awk '{print $1}')
#echo $checksum

mv "file.tar" "./$checksum.tar.xz"

tarfile="$checksum.tar.xz"


if egrep "$PVS" "$db";then #proverqvame dali ima ime-versiq v db
	#tuka q ima, pravim proverka dali hesha e sushtiq
	#tr da zapazim starata hesh stoinost za da mahnem ot packages i da dobavim noviq tar
	old_checksum=$(egrep "$PVS" "$db" | awk '{print $2}')
	if [ "$checksum" == "$old_checksum" ];then
		echo 'All is up to date'
	else
		sed -i "s|^${PVS} .*| ${PVS} ${checksum}|" "$db"
		rm "${pachages}/${old_checksum}.tar.xz"
		mv "$tarfile" "$packages"
	fi
else
	#tuk q nqma znachi q dobavqme
	echo "$PVS $checksum" >> "$db"
	mv "$tarfile" "$packages"
	sort -o "$db" "$db"

fi

exit 0

