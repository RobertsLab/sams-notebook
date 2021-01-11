#!/bin/bash

# A script to create mirrored versions of Roberts Lab
# GitHub-based notebooks for offline viewing and archiving.



## Identify files >100MB to avoid downloading them.

# Set field separator to newling to process output from find
IFS=$'\n'

# Initialize array
array=()

for item in $(find . -type f -size +100M)
do
  file=${item##*/}
  echo $file
  array+=($file)
done

# Restore field separator to default (space)
unset IFS

# Create comma-separated list for use in wget
# Use "${joined%,}" later on to remove trailing comma after last element
printf -v joined '%s,' "${array[@]}"
