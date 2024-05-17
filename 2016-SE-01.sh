#!/bin/bash

if [ $# -ne 1 ]; then
  echo "The script takes one parameter only!"
  exit 1
fi

if [ ! -d "$1" ];then
  echo "Must be a directory!"
  exit 2
fi

DIR="$1"

find "${DIR}" -xtype l
 
