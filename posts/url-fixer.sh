#!/bin/bash

# Specify the root directory where you want to start the search
root_directory="./"

# Use 'grep' to find all URLs with the pattern and extract the dates
urls_with_pattern=$(grep -Eroh "$root_directory" -e 'https://robertslab\.github\.io/sams-notebook/posts/[0-9]{4}-[0-9]{2}-[0-9]{2}')

# Loop through the found URLs and perform the replacement
for url in $urls_with_pattern; do
    # Extract the date part from the URL
    date_part=$(echo "$url" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
    
    # Extract year
    year=$(echo "$url" | grep -oE '[0-9]{4}')
    # Use 'sed' to perform the URL replacement
    new_url=$(echo "$url" | sed "s#https://robertslab\.github\.io/sams-notebook/posts/$date_part#https://robertslab.github.io/sams-notebook/posts/$year/$date_part#g")
    
    # Rename the file or update the URL in the file content
    if [ -f "$url" ]; then
        mv "$url" "$new_url"
    else
        sed -i "s#$url#$new_url#g" $(grep -rl "$url" "$root_directory")
    fi
done
