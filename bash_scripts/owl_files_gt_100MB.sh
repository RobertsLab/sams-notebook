#!/bin/bash

# Script to create list of files >100MB
# Outputs a newline-delimited text file
# of unique filenames of sizes >100MB

# Set variables
web_dir=/volume1/web/
out_dir="${web_dir}testing"
out_file="${out_dir}/owl_files_gt_100MB.txt"

# Create temporary file
# mktemp requires a filename with at least two consecutive 'XX's if specifying
# a directory and filename
tmp_file=$(mktemp -p ${out_dir} tmp.100MB.list.XXXXXX)

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
