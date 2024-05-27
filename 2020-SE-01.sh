#!/bin/bash

if [ $# -ne 2 ];then
	echo 'Wrong number of arguments'
	exit 1
fi

if [ ! -f $1 ];then
	echo 'First argument must be a regular file'
	exit 2
fi

if [ ! -e $1 ];then
	echo "$1 does not exist"
	exit 3
fi

if [ ! -d $2 ];then
	echo 'Second argument must be a directory'
	exit 4
fi

echo "hostname,phy,vlans,hosts,failover,VPN-3DES-AES,peers,VLAN Trunk Ports,license,SN,key" > "$1"

getValue(){
	cat "$file" | egrep "$1" | cut -d':' -f 2 | tr -s ' ' | tr -d ' '
}


while read file;do
	echo -n "$(basename ${file} | rev | cut -c 5- | rev)," >> "$1"
	echo -n "$(getValue "Maximum Physical Interfaces")," >> "$1"
	echo -n "$(getValue "VLANs")," >> "$1"
	echo -n "$(getValue "Inside Hosts")," >> "$1"
	echo -n "$(getValue "Failover")," >> "$1"
	echo -n "$(getValue "VPN-3DES-AES")," >> "$1"
	echo -n "$(getValue "\*Total VPN Peers")," >> "$1"
	echo -n "$(getValue "VLAN Trunk Ports")," >> "$1"
	echo -n "$(egrep 'license' "$file" | cut -d ' ' -f 5- | rev | cut -c 10- | rev )," >> "$1"
	echo -n "$(getValue "Serial Number"),">> "$1"
	echo "$(getValue "Running Activation Key")" >> "$1"
done < <(find "$2" -type f | egrep ".*.log$")
