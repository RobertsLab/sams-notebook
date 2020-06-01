#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_detonate_transcriptome_evaluations
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=8-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200601_cbai_detonate_transcriptome_evaluations


###################################################################################
# These variables need to be set by user

# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
transcriptomes_array=(
cbai_transcriptome_v1.0.fa \
cbai_transcriptome_v1.5.fa \
cbai_transcriptome_v1.6.fa \
cbai_transcriptome_v1.7.fa \
cbai_transcriptome_v2.0.fa \
cbai_transcriptome_v3.0.fa \
20200526.P_trituberculatus.Trinity.fa
)


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log


## Inititalize arrays
R1_array=()
R2_array=()

# Variables
R1_list=""
R2_list=""
threads=28

#programs
bowtie2="/gscratch/srlab/programs/bowtie2-2.3.5.1-linux-x86_64/bowtie2"
detonate_trans_length="/gscratch/srlab/programs/detonate-1.11/rsem-eval/rsem-eval-estimate-transcript-length-distribution"
detonate="/gscratch/srlab/programs/detonate-1.11/rsem-eval/rsem-eval"


# Loop through each comparison
for transcriptome in "${!transcriptomes_array[@]}"
do
  transcriptome="${transcriptomes_array[$transcriptome]}"

  # Capture FastA checksums for verification
  echo "Generating checksum for ${transcriptome}"
  md5sum "${transcriptome}" >> fasta.checksums.md5
  echo "Finished generating checksum for ${transcriptome}"
  echo ""

  if [[ "${transcriptome}" == "cbai_transcriptome_v1.0.fa" ]]; then
    # Create array of fastq R1 files
    R1_array=(${reads_dir}/*.3[02]*megan*R1.fq)

    # Create array of fastq R2 files
    R2_array=(${reads_dir}/*.3[02]*megan*R2.fq)

    # Create list of fastq files used in analysis
    ## Uses parameter substitution to strip leading path from filename
    for fastq in ${reads_dir}/*.fq
      do
      echo "${fastq##*/}" >> "${transcriptome}".fastq.list.txt
    done

    # Create comma-separated lists of FastQ reads
    R1_list=$(echo "${R1_array[@]}" | tr " " ",")
    R2_list=$(echo "${R2_array[@]}" | tr " " ",")
  fi
done
