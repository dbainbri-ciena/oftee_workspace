#!/bin/bash

CHECK=0
if [ "$1" == "-check" ]; then
    CHECK=1
    shift
fi

MESSAGE=$1
shift
COMMAND=$*

RESULTS=$(mktemp)
$COMMAND 2>/dev/null > $RESULTS
ERR=$?
if [ $ERR -eq 0 -a $CHECK -eq 1 ]; then
  LOC=$(cat $RESULTS | grep "^Location" | awk '{print $2}' | sed -e 's|//|//karaf:karaf@|g' | tr -d '\r\n')
  FLOW=$(curl --fail -s $LOC)
  if [ $? -ne 0 ]; then
    ERR=1
  elif [ $(echo $FLOW | jq '.flows | length') -eq 0 ]; then
    ERR=1
  fi
fi

while [ $ERR -ne 0 ]; do
  echo "$MESSAGE"
  sleep 3
  $COMMAND 2>/dev/null > $RESULTS
  ERR=$?
  if [ $ERR -eq 0 -a $CHECK -eq 1 ]; then
    LOC=$(cat $RESULTS | grep "^Location" | awk '{print $2}' | sed -e 's|//|//karaf:karaf@|g' | tr -d '\r\n')
    FLOW=$(curl --fail -s $LOC)
    if [ $? -ne 0 ]; then
      ERR=1
    elif [ $(echo $FLOW | jq '.flows | length') -eq 0 ]; then
      ERR=1
    fi
  fi
done

rm -f $RESULTS
