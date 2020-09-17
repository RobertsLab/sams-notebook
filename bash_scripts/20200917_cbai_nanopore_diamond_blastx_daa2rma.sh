#!/bin/bash

# Script to run MEGAN6 daa2rma on DIAMOND DAA files from
# 20200916_cbai_diamond_blastx_nanopore_all.blastx.
# Utilizes the --longReads option

# Requires MEGAN mapping file from:
# http://ab.inf.uni-tuebingen.de/data/software/megan6/download/


# MEGAN mapping file
megan_map=/home/sam/data/databases/MEGAN6/megan-map-Jul2020-2.db

# Programs array
declare -A programs_array
programs_array=(
[daa2rma]="/home/shared/megan_6.19.9/tools/daa2rma"
)

threads=16

#########################################################################

# Exit script if any command fails
set -e


## Run daa2rma

# Capture start "time"
# Uses builtin bash variable called ${SECONDS}
start=${SECONDS}

for daa in *.daa
do
  start_loop=${SECONDS}
  sample_name=$(basename --suffix ".blastx.daa" "${daa}")

  echo "Now processing ${sample_name}.daa2rma.rma6"
  echo ""

  # Run daa2rma with long reads option
  ${programs_array[daa2rma]} \
  --in "${daa}" \
  --longReads \
  --mapDB ${megan_map} \
  --out "${sample_name}".daa2rma.rma6 \
  --threads ${threads} \
  2>&1 | tee --append daa2rma_log.txt

  end_loop=${SECONDS}
  loop_runtime=$((end_loop-start_loop))


  echo "Finished processing ${sample_name}.daa2rma.rma6 in ${loop_runtime} seconds."
  echo ""

done

# Caputure end "time"
end=${SECONDS}

runtime=$((end-start))

# Print daa2rma runtime, in seconds

{
  echo ""
  echo "---------------------"
  echo ""
  echo "Total runtime was: ${runtime} seconds"
} >> daa2rma_log.txt

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

# Document programs in PATH
{
date
echo ""
echo "System PATH:"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log
