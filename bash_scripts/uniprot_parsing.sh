#!/bin/bash

### Bash script for batch retrieval of Gene Ontology terms from uniprot.org from
### a list of UniProt accessions.

while read -r line
do
  entry=$(echo "${line}" | awk '{print $1}' )
  if [[ "${entry}" == "ID" ]]; then
    echo "${line}" | awk '{print $2}'
  fi
done < "$1"
