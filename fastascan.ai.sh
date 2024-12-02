#!/bin/bash

### Optional Argument 1: Directory to search for files (default: current folder)
X=${1:-"."} # Use provided directory or default to current directory

# Check if the directory exists and has read/execute permissions
if [[ ! -d "$X" || ! -r "$X" || ! -x "$X" ]]; then
    echo "ERROR: Directory does not exist or lacks permissions."
    exit 1
fi

# Optional Argument 2: Number of lines to display (default: 0)
N=${2:-0} # Default to 0 if no argument provided
if ! [[ "$N" =~ ^[0-9]*$ ]]; then
    echo "ERROR: Second argument must be a non-negative integer."
    exit 1
fi

### FOLDER REPORT
echo 
echo "--------------------------------------------------------------------------- FOLDER REPORT -----------------------------------------------------------------------------------------"
echo "FOLDER: $X"

## Find readable and valid FASTA/FA files
allfiles=$(find "$X" -name "*.fasta" -or -name "*.fa")
permissions_files=$(for file in $allfiles; do [[ -r $file ]] && echo $file; done) 
if [[ $(echo "$allfiles" | wc -w) -gt $(echo "$permissions_files" | wc -w) ]]; then
   echo "WARNING: Files with NO reading permissions have been excluded"
fi
files=$(for file in $permissions_files; do if grep -q "^>.*" $file || [[ ! -s $file ]]; then echo $file; fi; done) 
if [[ $(echo "$permissions_files" | wc -w) -gt $(echo "$files" | wc -w) ]]; then
   echo "WARNING: Files that do NOT follow the structure of FASTA/FA files have been excluded"
fi

## Count valid files
num_files=$(echo $files | wc -w)
  if [[ $num_files -eq 0 ]]; then
     echo "WARNING: There is NOT any fasta or fa file" 
  else 
     echo " - Number of FASTA/FA file(s): $num_files"
     
     ## Determine how many unique FASTA IDs they contain in total
     total_unique_IDs=$(for file in $files; do
     awk '/^>.*/{print $0}' "$file"; done | sort -u | wc -l)
     echo " - Number of unique FASTA IDs: $total_unique_IDs"  
     echo "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
     echo 
     echo "----------------------------------------------------------------------- FASTA/FA FILES REPORT -------------------------------------------------------------------------------------"
  fi

### FASTA/FA FILES REPORT
## Process each valid file
for file in $files; do
 echo "..................................................................................................................................................................................."
 echo "FILENAME: $file"
 
 # Check if the file is a symbolic link using '-h' option
 [[ -h $file ]] && echo " - Symlink: Yes" || echo " - Symlink: No"
 if [[ ! -s $file ]]; then
    echo "WARNING: the file is empty"
    continue
 fi
 
 # Count the number of sequences in the file 
 echo " - Number of sequences: $(grep -c "^>" $file)"
   
 # Calculate the total length of all sequences
 echo " - Total Sequences Length: $(awk '!/>/{gsub(/[- \n]/,"", $0); print $0}' $file | awk '{n+=length($0)} END {print n}')"
   
 ## Determine sequence type
 if grep -q '^[Mm]' $file; then 
    echo " - Type: Aminoacid Sequence" 
 elif grep -q '^[AaTtGgCcNnUu]' $file; then
    echo " - Type: Nucleotide Sequence" 
 else 
    echo " - Type: Unknown" 
 fi   

 # Display file content if N > 0
 if [[ $N -gt 0 ]]; then 
    echo
    echo FILE CONTENT:
    if [[ $(cat $file | wc -l) -le $((2 * $N)) ]]; then echo "The full content of the file is: "; echo; cat $file
    else echo "The first and last $N line(s) of the file are: "; echo; head -n $N $file; echo "..."; tail -n $N $file 
    fi
 fi 
echo 
done 
echo "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
