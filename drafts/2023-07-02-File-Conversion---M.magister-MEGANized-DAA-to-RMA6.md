---
layout: post
title: File Conversion - M.magister MEGANized DAA to RMA6
date: '2023-07-02 06:19'
tags: 
  - megan
  - DAA
  - RMA6
  - Metacarcinus magister
  - dungeness crab
categories: 
  - Miscellaneous
---
After the [initial DIAMOND BLASTx and subsequent MEGANization](https://robertslab.github.io/sams-notebook/2023/03/16/Sequencing-Read-Taxonomic-Classification-M.magister-RNA-seq-Using-DIAMOND-BLASTx-and-MEGAN6-daa-meganizer-on-Mox.html)(notebook) ran for 41 _days_, I attempted to open the extremely large files in the MEGAN6 GUI to get an overview of taxonomic breakdown. Due to the large file sizes (the _smallest_ is 68GB!), the GUI consistently crashed. Also, each attempt took an hour or two before it would crash. Looking into this a bit more, I realized that I needed to convert the MEGANized DAA files to RMA6 format before attempting to import into the MEGAN6 GUI! Gah! The RMA6 files are _significantly_ smaller (like "only" 2GB) and there should be ample memory to import them.

This job was run on Raven. It cannot be run on Mox due to Mox lacking an "X11 window." An X11 window is usually a graphics window. Even though this is run through command line, MEGAN6 still requires launching an X11 window in the background. Since Mox does not have this available, MEGAN6 `daa2rma` tool fails on Mox.

Bash script (GitHub):

- [20230702-mmag-daa2rma.sh](https://github.com/RobertsLab/sams-notebook/blob/master/bash_scripts/20230702-mmag-daa2rma.sh)

```bash
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
```


---

#### RESULTS

Output folder:

- []()

