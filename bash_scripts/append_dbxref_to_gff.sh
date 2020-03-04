#!/bin/bash


gff=

while read -r line
do
	if grep "notes=" "${line}"
	then

	fi
done < ${gff}
