#!/bin/bash

# Script to run MEGAN6 meganizer on DIAMOND DAA files from
# 20200414_cbai_diamond_blastx Mox job.

# Requires MEGAN mapping files from:
# http://ab.inf.uni-tuebingen.de/data/software/megan6/download/

# Exit script if any command fails
set -e

# Program path
meganizer=/home/sam/programs/megan/tools/daa2rma

# MEGAN mapping files
prot_acc2tax=/home/sam/data/databases/MEGAN/prot_acc2tax-Jul2019X1.abin
acc2interpro=/home/sam/data/databases/MEGAN/acc2interpro-Jul2019X.abin
acc2eggnog=/home/sam/data/databases/MEGAN/acc2eggnog-Jul2019X.abin


## Inititalize arrays
daa_array_R1=()
daa_array_R2=()


# Populate array with unique sample names
## NOTE: Requires Bash >=v4.0
mapfile -t samples_array < <( for daa in *.daa; do echo "${daa}" | awk -F"_" '{print $1}'; done | sort -u )

# Loop to concatenate same sample R1 and R2 reads
for sample in "${!samples_array[@]}"
do
  # Concatenate R1 reads for each sample
  for daa in *R1*.daa
  do
    daa_sample=$(echo "${daa}" | awk -F"_" '{print $1}')
    if [ "${samples_array[sample]}" == "${daa_sample}" ]; then
      reads_1=${samples_array[sample]}_reads_1.daa
      echo "Concatenating ${daa} with ${reads_1}"
      cat "${daa}" >> "${reads_1}"
    fi
  done

# Concatenate R2 reads for each sample
for daa in *R2*.daa
do
  daa_sample=$(echo "${daa}" | awk -F"_" '{print $1}')
  if [ "${samples_array[sample]}" == "${daa_sample}" ]; then
    reads_2=${samples_array[sample]}_reads_2.daa
    echo "Concatenating ${daa} with ${reads_2}"
    cat "${daa}" >> "${reads_2}"
  fi
done


# Create array of DAA R1 files
for daa in *reads_1.daa
do
  daa_array_R1+=("${daa}")
done

# Create array of DAA R2 files
for daa in *reads_2.daa
do
  daa_array_R2+=("${daa}")
done

## Run MEGANIZER

# Capture start "time"
# Uses builtin bash variable called ${SECONDS}
start=${SECONDS}

for index in "${!daa_array_R1[@]}"
do
  start_loop=${SECONDS}
  sample_name=$(echo "${daa_array_R1[index]}" | awk -F "_" '{print $1}')

  echo "Now processing ${sample_name}.daa2rma.rma6"
  echo ""

  # Run daa2rma with paired option
  ${meganizer} \
  --paired \
  --in "${daa_array_R1[index]}" "${daa_array_R2[index]}" \
	--acc2taxa ${prot_acc2tax} \
	--acc2interpro2go ${acc2interpro} \
	--acc2eggnog ${acc2eggnog} \
  --out "${sample_name}".daa2rma.rma6 \
  2>&1 | tee --append daa2rma_log.txt

  end_loop=${SECONDS}
  loop_runtime=$((end_loop-start_loop))


  echo "Finished processing ${sample_name}.daa2rma.rma6 in ${loop_runtime} seconds."
  echo ""

done

# Caputure end "time"
end=${SECONDS}

runtime=$((end-start))

# Print MEGANIZER runtime, in seconds

{
  echo ""
  echo "---------------------"
  echo ""
  echo "Total runtime was: ${runtime} seconds"
} >> daa2rma_log.txt
