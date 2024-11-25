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
echo "------------------------------------------------------------- FASTA/FA FILES REPORT -----------------------------------------------------------------------------------------"
## Search for files with names ending in .fasta -or .fa
files=$(find "$X" -name "*.fasta" -or -name "*.fa")

## Number of fasta/fa files
# Search for files with names ending in .fasta or .fa and count the number of matching files
num_files=$(find "$X" -name "*.fasta" -or -name "*.fa" | wc -l)

# Print the number of fasta/fa files in a grammarly-corrected form
if [[ $num_files -eq 0 ]]; then
  echo "WARNING: There is NOT any fasta or fa file" # No files found
elif [[ $num_files -eq 1 ]]; then
  echo "- There is one fasta/fa file" # Exactly one file found
else
  echo "- There are $num_files fasta/fa files" # More than one file found
fi

## Determine how many unique FASTA IDs they contain in total
# Only calculate unique IDs if there is at least one FASTA/FA file. If there is no FASTA/FA file, the information on how many unique FASTA IDs they contain cannot given
if [[ $num_files -ge 1 ]]; then 
 total_unique_IDs=$(for file in $files; do
  awk '/^>.*/{print $0}' "$file"; done | sort | uniq | wc -l) 
  # Use 'awk' to extract lines starting with ">" (FASTA headers) from each file
  # Use 'sort' to sort the lines so duplicates are grouped together
  # Use 'uniq' to remove duplicate, leaving only unique lines
  # 'wc -l' counts the number of remaining lines, representing the total number of unique entries
fi

# Print how many unique FASTA IDs, but only if the count was calculated (i.e. at least one FASTA/FA file was found) 
if [[ -n $total_unique_IDs ]]; then
 # Print the number of unique FASTA IDs in a grammarly-corrected form
 if [[ $total_unique_IDs -eq 0 ]]; then
  echo "WARNING: Files are empty or they do not contain FASTA IDs" # Files are present but they do not contain FASTA IDs
 elif [[ $total_unique_IDs -eq 1 ]]; then
  echo "- There is one unique FASTA ID" # Exactly one unique FASTA ID found
 else
  echo "- There are $total_unique_IDs unique FASTA IDs" # More than one unique FASTA ID found
 fi
fi

echo

## Loop through each fasta/fa file found to determine if it is a symlink and information about its content
for file in $files; do
 echo "............................................................................................................................................................................"
 # Print the name of the file evaluated
 echo "                                                                  File: $file                                                                                           "
 # Check if the file is a symbolic link using '-h' option
 if [[ -h $file ]]; then
  echo "- Symlink: Yes"
 else
  echo "- Symlink: No"
 fi
 
 # Check if the file is not empty using '-s' option
 if [[ -s $file ]]; then
 
  #Count the number of sequences in the file (lines starting with ">" indicate sequences in fasta/fa files)
  num_seq=$(awk '/^>.*/{print $0}' "$file"| wc -l)
  
  # Check if the no sequences were found
  if [[ $num_seq -eq 0 ]]; then
  
   # If no sequences are found, print a warning message 
   echo "WARNING: FASTA/FA file is not empty, but does not contain any sequences"
  
  else
   # If sequences are found, print the count
   echo "- Number of sequences: $num_seq"
   
   # Calculate the total length of all sequences, excluding headers and unwanted characters
   sequence_length=$(awk '!/>/{gsub(/[- \n]/,"", $0); print $0}' $file | awk '{n+=length($0)} END {print n}')
   # !/>/: Process only lines that do not start with ">" (sequence lines)
   # gsub(/[- \n]/, "", $0): Remove hyphens, spaces, and newlines from sequence lines
   # n+=length($0): Add the length of the current line to the total
   # END {print n}: Print the total sequence length after processing all lines
   
   # Print the total sequence length
   echo "- Total Sequences Length: $sequence_length" 
   
  fi 
  
  # Check if the file containe any lines that do not start with ">" (Detection of non-header lines)
  if grep -q '^[^>]' $file; then
   
   # Check if any non-header lines stat with "M" or "m", which represent Methionine aminoacid (coded for by the start codon)
   if grep -q '^[Mm]' $file; then 
   
    # If a line starts with Methionine aminoacid, classify the file as Aminoacidic
    echo "- Type: Aminoacid Sequence"
    
   # Check if any non-header lines start with nucleotide characters (A, T, G, C, N, U)
   elif grep -q '^[AaTtGgCcNnUu]' $file; then 
   
    # If a line starts with nucleotide characters, classify the file as Nucleotidic
    echo "- Type: Nucleotide Sequence"
    
   else 
   
    # If neither condition is met, classify the file as Unknown
    echo "- Type: Unknown"
   fi   
  fi 
  
  
  # Check if the variable N is equal 0. If N is 0, skip the file processing and move to the next interation of the loop
  if [[ $N -eq 0 ]]; then continue; fi
 
  echo 
  # Count the total number of lines in the file. 
  if [[ $(cat $file | wc -l) -le $((2 * $N)) ]]; then
  
   # If the total number of lines in the file is less or equal to 2*N, display the entire content of the file
   echo "The full content of the file is: "
   cat $file
 
  else
  
   # If the total number of lines in the file is greater to 2*N, display the first N lines and the last N lines of the files separeted by "..."
   echo "The first $N line(s) and the last $N line(s) of the file are: "
   head -n $N $file
   echo "..."
   tail -n $N $file
  fi 
  
 else
 
  # If the file is empty, print a warning message
  echo "WARNING: The file is empty"
 fi
 
 
 
 # Print separator lines for readability
 echo "............................................................................................................................................................................"
 echo
 echo
done   

echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------" 
 

