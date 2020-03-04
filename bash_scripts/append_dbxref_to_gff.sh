#!/bin/bash


gff=

# Dbxref annotation labels
ips="InterPro"
pfam="Pfam"
sp="UniProtKB/Swiss-Prot"


while read -r line
do
	if grep "notes=" "${line}"
	then

	fi
done < ${gff}
