#!/bin/bash
       
for file in $@
 do
  line_count=$(cat $file | wc -l)
  if [[ $line_count -eq 0 ]]
    then
      echo $file: The file has 0 lines
  elif [[ $line_count  -eq 1 ]]
    then
      echo $file: The file has 1 line
  else
      echo $file: The file has $line_count lines
fi
done
