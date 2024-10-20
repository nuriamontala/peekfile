#!/bin/bash

input_file=$1

head -n 3 "$input_file"
echo "..."
tail -n 3 "$input_file"
