#!/bin/bash

### Bash script for batch retrieval of Gene Ontology terms from uniprot.org from
### a list of UniProt accessions.

### Expected input is a newline-separated file of UniProt accessions.
### Output is: UniProt_accession<tab>GOID1;GOID2;..GOIDn;

### Run script like this: ./uniprot2go.sh accessions.txt > uniprot2go_out.txt

# Save first argument as variable.
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


  # Record HTTP GET response code and download target file.
  # --ciphers argument seems to be needed when using Ubuntu 20.04.
  response=$(curl \
  --write-out %{http_code} \
  --ciphers 'DEFAULT:@SECLEVEL=1' \
  --silent \
  --output "${uniprot_file}" \
  "${base_url}${uniprot_file}")

  # Verify file was able to be retrieved, based on succesful HTTP server response code = 200
  if [[ "${response}" -eq 200 ]]; then

    # Process downloaded UniProt accession text file.
    while read -r line
    do

      # Get record line descriptor
      descriptor=$(echo "${line}" | awk '{print $1}' )

      # Capture second field for evaluation
      go_line=$(echo "${line}" | awk '{print $2}')

      # Append GO IDs to array
      if [[ "${go_line}" == "GO;" ]]; then
        go_id=$(echo "${line}" | awk '{print $3}')
        go_ids_array+=("${go_id}")
      fi

    done < "${uniprot_file}"

    # Prints accession<tab>GOID1;GOID2;GOIDn
    # IFS prevents spaces from being added between GO IDs
    # sed removes ";" after final GO ID
    (IFS=; printf "%s\t%s" "${accession}" "${go_ids_array[*]}" | sed 's/.$//')

  # Record accession numbers of those that failed to download.
  else
    error_count=$((error_count+1))
    printf "%s\n" "${accession}" >> failed_accessions.txt
  fi

# If a file was downloaded, remove it.
test -f "${uniprot_file}" && rm "${uniprot_file}"


done < "${input_file}"

# Print error message if any accessions failed to download.
if [[ "${error_count}" -gt 0 ]]; then
  {
    echo "${error_count} accessions were not processed."
    echo "Please see: failed_accessions.txt"
  } 1>&2
fi
