#!/bin/bash
## Job Name
#SBATCH --job-name=20201229_cbai_detonate_transcriptome_evaluations
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=15-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201229_cbai_detonate_transcriptome_evaluations

# Script runs DETONATE on each of the C.bairdi transcriptomes
# using Bowtie2 BAM alignments generated on 20201224.
# DETONATE will generate a corresponding "score" for each transcriptome,
# providing another metric by which to compare each assembly.

# Requires Bash >=4.0, as script uses associative arrays.


###################################################################################
# These variables need to be set by user

# Assign Variables
## frag_size is guesstimate of library fragment sizes
frag_size=500
bams_dir=/gscratch/scrubbed/samwhite/outputs/20201224_cbai_bowtie2_transcriptomes_alignments
transcriptomes_dir=/gscratch/srlab/sam/data/C_bairdi/transcriptomes
threads=28

# Associative array of the transcriptomes and corresponding BAM file
declare -A transcriptomes_array
transcriptomes_array=(
["${transcriptomes_dir}/cbai_transcriptome_v1.5.fasta"]="${bams_dir}/cbai_transcriptome_v1.5.fasta.sorted.bam" \
["${transcriptomes_dir}/cbai_transcriptome_v1.6.fasta"]="${bams_dir}/cbai_transcriptome_v1.6.fasta.sorted.bam" \
["${transcriptomes_dir}/cbai_transcriptome_v1.7.fasta"]="${bams_dir}/cbai_transcriptome_v1.7.fasta.sorted.bam" \
["${transcriptomes_dir}/cbai_transcriptome_v2.0.fasta"]="${bams_dir}/cbai_transcriptome_v2.0.fasta.sorted.bam" \
["${transcriptomes_dir}/cbai_transcriptome_v2.1.fasta"]="${bams_dir}/cbai_transcriptome_v2.1.fasta.sorted.bam" \
["${transcriptomes_dir}/cbai_transcriptome_v3.0.fasta"]="${bams_dir}/cbai_transcriptome_v3.0.fasta.sorted.bam" \
["${transcriptomes_dir}/cbai_transcriptome_v3.1.fasta"]="${bams_dir}/cbai_transcriptome_v3.1.fasta.sorted.bam"
)


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017


# Programs array

declare -A programs_array
programs_array=(
[detonate_trans_length]="/gscratch/srlab/programs/detonate-1.11/rsem-eval/rsem-eval-estimate-transcript-length-distribution" \
[detonate]="/gscratch/srlab/programs/detonate-1.11/rsem-eval/rsem-eval-calculate-score"
)




# Loop through each comparison
for transcriptome in "${!transcriptomes_array[@]}"
do

  # Remove path from transcriptome
  transcriptome_name="${transcriptome]##*/}"

  # Set RSEM distance output filename
  rsem_eval_dist_mean_sd="${transcriptome_name}_true_length_dis_mean_sd.txt"

  # Capture FastA checksums for verification
  echo "Generating checksum for ${transcriptome_name}"
  md5sum "${transcriptome}" >> fasta.checksums.md5
  echo "Finished generating checksum for ${transcriptome_name}"
  echo ""

  # Determine transcript length
  # Needed for subsequent rsem-eval command.
  ${programs_array[detonate_trans_length]} \
  "${transcriptomes_array[$transcriptome]}" \
  "${rsem_eval_dist_mean_sd}"


  # Run rsem-eval
  # Use paired-end options
  ${programs_array[detonate]} \
  --transcript-length-parameters "${rsem_eval_dist_mean_sd}" \
  --bam \
  --paired-end \
  "${transcriptomes_array[$transcriptome]}" \
  "${transcriptome}" \
  "${transcriptome_name}" \
  ${frag_size}

done

# Capture program options
echo "Logging program options..."
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${program}: "
	echo ""
  # Handle samtools help menus
  if [[ "${program}" == "samtools_index" ]] \
  || [[ "${program}" == "samtools_sort" ]] \
  || [[ "${program}" == "samtools_view" ]]
  then
    ${programs_array[$program]}
  fi
	${programs_array[$program]} -h
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true

  # If MultiQC is in programs_array, copy the config file to this directory.
  if [[ "${program}" == "multiqc" ]]; then
  	cp --preserve ~/.multiqc_config.yaml multiqc_config.yaml
  fi
done

echo ""
echo "Finished logging program options."
echo ""

echo ""
echo "Logging system PATH."
# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log

echo "Finished logging system PATH"
