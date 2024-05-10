#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Wrong number of integers."
  exit 1
fi

if ! egrep -q '^[+-]?[0-9]+$' <(echo "${1}"); then
  echo "Invalid argument"
  exit 2
fi

