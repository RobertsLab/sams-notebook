#!/bin/bash

# Find all index.qmd files recursively
find . -name "index.qmd" | while read -r file; do
  # Process each file
  awk '
  BEGIN { in_categories = 0 }
  /^categories:/ { in_categories = 1; print; next }
  in_categories && /^  - / {
    # Extract the category and check if it needs quotes
    category = substr($0, 5)
    if (category !~ /^".*"$/) {
      $0 = "  - \"" category "\""
    }
    print
    next
  }
  in_categories && !/^  - / { in_categories = 0 }
  { print }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done