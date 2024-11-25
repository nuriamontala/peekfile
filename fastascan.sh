#!/bin/bash

### Optional Argument 1: The folder where to search files (default: current folder)
# Check if a directory argument is provided ($1) and if it exists and is accessible (-d checks for directory existence and permissions)
if [[ -n $1 && -d $1 ]]; then 
  X=$1   # If the above condition is true, assign the provided directory to variable X
 else
  echo "WARNING: No directory was provided, or the specified directory does not exist or lacks the necessary permissions. The FASTA/FA file report will be generated in the current folder instead"
  X="."   # Set the variable X to the current directory (.)
fi

### Optional Argument 2: The number of lines (default: 0)
# Check if the second argument ($2) is empty (-z checks for an empty string)
if [[ -z $2 ]]; then 
  N=0  # If $2 is empty, assign the default value 0 to variable N
 else
  N=$2 # If $2 is not empty, assign its value to variable N
fi

### Checking that optional arguments work correctly
find $X -name "*.fasta" -or -name "*.fa" | head -n $N
