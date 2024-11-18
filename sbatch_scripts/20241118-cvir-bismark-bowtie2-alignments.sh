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

# Program paths
samtools_dir=
bowtie2_dir=


# CPU threads
bismark_threads=15


###################################################################################################

# Get the FastQ file pair for this task
pair=$(sed -n "${SLURM_ARRAY_TASK_ID}p" fastq_pairs.txt)
R1=$(echo $pair | awk '{print $1}')
R2=$(echo $pair | awk '{print $2}')

# Run Bismark
${bismark_dir}/bismark \
--path_to_bowtie2 ${bowtie2_dir} \
--genome ${bisulfite_genome_dir} \
--score_min "${bowtie2_min_score}" \
--parallel "${bismark_threads}" \
--non_directional \
--samtools_path "${samtools_dir}" \
--gzip \
-p "${threads}" \
-1 ${trimmed_fastqs_dir}/${R1}${R1_reads_basename} \
-2 ${trimmed_fastqs_dir}/${R2}${R2_reads_basename} \
--output_dir "${output_dir_top}" \
2> "${output_dir_top}"/bismark_summary_${SLURM_ARRAY_TASK_ID}.txt