#!/bin/bash

# Script to create list of files >100MB
# Outputs a newline-delimited text file
# of unique filenames of sizes >100MB

# Set variables
out_file=owl_files_gt_100MB.txt
tmp_file="$(mktemp)"
web_dir=/volume1/web/testing

# Change to web directory
cd "${web_dir}"

# Find files >100MB and write output to file.
# Set field separator to newling to process output from find
IFS=$'\n'

for item in $(find . -type f -size +100M)
do
  # Strip leading path from result
  filename=${item##*/}
  echo "$filename"
done \
| sort --unique \
>> "${tmp_file}"

# Restore field separator to default (space)
unset IFS

# Update list and remove tmp_file
rsync --remove-source-files "${tmp_file}" "${out_file}"

# Change permissions on file
chmod 774 "${out_file}"
