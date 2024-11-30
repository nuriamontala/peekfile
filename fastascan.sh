#!/bin/bash

### Optional Argument 1: Directory to search for files (default: current folder)
if [[ -n $1 && -d $1 ]]; then # Check if the first argument is a non-empty valid directory
  X=$1  
else
  echo "WARNING: No directory was provided or the specified directory does NOT exist. The FASTA/FA file report will be generated in the current folder instead"
  X="."  
fi

if [[ ! -r $X || ! -x $X ]]; then
  echo "ERROR: Directory has no permissions"
  exit 1 # Exit the script with exit code 1, indicating an error (the directory has no permissions)
fi

### Optional Argument 2: Number of lines to display (default: 0)
if [[ -z $2 ]]; then N=0; else N=$2; fi

#Check if the variable N is not a valid positive integer (including 0) 
if ! [[ $N =~ ^[0-9]*$ ]]; then
  echo "ERROR: No valid number. The number must be an integer equal or higher than 0"
  exit 1 # Exit the script with exit code 1, indicating an error
fi # If the condition is false (N is a valid number), the script continues from here

### FOLDER REPORT
echo 
echo "--------------------------------------------------------------------------- FOLDER REPORT -----------------------------------------------------------------------------------------"
echo "FOLDER: $X"

## Find readable and valid FASTA/FA files
allfiles=$(find "$X" -name "*.fasta" -or -name "*.fa")
permissions_files=$(for file in $allfiles; do [[ -r $file ]] && echo $file; done) # Check if file has reading permissions (list files that are readable)
if [[ $(echo "$allfiles" | wc -w) -gt $(echo "$permissions_files" | wc -w) ]]; then
   echo "WARNING: Files with NO reading permissions have been excluded"
fi # If there are non-readable files, a warning message is displayed
files=$(for file in $permissions_files; do if grep -q "^>.*" $file || [[ ! -s $file ]]; then echo $file; fi; done) # Check which files are valid FASTA/FA files or are empty (list only the files that fulfills one of these conditions)
if [[ $(echo "$permissions_files" | wc -w) -gt $(echo "$files" | wc -w) ]]; then
   echo "WARNING: Files that do NOT follow the structure of FASTA/FA files have been excluded" # If some readable files do not match the expected FASTA/FA file structure, a warning message is displayed.
fi

## Count valid files
num_files=$(echo $files | wc -w)
  if [[ $num_files -eq 0 ]]; then
     echo "WARNING: There is NOT any fasta or fa file" 
  else 
     echo " - Number of FASTA/FA file(s): $num_files"
     
     ## Determine how many unique FASTA IDs they contain in total
     total_unique_IDs=$(for file in $files; do
     awk '/^>.*/{print $0}' "$file"; done | sort | uniq | wc -l)
     echo " - Number of unique FASTA IDs: $total_unique_IDs"  
     echo "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
     echo 
     echo "----------------------------------------------------------------------- FASTA/FA FILES REPORT -------------------------------------------------------------------------------------"
  fi

### FASTA/FA FILES REPORT
## Process each valid file
for file in $files; do
 echo "..................................................................................................................................................................................."
 echo
 echo "FILENAME: $file"
 
 # Check if the file is a symbolic link using '-h' option
 if [[ -h $file ]]; then echo " - Symlink: Yes"; else echo " - Symlink: No"; fi
 
 # Check if the file is not empty using '-s' option
 if [[ -s $file ]]; then
  
       # Count the number of sequences in the file 
       echo " - Number of sequences: $(awk '/^>.*/{print $0}' "$file"| wc -l) "
   
       # Calculate the total length of all sequences
       echo " - Total Sequences Length: $(awk '!/>/{gsub(/[- \n]/,"", $0); print $0}' $file | awk '{n+=length($0)} END {print n}')"
   
       ## Determine sequence type
       if grep -q '^[Mm]' $file; then 
           echo " - Type: Aminoacid Sequence" # If a line starts with Methionine amino acid, classify the file as Aminoacidic
       elif grep -q '^[AaTtGgCcNnUu]' $file; then 
           echo " - Type: Nucleotide Sequence" # If a line starts with nucleotide character, classify the file as Nucleotidic
        else 
           echo " - Type: Unknown" # If neither condition is met, classify the file as Unknown
       fi   
       echo
    
       # Check if the variable N is equal 0. If N is 0, skip the file processing and move to the next iteration of the loop
       if [[ $N -eq 0 ]]; then continue; fi
       echo
       echo FILE CONTENT:
       if [[ $(cat $file | wc -l) -le $((2 * $N)) ]]; then  # Count the total number of lines in the file. 
            echo "The full content of the file is: "; echo; cat $file # If the total number of lines in the file is less or equal to 2*N, display the entire content of the file
       else
            echo "The first and last $N line(s) of the file are: "; echo; head -n $N $file; echo "..."; tail -n $N $file # If the total number of lines in the file is greater to 2*N, display the first N lines and the last N lines of the files separated by "..."
       fi 
 else
   echo "WARNING: The file is empty"   # If file is empty, print a warning message
 fi
echo 
done 
echo "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
