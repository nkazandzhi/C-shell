#!/bin/bash

if [ $# -ne 3 ];then
	echo 'Wrong number of arguments'
	exit 1
fi

#TRQBVA DA SE DOBAVQT OSHTE PROVERKI

BASE="base.csv"
PREFIX="prefix.csv"

RESULT=""

MULTIPLY=$(egrep -w "$2" "$PREFIX" | cut -d ',' -f 3)
DIGIT=$(echo "$1 * $MULTIPLY" | bc)
RESULT+=$DIGIT

MEASURE=$(egrep -w "$3" "$BASE" | cut -d ',' -f 3)
UNIT_NAME=$(egrep -w "$3" "$BASE" | cut -d ',' -f 1)

RESULT+=" $3 ($MEASURE, $UNIT_NAME)"
echo $RESULT
