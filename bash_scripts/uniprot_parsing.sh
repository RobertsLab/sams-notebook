#!/bin/bash

### Bash script for batch retrieval of Gene Ontology terms from uniprot.org from
### a list of UniProt accessions.

# Initialize variables
base_url="https://www.uniprot.org/uniprot/"
descriptor=""
error_count=0
go_line=""
response=""
uniprot_file=""

# Initialize arrays
go_ids_array=()

# Process UniProt accession list file.
while read -r line
do
  uniprot_file="${line}.txt"

  # Record GET response code and download target file.
  response=$(curl --write-out %{http_code} --silent --output "${uniprot_file}" https://www.uniprot.org/uniprot/"${uniprot_file}")

  # Vefrify file was able to be retrieved, based on succesful HTTP server response code
  if [[ "${response}" -eq 200 ]]; then

    # Process downloaded UniProt accession text file.
    while read -r line
    do

      # Get record line descriptor
      descriptor=$(echo "${line}" | awk '{print $1}' )

      # Capture second field for evaluation
      go_line=$(echo "${line}" | awk '{print $2}')

      # Print abbreviated protin name
      if [[ "${descriptor}" == "ID" ]]; then
        echo "${line}" | awk '{print $2}'
      fi

      # Append GO IDs to array
      if [[ "${go_line}" == "GO;" ]]; then
        go_id=$(echo "${line}" | awk '{print $3}')
        go_ids_array+=("${go_id}")
      fi
    done < "${uniprot_file}"

  else
    error_count=$((error_count+1))
    printf "%s\n" "${line}" >> failed_accessions.txt
    rm "${uniprot_file}"
  fi
done < "$1"
