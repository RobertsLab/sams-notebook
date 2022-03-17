#!/bin/bash
## Job Name
#SBATCH --job-name=
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=21-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/


###################################################################################

# These variables need to be set by user

## Assign Variables

# These variables need to be set by user

# NF Core RNAseq workflow directory
nf-core_rnaseq=""

# RNAseq FastQs directory
reads_dir=/gscratch/srlab/sam/data/P_generosa/RNAseq

# Genome FastA
genome_fasta=/gscratch/srlab/sam/data/P_generosa/genomes/Panopea-generosa-v1.0.fa

# Genome GFF3
genome_gff=/gscratch/srlab/sam/data/P_generosa/genomes/Panopea-generosa-vv0.74.a4-merged-2019-10-07-4-46-46.gff3

# Trascriptome FastA
transcriptome_fasta=/gscratch/srlab/sam/data/P_generosa/transcriptomes/Pgenerosa_transcriptome_v5.fasta

# Inititalize arrays
# Leave empty!!
R1_array=()
R2_array=()
R1_uncompressed_array=()
R2_uncompressed_array=()

###################################################################################

# Exit script if a command fails
set -e

# Load Anaconda
# Uknown why this is needed, but Anaconda will not run if this line is not included.
. "/gscratch/srlab/programs/anaconda3/etc/profile.d/conda.sh"

# Activate NF-core conda environment
conda activate nf-core_env

# Load Singularity Mox module for NF Core/Nextflow
module load singularity

# NF Core RNAseq sample sheet header
sample_sheet_header="sample,fastq_1,fastq_2,strandedness"
printf "%s\n" "sample_sheet_header" >> sample_sheet-"${SLURM_JOB_ID}".csv

# Create array of original uncompressed fastq R1 files
# Set filename pattern
R1_uncompressed_array=("${reads_dir}"/*_1.fastq)

# Create array of original uncompressed fastq R2 files
# Set filename pattern
R2_uncompressed_array=("${reads_dir}"/*_2.fastq)

# Check array size to confirm it has all expected samples
# Exit if mismatch
if [[ "${#R1_uncompressed_array[@]}" != "${#R2_uncompressed_array[@]}" ]]
then
  echo ""
  echo "Uncompressed array sizes don't match."
  echo "Confirm all expected FastQs are present in ${reads_dir}"
  echo ""

  exit
fi

# Create list of original uncompressed fastq files
## Uses parameter substitution to strip leading path from filename
for fastq in "${!R1_uncompressed_array[@]}"
do
  # Strip leading path
	no_path=$(echo "${R1_uncompressed_array[${fastq}]##*/}")

  # Grab SRA name
  sra=$(echo "${no_path}" | awk -F "_" '{print $1}')

  # Only gzip matching FastQs
  # Only generate MD5 checksums for matching FastQs
  if [[ "${sra}" == "SRR12218868" ]] \
    || [[ "${sra}" == "SRR12218869" ]] \
    || [[ "${sra}" == "SRR12226692" ]] \
    || [[ "${sra}" == "SRR12218870" ]] \
    || [[ "${sra}" == "SRR12226693" ]] \
    || [[ "${sra}" == "SRR12207404" ]] \
    || [[ "${sra}" == "SRR12207405" ]] \
    || [[ "${sra}" == "SRR12227930" ]] \
    || [[ "${sra}" == "SRR12207406" ]] \
    || [[ "${sra}" == "SRR12207407" ]] \
    || [[ "${sra}" == "SRR12227931" ]] \
    || [[ "${sra}" == "SRR12212519" ]] \
    || [[ "${sra}" == "SRR12227929" ]] \
    || [[ "${sra}" == "SRR8788211" ]]
  then
    # Gzip FastQs; NF Core RNAseq requires gzipped FastQs as inputs
    gzip "${R1_uncompressed_array[${fastq}]}"
    gzip "${R2_uncompressed_array[${fastq}]}"

    # Generate MD5 checksums of uncompressed FastQs
    {
      md5sum "${R1_uncompressed_array[${fastq}]}"
      md5sum "${R2_uncompressed_array[${fastq}]}"
    } >> uncompressed_fastqs-"${SLURM_JOB_ID}".md5
  fi
done


# Create array of fastq R1 files
# Set filename pattern
R1_array=("${reads_dir}"/*_1.fastq.gz)

# Create array of fastq R2 files
# Set filename pattern
R2_array=("${reads_dir}"/*_2.fastq.gz)

# Check array sizes to confirm they are same size
# Exit if mismatch
if [[ "${#R1_array[@]}" != "${#R2_array[@]}" ]]
  then
    echo ""
    echo "Read1 and Read2 compressed FastQ array sizes don't match."
    echo "Confirm all expected compressed FastQs are present in ${reads_dir}"
    echo ""

    exit
fi

# Create list of fastq files used in analysis
## Uses parameter substitution to strip leading path from filename
for fastq in "${!R1_array[@]}"
do
  # Generate MD5 checksums for compressed FastQs used in NF Core RNAseq analysis
  {
    md5sum "${R1_array[${fastq}]}"
    md5sum "${R2_array[${fastq}]}"
  } >> input_fastqs-"${SLURM_JOB_ID}".md5

  # Strip leading path
	no_path=$(echo "${R1_array[${fastq}]##*/}")

  # Grab SRA name
  sra=$(echo "${no_path}" | awk -F "_" '{print $1}')

  # Set tissue type
  if [[ "${sra}" == "SRR12218868" ]]
  then
    tissue="heart"

    # Add to NF Core RNAseq sample sheet
    printf "%s,%s,%s,%s\n" "${tissue}" "${R1_array[${fastq}]}" "${R2_array[${fastq}]}" "reverse" \
    >> sample_sheet-"${SLURM_JOB_ID}".csv

  elif [[ "${sra}" == "SRR12218869" ]] \
    || [[ "${sra}" == "SRR12226692" ]]

  then
    tissue="gonad"

    # Add to NF Core RNAseq sample sheet
    printf "%s,%s,%s,%s\n" "${tissue}" "${R1_array[${fastq}]}" "${R2_array[${fastq}]}" "reverse" \
    >> sample_sheet-"${SLURM_JOB_ID}".csv

  elif [[ "${sra}" == "SRR12218870" ]] \
    || [[ "${sra}" == "SRR12226693" ]]
  then
    tissue="ctenidia"

    # Add to NF Core RNAseq sample sheet
    printf "%s,%s,%s,%s\n" "${tissue}" "${R1_array[${fastq}]}" "${R2_array[${fastq}]}" "reverse" \
    >> sample_sheet-"${SLURM_JOB_ID}".csv

  elif [[ "${sra}" == "SRR12207404" ]] \
    || [[ "${sra}" == "SRR12207405" ]] \
    || [[ "${sra}" == "SRR12227930" ]] \
    || [[ "${sra}" == "SRR12207406" ]] \
    || [[ "${sra}" == "SRR12207407" ]] \
    || [[ "${sra}" == "SRR12227931" ]]
  then
    tissue="juvenile"

    # Add to NF Core RNAseq sample sheet
    printf "%s,%s,%s,%s\n" "${tissue}" "${R1_array[${fastq}]}" "${R2_array[${fastq}]}" "reverse" \
    >> sample_sheet-"${SLURM_JOB_ID}".csv

  elif [[ "${sra}" == "SRR12212519" ]] \
    || [[ "${sra}" == "SRR12227929" ]] \
    || [[ "${sra}" == "SRR8788211" ]]
  then
    tissue="larvae"

    # Add to NF Core RNAseq sample sheet
    printf "%s,%s,%s,%s\n" "${tissue}" "${R1_array[${fastq}]}" "${R2_array[${fastq}]}" "reverse" \
    >> sample_sheet-"${SLURM_JOB_ID}".csv
  fi

done


# Run NF Core RNAseq workflow
