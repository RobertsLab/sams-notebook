#!/bin/bash

# Script to run MEGAN6 "daa2rma" on MEGANized DAA files from
# 20230316.

# Requires MEGAN mapping file from:
# http://ab.inf.uni-tuebingen.de/data/software/megan6/download/

###############################################

# Set variables

## CPU threads
threads="40"

## File path on Gannet
gannet_path="/volume2/web/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq"

## MEGAN mapping database
megan_db="/home/sam/data/databases/MEGAN/megan-map-Feb2022.db"

## Output files
input_filenames="mmag-daa_filenames.txt"

## Programs array
declare -A programs_array
programs_array=(
[daa2rma]="/home/shared/megan-6.24.20/tools/daa2rma"
)

## Set a line
line="------------------------------------------"

# Exit script if any command fails
set -e

###############################################

## Create two column list of paired DAA files
## Retrieves list of files from gannet
ssh gannet "for file in ${gannet_path}/*R1*.daa; do
    r1=\"\$file\"
    r2=\"\${file/R1/R2}\"
    echo \"\$(basename \"\$r1\") \$(basename \"\$r2\")\"
done" > "${input_filenames}"

###############################################

## Run MEGANIZER

# Capture start "time"
# Uses builtin bash variable called ${SECONDS}
start=${SECONDS}


while read -r daa1 daa2
do
  start_loop=${SECONDS}
  sample_name=$(basename --suffix ".trimmed.R1.blastx.meganized.daa" "${daa1}")

  echo "Now transferring ${daa1} and ${daa2} via rsync."
  echo ""

  # Transfer paired DAA files
  rsync -av gannet:${gannet_path}/${sample_name}* .

  # Generate checksums of input DAA files
  echo ""
  echo "Generating checksums for ${daa1} and ${daa2}."

  md5sum "${daa1}" "${daa2}" | tee --append input-daa-file-checksums.md5

  echo "Finished generating checksums for ${daa1} and ${daa2}."
  echo ""

  echo "Now creating ${sample_name}.daa2rma.rma6"
  echo ""

  # Run daa2rma with paired option
  ${programs_array[daa2rma]} \
  --in "${daa1}" "${daa2}" \
  --mapDB ${megan_db} \
  --out "${daa1}.daa2rma.rma6" "${daa2}.daa2rma.rma6"\
  --threads "${threads}" \
  2>&1 | tee --append daa2rma_log.txt

  end_loop=${SECONDS}
  loop_runtime=$((end_loop-start_loop))

  # Convert runtime to hrs/mins/secs
  days=$((loop_runtime / 86400))
  hours=$((loop_runtime / 3600))
  minutes=$(( (loop_runtime % 3600) / 60 ))
  seconds=$(( (loop_runtime % 3600) % 60 ))


  printf "Finished creating ${daa1}.daa2rma.rma6 and ${daa2}.daa2rma.rma6 in: \n\n%02ddays %02dhrs %02dmins %02dsecs\n" "${days}" "${hours}" "${minutes}" "${seconds}"
  echo ""

  # Remove DAA files
  rm "${daa1}" "${daa2}"

  echo "${line}"
  echo ""

done < "${input_filenames}"

# Caputure end "time"
end=${SECONDS}

# Calculate runtime
runtime=$((end-start))

# Convert runtime to days/hrs/mins/secs
days=$((runtime / 86400))
hours=$((runtime / 3600))
minutes=$(( (runtime % 3600) / 60 ))
seconds=$(( (runtime % 3600) % 60 ))

# Print MEGANIZER runtime

{
  echo ""
  echo "${line}"
  echo ""
  printf "Total runtime was: \n\n%02ddays %02dhrs %02dmins %02dsecs\n" "${days}" "${hours}" "${minutes}" "${seconds}"
} >> daa2rma_log.txt

###############################################

# Generating checkums for all files

for file in *
do
  echo ""
  echo "Generating checksums for ${file}."
  md5sum "${file}" | tee --append checksums.md5
  echo "Finished generating checksums for ${files}."
  echo ""
done

###############################################


# Capture program options
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${program}: "
	echo ""
	${programs_array[$program]} --help
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true
done


