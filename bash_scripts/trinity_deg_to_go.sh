#!/bin/bash

#############################################################
# Script to "flatten" Trinity edgeR GOseq enrichment format
# so each line contains a single gene/transcript ID
# and associated GO term
#############################################################

# Enable globstar for recursive searching
shopt -s globstar

# Declare variables
output_file=""
wd=$(pwd)

# Input file
## Expects Trinity edgeR GOseq enrichment format:
## category	over_represented_pvalue	under_represented_pvalue	numDEInCat	numInCat	term	ontology	over_represented_FDR	go_term	gene_ids
## Field 10 (gene_ids) contains comma separated gene_ids that fall in the given GO term in the "category" column

for goseq in **/*UP.subset*.enriched
do
	# Capture path to file
	dir=${goseq%/*}

	cd "${dir}" || exit

	tmp_file=$(mktemp)

	# Count lines in file
  linecount=$(cat "${goseq}" | wc -l)

	# If file is not empty
  if (( "${linecount}" > 1 ))
	then
		output_file="${goseq}.flattened"


		# 1st: Convert comma-delimited gene IDs in column 10 to tab-delimited
		# Also, set output (OFS) to be tab-delimited
		# 2nd: Convert spaces to underscores and keep output as tab-delimited
		# 3rd: Sort on Trinity IDs (column 10) and keep only uniques
		awk 'BEGIN{FS="\t";OFS="\t"} {gsub(/, /, "\t", $10); print}' "${goseq}" \
		| awk 'BEGIN{F="\t";OFS="\t"} NR==1; NR > 1 {gsub(/ /, "_", $0); print}' \
		> "${tmp_file}"

		# Identify the first line number which contains a gene_id
		begin_goterms=$(grep --line-number "TRINITY" "${tmp_file}" \
		| awk '{for (i=1;i<=NF;i++) if($i ~/TRINITY/) print i}' \
		| sort --general-numeric-sort --unique | head -n1)

		# "Unfolds" gene_ids to a single gene_id per row
		while read -r line
		do
			# Capture the length of the longest row
			max_field=$(echo "$line" | awk -F "\t" '{print NF}')

			# Retain the first 8 fields (i.e. categories)
			fixed_fields=$(echo "$line" | cut -f1-8)

			# Since not all the lines contain the same number of fields (e.g. may not have GO terms),
			# evaluate the number of fields in each line to determine how to handle current line.

			# If the value in max_field is less than the field number where the GO terms begin,
			# then just print the current line (%s) followed by a newline (\n).
			if (( "$max_field" < "$begin_goterms" ))
			then
				printf "%s\n" "$line"
			else goterms=$(echo "$line" | cut -f"$begin_goterms"-"$max_field")

		  # Assign values in the variable "goterms" to a new indexed array (called "array"),
		  # with tab delimiter (IFS=$'\t')
		  IFS=$'\t' read -r -a array <<<"$goterms"

		  # Iterate through each element of the array.
		  # Print the first n fields (i.e. the fields stored in "fixed_fields") followed by a tab (%s\t).
		  # Print the current element in the array (i.e. the current GO term) followed by a new line (%s\n).
		  for element in "${!array[@]}"
		  do
			  printf "%s\t%s\n" "$fixed_fields" "${array[$element]}"
		  done
		  fi
		done < "${tmp_file}" > "${output_file}"
	fi

  # Cleanup
  rm "${tmp_file}"

	cd "${wd}" || exit
done
