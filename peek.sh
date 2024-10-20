#!/bin/bash

input_file=$1

head -n $2 "$input_file"
echo "..."
tail -n $2 "$input_file"
