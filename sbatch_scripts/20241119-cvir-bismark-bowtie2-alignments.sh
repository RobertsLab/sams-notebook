#!/bin/bash

###################################################################################
# These variables need to be set by user

## Assign Variables

# INPUT FILES
repo_dir="/gscratch/scrubbed/samwhite/gitrepos/ceasmallr"
trimmed_fastqs_dir="${repo_dir}/output/00.00-trimming-fastp"
bisulfite_genome_dir="${repo_dir}/data/Cvirginica_v300"


# OUTPUT FILES
output_dir_top="${repo_dir}/output/02.00-bismark-bowtie2-alignment"

# PARAMETERS
bowtie2_min_score="L,0,-0.6"


# CPU threads
# Bismark already spawns multiple instances and additional threads are multiplicative."
bismark_threads=8


###################################################################################

cd "${output_dir_top}"

echo "Currently in this directory:"
pwd

# Get the FastQ file pair for this task
pair=$(sed -n "${SLURM_ARRAY_TASK_ID}p" fastq_pairs.txt)

echo "Contents of pair:"
echo "${pair}"
echo ""

R1=$(echo $pair | awk '{print $1}')
echo "Contents of R1: ${R1}"
echo ""

R2=$(echo $pair | awk '{print $2}')
echo "Contents of R2: ${R2}"
echo ""

# Get just the sample name (excludes the _R[12]_001*)
sample_name="${R1%%_*}"

echo "Contents of sample_name: ${sample_name}"
echo ""

# Run Bismark
bismark \
--genome ${bisulfite_genome_dir} \
--score_min "${bowtie2_min_score}" \
--parallel "${bismark_threads}" \
--non_directional \
--gzip \
-p "${bismark_threads}" \
-1 ${trimmed_fastqs_dir}/${R1}\
-2 ${trimmed_fastqs_dir}/${R2} \
--output_dir "${output_dir_top}" \
2> "${output_dir_top}"/${sample_name}-${SLURM_ARRAY_TASK_ID}-bismark_summary.txt