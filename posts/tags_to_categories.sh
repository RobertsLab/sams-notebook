#!/bin/bash

# Find all index.qmd files and process them
find . -type f -name "index.qmd" -print0 | while IFS= read -r -d '' file; do
    echo "Processing $file..."
    
    # Remove the 'tags:' line and save it in a variable
    tags=$(sed -n '/^tags:/,/^[^-]/p' "$file")
    sed -i '/^tags:/,/^[^-]/d' "$file"
    
    # Find the 'categories:' line and append the tags below it
    sed -i '/^categories:$/a '"$tags"'' "$file"
    
    echo "Done processing $file"
done

echo "All files processed."
