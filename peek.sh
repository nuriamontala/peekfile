#!/bin/bash
       
if [[ -z $2 ]]
 then 
  lines=3
 else
  lines=$2
fi

if [[ $(cat $1 | wc -l) -le $((2 * $lines)) ]]
 then
   cat $1
else
   echo Warning: The file contains more than $lines lines
   head -n $lines $1
   echo "..."
   tail -n $lines $1
fi
