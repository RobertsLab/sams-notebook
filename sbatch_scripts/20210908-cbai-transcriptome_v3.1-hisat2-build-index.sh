#!/bin/bash
## Job Name
#SBATCH --job-name=20210908-cbai-transcriptome_v3.1-hisat2-build-index
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=5-00:00:00
## Memory per node
#SBATCH --mem=200G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210908-cbai-transcriptome_v3.1-hisat2-build-index

## Script using HiSat2 to build a transcriptome index for cbai_transcriptome_v3.1 using Hisat2.


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=40

# Set Hisat2 index name
transcriptome_index_name="cbai-transcriptome_v3.1"

# Paths to programs
hisat2_dir="/gscratch/srlab/programs/hisat2-2.1.0"
hisat2_build="${hisat2_dir}/hisat2-build"

# Input/output files
transcriptome_dir="/gscratch/srlab/sam/data/C_bairdi/transcriptomes"
transcriptome_fasta="${transcriptome_dir}/cbai_transcriptome_v3.1.fasta"


# Programs associative array
declare -A programs_array
programs_array=(
[hisat2_build]="${hisat2_build}"
)


###################################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Build Hisat2 reference index
"${programs_array[hisat2_build]}" \
"${transcriptome_fasta}" \
"${transcriptome_index_name}" \
-p "${threads}" \
2> hisat2_build.err

# Generate checksums for all files
md5sum * >> checksums.md5

# Copy Hisat2 index files to my data directory for later use
rsync -av "${transcriptome_index_name}"*.ht2 "${transcriptome_dir}"


#######################################################################################################

# Capture program options
if [[ "${#programs_array[@]}" -gt 0 ]]; then
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

    # Handle DIAMOND BLAST menu
    elif [[ "${program}" == "diamond" ]]; then
      ${programs_array[$program]} help

    # Handle NCBI BLASTx menu
    elif [[ "${program}" == "blastx" ]]; then
      ${programs_array[$program]} -help
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
fi


# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log