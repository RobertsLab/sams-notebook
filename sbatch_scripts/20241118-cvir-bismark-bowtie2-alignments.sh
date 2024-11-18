#!/bin/bash
#SBATCH --job-name=bismark_job_array
#SBATCH --account=coenv
#SBATCH --partition=cpu-g2
#SBATCH --output=bismark_job_%A_%a.out
#SBATCH --error=bismark_job_%A_%a.err
#SBATCH --array=0-$(($(wc -l < fastq_pairs.txt) - 1))
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=175G
#SBATCH --time=24:00:00
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/gitrepos/ceasmallr/output/02.00-bismark-bowtie2-alignment/

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

# Program paths
samtools_dir=
bowtie2_dir=
bismark_dir=
bisulfite_genome_dir=

# CPU threads
# Bismark already spawns multiple instances and additional threads are multiplicative."
bismark_threads=8


###################################################################################

# Get the FastQ file pair for this task
pair=$(sed -n "${SLURM_ARRAY_TASK_ID}p" fastq_pairs.txt)
R1=$(echo $pair | awk '{print $1}')
R2=$(echo $pair | awk '{print $2}')

# Get just the sample name (excludes the _R[12]_001*)
sample_name="${R1%%_*}"

# Run Bismark
${bismark_dir}/bismark \
--genome ${bisulfite_genome_dir} \
--score_min "${bowtie2_min_score}" \
--parallel "${bismark_threads}" \
--non_directional \
--gzip \
-p "${threads}" \
-1 ${trimmed_fastqs_dir}/${R1}\
-2 ${trimmed_fastqs_dir}/${R2} \
--output_dir "${output_dir_top}" \
2> "${output_dir_top}"/${sample_name}-{SLURM_ARRAY_TASK_ID}-bismark_summary.txt