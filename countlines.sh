 #!/bin/bash
       
if [[ $(cat $1 | wc -l) -eq 0 ]]
 then
   echo $1: The file has 0 lines
elif [[ $(cat $1 | wc -l) -eq 1 ]]
 then
   echo $1: The file has 1 line
else
   echo $1: The file has $(cat $1 | wc -l) lines
fi
