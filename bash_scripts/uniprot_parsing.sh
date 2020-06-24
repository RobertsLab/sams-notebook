#!/bin/bash

### Bash script for batch retrieval of Gene Ontology terms from uniprot.org from
### a list of UniProt accessions.

input_file="$1"

# Initialize variables
accession=""
base_url="https://www.uniprot.org/uniprot/"
descriptor=""
error_count=0
go_id=""
go_line=""
response=""
uniprot_file=""

# Initialize arrays
go_ids_array=()

# Process UniProt accession list file.
while read -r line
do
  accession="${line}"
  go_ids_array=()
  uniprot_file="${accession}.txt"


  # Record GET response code and download target file.
  # --ciphers argument seems to be needed when using Ubuntu 20.04.
  response=$(curl \
  --write-out %{http_code} \
  --ciphers 'DEFAULT:@SECLEVEL=1' \
  --silent \
  --output "${uniprot_file}" \
  "${base_url}${uniprot_file}")

  # Vefrify file was able to be retrieved, based on succesful HTTP server response code
  if [[ "${response}" -eq 200 ]]; then

    # Process downloaded UniProt accession text file.
    while read -r line
    do

      # Get record line descriptor
      descriptor=$(echo "${line}" | awk '{print $1}' )

      # Capture second field for evaluation
      go_line=$(echo "${line}" | awk '{print $2}')

      # Print abbreviated protein name
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
    printf "%s\n" "${accession}" >> failed_accessions.txt
    rm "${uniprot_file}"
  fi

  # Prints accession <tab> GOID1;GOID2;GOIDn; followed by newline
  (IFS=; printf "%s\t%s" "${accession}" "${go_ids_array[*]}"; echo)


done < "${input_file}"

if [[ "${error_count}" -gt 0 ]]; then
  echo "${error_count} accessions were not processed."
  echo "Please see failed_accessions.txt file "
fi
