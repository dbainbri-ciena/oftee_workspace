#!/bin/bash

MESSAGE=$1
shift
COMMAND=$*

$COMMAND 2>/dev/null
while [ $? -ne 0 ]; do
  echo "$MESSAGE"
  sleep 3
  $COMMAND 2>/dev/null
done
