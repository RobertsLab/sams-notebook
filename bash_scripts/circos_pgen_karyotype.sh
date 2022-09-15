#!/bin/bash

# Script to create karyotype file for Circos

# Expects two inputs:

# 1. FastA index file
# 2. Abbreviation for species of interest

# Copy script to desired output directory and use like this:

# ./circos_pgen_karyotype.sh -f file.fasta.fai -s pg

# Creates output file formatted like:
# chr - pg1 1 0 89643857 chr1

# Set -f and -s flags for passing argument to script.
while getopts f:s: flag
do
	case "${flag}" in
		f) fasta_index=${OPTARG};;
		s) species_abbreviation=${OPTARG};;
	esac
done

# Set output filename
karyo_file=karyotype.${species_abbreviation}.txt

# Parse FastA index file and format output file.
while IFS=$'\t' read -r line
do
	# Capture scaffold number and strip leading '0'
	scaffold_num=$(echo "${line}" | awk -F"[_\t]" '{print $2}' | sed 's/^0//')

	scaffold_length=$(echo "${line}" | awk '{print $2}')
	printf "chr - %s\n" "${species_abbreviation}${scaffold_num} ${scaffold_num} 0 ${scaffold_length} chr${scaffold_num}"
done < "${fasta_index}" >> "${karyo_file}"
