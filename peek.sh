#!/bin/bash
       
if [[ -z $2 ]]
 then 
  lines=3
 else
  lines=$2
fi
       
head -n $lines $1
echo "..."
tail -n $lines $1
