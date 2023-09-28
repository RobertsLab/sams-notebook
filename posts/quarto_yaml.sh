#!/usr/bin/env bash

# This script is designed to create a markdown file that
# generates a formatted Jekyll header. It prompts the user
# for a post title and that title is utilized in the name of
# the markdown file that is created.

# It also prompts the user for tags/categories and launches the Atom text editing software after this information is provided.

# Tag/category formatting is specifically for the Basically Basic theme, which requires a Jekyll array format.
# Space-separated formatting for tags/categories are available in this git commit:
# https://github.com/kubu4/Scripts/blob/3712cdf474a8008dd4d314418f19f5579e360466/bash/jekyll_header.sh

# Expected output will be something like:
#
# ---
# layout: post
# title: First post test
# date: '2018-10-29'
# tags:
#   - temporary
# categories:
#   - delete
# ---


# To run, copy this file to your desired directory.
# Change to the directory where you just copied this file.
# In a terminal prompt, type:. jekyll_header.sh

# Set variables
post_date=$(date '+%F %H:%M')
filename_date=$(date '+%F')
md_line="---"
layout="layout: post"
title="title: "
date_line="date: "
tags="tags: "
categories="categories: "

IFS=';'

# Ask user for input
echo "Enter post title (use no punctuation):"
read post_title

echo "Enter tags (semi-colon separated)"
read -a tag_array

echo "Enter categories (semi-colon separated)"
read -a categories_array

# remove spaces from post-title and replace with hyphens
formatted_title=$(echo -ne "${post_title}" | tr [:space:] '-')

# save new filename using post_date and formatted_phrase variables.
new_md_file="$(echo -n "${filename_date}"-"${formatted_title}")".md

# Creates markdown file.
touch "${new_md_file}"

# prints formatted jekyll header utilizing post_date and user-entered post title and tags/categories.
# Tags and categories are formatted as Jekyll array - needed for Basically Basic theme.
# writes contents to new_md_file
printf "%s\n" "${md_line}" "${layout}" "${title}${post_title}" "${date_line}'${post_date}'" "${tags}" >> "${new_md_file}"
printf "  - %s\n" "${tag_array[@]}" >> "${new_md_file}"
printf "%s\n" "${categories}" >> "${new_md_file}"
printf "  - %s\n" "${categories_array[@]}" >> "${new_md_file}"
printf "%s\n" "${md_line}" >> "${new_md_file}"
printf "\n\n\n" >> "${new_md_file}"
printf "%s\n\n" "${md_line}" >> "${new_md_file}"
printf "%s\n\n" "#### RESULTS" >> "${new_md_file}"
printf "%s\n\n" "Output folder:" >> "${new_md_file}"
printf "%s\n\n" "- []()" >> "${new_md_file}"


# Open file with VS Code text editor.
code "${new_md_file}"
