#!/bin/bash

### Optional Argument 1: The folder where to search files (default: current folder)
# Check if a directory argument is provided ($1) and if it exists and is accessible (-d checks for directory existence and permissions)
if [[ -n $1 && -d $1 ]]; then 
  X=$1   # If the above condition is true, assign the provided directory to variable X
 else
  echo "WARNING: No directory was provided or the specified directory does not exist. The FASTA/FA file report will be generated in the current folder instead"
  X="."  # Set the variable X to the current directory (.)
fi

if [[ ! -r $X || ! -x $X ]]; then
  echo "ERROR: Directory has no permissions"
  exit 1 # Exit the script with exit code 1, indicating an error
fi

### Optional Argument 2: The number of lines (default: 0)
# Check if the second argument ($2) is empty (-z checks for an empty string)
if [[ -z $2 ]]; then 
  N=0  # If $2 is empty, assign the default value 0 to variable N
else
  N=$2 # If $2 is not empty, assign its value to variable N
fi

#Check if the variable N is not a valid positive integer (including 0)
if ! [[ $N =~ ^[0-9]+$ ]]; then
  echo "ERROR: No valid number. The number must be an integer equal or higher than 0"
  exit 1 # Exit the script with exit code 1, indicating an error
fi # If the condition is false (N is a valid number), the script continues from here

### FOLDER REPORT
echo 
echo "--------------------------------------------------------------------------- FOLDER REPORT -----------------------------------------------------------------------------------------"
echo "FOLDER: $X"

allfiles=$(find "$X" -name "*.fasta" -or -name "*.fa")
files=$(for file in $allfiles; do [[ -r $file ]] && echo $file; done) # control: determine if file has reading permissions
if [[ $(echo "$allfiles" | wc -w) -gt $(echo "$files" | wc -w) ]]; then
   echo "WARNING: Files with no reading permissions have been excluded"
fi

num_files=$(echo $files | wc -w)
  if [[ $num_files -eq 0 ]]; then
     echo "WARNING: There is NOT any fasta or fa file" 
  else 
     echo " - Number of FASTA/FA file(s): $num_files" 
  fi

## Determine how many unique FASTA IDs they contain in total
# Only calculate unique IDs if there is at least one FASTA/FA file
if [[ $num_files -ge 1 ]]; then 
 total_unique_IDs=$(for file in $files; do
  awk '/^>.*/{print $0}' "$file"; done | sort | uniq | wc -l) 
fi
  # Use 'awk' to extract lines starting with ">" (FASTA headers) from each file
  # Use 'sort' to sort the lines so duplicates are grouped together
  # Use 'uniq' to remove duplicate, leaving only unique lines
  # 'wc -l' counts the number of remaining lines, representing the total number of unique entries

# Print how many unique FASTA IDs, but only if the count was calculated (i.e. at least one FASTA/FA file was found) 
if [[ -n $total_unique_IDs ]]; then
 if [[ $total_unique_IDs -eq 0 ]]; then
  echo "WARNING: Files are empty or they do not contain FASTA IDs" 
 else
  echo " - Number of unique FASTA IDs: $total_unique_IDs"  
  echo "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo 
echo "----------------------------------------------------------------------- FASTA/FA FILES REPORT -------------------------------------------------------------------------------------"
 fi
fi

## Loop through each fasta/fa file found to determine if it is a symlink and information about its content
for file in $files; do
 echo "..................................................................................................................................................................................."
 # Print the name of the file evaluated
 echo "FILE: $file"
 
 # Check if the file is a symbolic link using '-h' option
 if [[ -h $file ]]; then
  echo " - Symlink: Yes"
 else
  echo " - Symlink: No"
 fi
 
 # Check if the file is not empty using '-s' option
 if [[ -s $file ]]; then
  
    #Count the number of sequences in the file (lines starting with ">" indicate sequence-headers in fasta/fa files)
    num_seq=$(awk '/^>.*/{print $0}' "$file"| wc -l)
  
    # Check if the no sequences were found
    if [[ $num_seq -eq 0 ]]; then
       echo "WARNING: FASTA/FA file is not empty, but does not contain any sequences" # If no sequences are found, print a warning message 
    else # If sequences are found, print the count
       echo " - Number of sequences: $num_seq"
   
       # Calculate the total length of all sequences, excluding headers and unwanted characters
       sequence_length=$(awk '!/>/{gsub(/[- \n]/,"", $0); print $0}' $file | awk '{n+=length($0)} END {print n}')
           # !/>/: Process only lines that do not start with ">" (sequence lines)
           # gsub(/[- \n]/, "", $0): Remove hyphens, spaces, and newlines from sequence lines
           # n+=length($0): Add the length of the current line to the total
           # END {print n}: Print the total sequence length after processing all lines
   
       # Print the total sequence length
       echo " - Total Sequences Length: $sequence_length"
   
       ## Determine sequence type
       # Check if the file contains any lines that do not start with ">" (Detection of non-header lines)
       if grep -q '^[^>]' $file; then
   
           if grep -q '^[Mm]' $file; then 
                echo " - Type: Aminoacid Sequence" # If a line starts with Methionine amino acid, classify the file as Aminoacidic
           elif grep -q '^[AaTtGgCcNnUu]' $file; then 
                echo " - Type: Nucleotide Sequence"     # If a line starts with nucleotide character, classify the file as Nucleotidic
           else 
                echo " - Type: Unknown" # If neither condition is met, classify the file as Unknown
           fi   
       fi 
    fi 
  
    # Check if the variable N is equal 0. If N is 0, skip the file processing and move to the next iteration of the loop
    if [[ $N -eq 0 ]]; then continue; fi
    echo
    echo FILE CONTENT
    if [[ $(cat $file | wc -l) -le $((2 * $N)) ]]; then  # Count the total number of lines in the file. 
       echo "The full content of the file is: "    # If the total number of lines in the file is less or equal to 2*N, display the entire content of the file
       echo
       cat $file
    else
       echo "The first and last $N line(s) of the file are: "    # If the total number of lines in the file is greater to 2*N, display the first N lines and the last N lines of the files separated by "..."
       echo 
       head -n $N $file
       echo "..."
       tail -n $N $file
     fi 
 else
   echo "WARNING: The file is empty"   # If file is empty, print a warning message
 fi

 echo "..................................................................................................................................................................................."
 echo
 echo
done   
echo "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
