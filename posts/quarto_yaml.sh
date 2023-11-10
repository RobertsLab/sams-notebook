#!/usr/bin/env bash

# This script is designed to create a markdown file that
# generates a formatted Quarto YAML header. It prompts the user
# for a post title and that title is utilized in the name of
# the subsequent directory that is created.

# It also prompts the user for categories and launches the Atom text editing software after this information is provided.

# The index.qmd file is also put in draft mode. This prevents rendering until removed or set to draft: false.

# Expected output will be something like:
#
# ---
# author: Sam White
# toc-title: Contents
# toc-depth: 5
# toc-location: left
# layout: post
# title: qPCR - C.gigas PolyIC Diploid MgCl2
# date: '2023-08-17 06:38'
# tags: 
#   - qPCR
#   - CFX Connect
#   - Crassostrea gigas
#   - Pacific oyster
#   - polyIC
# categories: 
#   - 2023
#   - Miscellaneous
# draft: true
# ---


# To run, copy this file to your desired directory.
# Change to the directory where you just copied this file.
# In a terminal prompt, type:. quarto_yaml.sh

# Set variables
author="author: Sam White"
post_date=$(date '+%Y-%m-%d')
md_line="---"
title="title: "
date_line="date: "
categories="categories: "

# Sets engine to use knitr so first code chunk
# can be rendered if not R
engine="engine: knitr"

# Capture year
# Used for folder structure and categories
year=$(echo "${post_date}" | awk -F"-" '{print $1}')

# Ask user for input
echo "Enter post title (use no punctuation):"
read -r post_title

echo "Enter categories (semi-colon separated)"
OLDIFS="{$IFS}"

IFS=';' read -ra categories_array

IFS="${OLDIFS}"

# remove spaces from post-title and replace with hyphens
formatted_title=$(echo -ne "${post_title}" | tr "[:space:]" '-')

# save new filename using post_date and formatted_title variables.
mkdir --parents "${year}/${post_date}-${formatted_title}" && cd "$_" || exit


# prints formatted Quarto YAML header utilizing post_date and user-entered post title and categories.
# writes contents to index.qmd
printf "%s\n" \
"${md_line}" \
"${author}" \
"toc-title: Contents" \
"toc-depth: 5" \
"toc-location: left" \
"${title}${post_title}" \
"${date_line}'${post_date}'" \
"draft: true" \
"${engine}" \
"${categories}" \
>> index.qmd

# Adds categories
printf "  - %s\n" "${categories_array[@]}" >> index.qmd

printf "%s\n" "${md_line}" >> index.qmd

# Open file with code text editor.
code index.qmd
