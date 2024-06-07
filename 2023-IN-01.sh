#!/bin/bash

if [ $# -eq 1 ] && [ "$1" == "autoconf" ];then
	echo 'yes'
	exit 0
fi

if [ $# -gt 1 ];then 
	echo "arguments"
	exit 1
fi

CTRLSLOTS="0 1"

if [ -z "$CTRLSLOTS" ];then
	CTRLSLOTS='0'
fi

SLOTS="$CTRLSLOTS"

OUTPUT=$(mktemp)

for SLOT in ${SLOTS};do
	cat "$SLOT.txt" | awk '{ 
	if ($1=="Smart") {slot = $6; model=$3}
	if ($1 == "Array") { array=$2 } 
	if ($1 == "Unassigned") { array="UN" } 
	if ($1 == "physicaldrive") { disk=$2 }
	if ($1 == "Current" && $2=="Temperature") 
	{ print slot, model,array,disk,$4}
	}' >> "$OUTPUT"
done

if [ "$1" == "config" ];then
	echo "graph_title SSA drive temperatures"
	echo "graph_vlabel Celsius"
	echo "graph_category sensors"
	echo "graph_info This graph shows SSA drive temp"

	while read slot model array disk temp;do
	diskWD=$(echo "$disk"|tr -d ':'|tr -d ' ')
	IND="SSA$slot$model$array$diskWD"
	LABEL="SSA$slot $model $array $disk"
	echo "${IND}.label ${LABEL}"
	echo "${IND}.type GAUGE"
	done < "$OUTPUT"

elif [ $# -eq 0 ];then 
	while read slot model array disk temp;do
		diskWD=$(echo "$disk" | tr -d ':'|tr -d ' ')
		IND="SSA$slot$model$array$diskWD"
		echo "${IND}.value $temp"
	done < "$OUTPUT"

else 
	exit 1
fi

exit 0
