import os

# Define the YAML fields to add
yaml_fields_to_add = """
author: Sam White
toc-title: Contents
toc-depth: 5
toc-location: left
"""

# Function to process a single .qmd file
def process_qmd_file(file_path):
    # Read the content of the file
    with open(file_path, 'r') as file:
        content = file.read()

    # Split the content into lines
    lines = content.split('\n')

    # Find the line index where the YAML header ends (after '---')
    yaml_end_index = 0
    for i, line in enumerate(lines):
        if line.strip() == '---':
            yaml_end_index = i
            break

    # Join the lines of the existing YAML header
    existing_yaml_header = '\n'.join(lines[:yaml_end_index+1])

    # Join the lines of the content after the YAML header
    content_after_yaml = '\n'.join(lines[yaml_end_index+1:])

    # Add the new YAML fields inside the existing YAML header
    updated_yaml_header = existing_yaml_header.strip() + '\n' + yaml_fields_to_add.strip()

    # Combine the updated YAML header and content
    updated_content = updated_yaml_header + '\n' + content_after_yaml

    # Write the updated content back to the file
    with open(file_path, 'w') as file:
        file.write(updated_content)

# Traverse through the directory tree
for root, dirs, files in os.walk('.'):
    for file_name in files:
        # Check if the file is an 'index.qmd' file
        if file_name == 'index.qmd':
            # Get the full path of the file
            file_path = os.path.join(root, file_name)

            # Process the 'index.qmd' file
            process_qmd_file(file_path)

print("YAML fields added to all 'index.qmd' files.")
