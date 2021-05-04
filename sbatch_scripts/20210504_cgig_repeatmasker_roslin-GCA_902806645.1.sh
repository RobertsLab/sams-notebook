#!/bin/bash
## Job Name
#SBATCH --job-name=20210504_cgig_repeatmasker_roslin-GCA_902806645.1
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=6-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210504_cgig_repeatmasker_roslin-GCA_902806645.1

# Script to run RepeatMasker 4.1.0 on "Roslin" C.gigas NCBI genome assembly GCA_902806645.1


###################################################################################
# These variables need to be set by user

# Set working directory
wd=$(pwd)

# Set number of CPUs to use
threads=40

# Input/output files
genome_fasta=/gscratch/srlab/sam/data/C_gigas/genomes/GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna

# Programs
## Minimap2
repeat_masker=/gscratch/srlab/programs/RepeatMasker-4.1.0/RepeatMasker




# Programs associative array
declare -A programs_array
programs_array=(
[repeat_masker]=${repeat_masker} \
)


###################################################################################

# Exit script if any command fails
set -e


# Generate checksum for "new" FastA
md5sum ${genome_fasta} > genome_fasta.md5


# Run RepeatMasker
# Uses all species
# Generates GFF output
# 'excln' calculates repeat densities
${programs_array[repeat_masker]} \
${genome_fasta} \
-species "all" \
-parallel ${threads} \
-gff \
-excln

###################################################################################

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

echo "Finished logging system PATH"