#!/bin/bash

### Optional Argument 1: The folder where to search files (default: current folder)
# Check if a directory argument is provided ($1) and if it exists and is accessible (-d checks for directory existence and permissions)
if [[ -n $1 && -d $1 ]]; then 
  X=$1   # If the above condition is true, assign the provided directory to variable X
 else
  echo "WARNING: No directory was provided, or the specified directory does not exist or lacks the necessary permissions. The FASTA/FA file report will be generated in the current folder instead"
  X="."  # Set the variable X to the current directory (.)
fi

### Optional Argument 2: The number of lines (default: 0)
# Check if the second argument ($2) is empty (-z checks for an empty string)
if [[ -z $2 ]]; then 
  N=0  # If $2 is empty, assign the default value 0 to variable N
 else
  N=$2 # If $2 is not empty, assign its value to variable N
fi

### REPORT
echo "---------------------------------------------------------- FASTA/FA FILES REPORT ----------------------------------------------------------------------------------"
## Search for files with names ending in .fasta -or .fa
files=$(find "$X" -name "*.fasta" -or -name "*.fa")

## Number of fasta/fa files
# Search for files with names ending in .fasta or .fa and count the number of matching files
num_files=$(find "$X" -name "*.fasta" -or -name "*.fa" | wc -l)

# Print the number of fasta/fa files in a grammarly-corrected form
if [[ $num_files -eq 0 ]]; then
  echo "  - There is not any fasta or fa file" # No files found
elif [[ $num_files -eq 1 ]]; then
  echo "  - There is one fasta/fa file" # Exactly one file found
else
  echo "  - There are $num_files fasta/fa files" # More than one file found
fi

## Determine how many unique FASTA IDs they contain in total
# Only calculate unique IDs if there is at least one FASTA/FA file. If there is no FASTA/FA file, the information on how many unique FASTA IDs they contain cannot given
if [[ $num_files -ge 1 ]]; then 
 total_unique_IDs=$(for file in $files; do
  awk '/^>.*/{print $0}' "$file"; done | sort | uniq | wc -l) 
  # Use 'awk' to extract lines strating with ">" (FASTA headers) from each file
  # Use 'sort' to sort the lines so duplicates are grouped together
  # Use 'uniq' to remove duplicate, leaving only unique lines
  # 'wc -l' counts the number of remaining lines, representing the total number of unique entries
fi

# Print how many unique FASTA IDs, but only if the count was calculated (i.e. at leat one FASTA/FA file was found) 
if [[ -n $total_unique_IDs ]]; then
 # Print the number of unique FASTA IDs in a grammarly-corrected form
 if [[ $total_unique_IDs -eq 0 ]]; then
  echo "WARNING: Files are empty or they do not contain fasta IDs" # Files are present but they do not contain FASTA IDs
 elif [[ $total_unique_IDs -eq 1 ]]; then
  echo "  - There is one unique fasta ID" # Exactly one unique FASTA ID found
 else
  echo "  - There are $total_unique_IDs unique fasta IDs" # More than one unique FASTA ID found
 fi
fi


