#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Wrong number of integers."
  exit 1
fi

if ! egrep -q '^[+-]?[0-9]+$' <(echo "${1}"); then
  echo "Invalid argument"
  exit 2
fi

USERS=$(mktemp)
ps -eo user= | sort | uniq > "${USERS}"

while read USER; do
  USER_TOTAL_RSS=0
  while read PID RSS; do
    USER_TOTAL_RSS=$(("${USER_TOTAL_RSS}" + "${RSS}"))
    LAST_PID="${PID}"
  done < <(ps -u "${USER}" -o pid=,rss= | sort -n -k2)

  echo "Total "${USER_TOTAL_RSS}" RRS for user "${USER}"."

  if [ "${USER_TOTAL_RSS}" -gt "${1}" ]; then
  #kill -s TERM "${LAST_PID}"
  echo "Kill a process with PIID "${LAST_PID}" for user "${USER}"."
  fi
done < "${USERS}"

rm "${USERS}"
