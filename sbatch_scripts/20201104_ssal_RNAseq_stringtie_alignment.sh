#!/bin/bash
## Job Name
#SBATCH --job-name=20201104_ssal_RNAseq_stringtie_alignment
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-00:00:00
## Memory per node
#SBATCH --mem=200G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201104_ssal_RNAseq_stringtie_alignment


### S.salar RNAseq StringTie alignment.

### Uses BAM alignment files from 20201103 and transcriptome
### GTF provided by Shelly (presumably GTF is from NCBI).


###################################################################################
# These variables need to be set by user

## Assign Variables

wd=$(pwd)

# Set number of CPUs to use
threads=27

# Input/output files
bam_dir="/gscratch/scrubbed/samwhite/outputs/20201103_ssal_RNAseq_hisat2_alignment/"
bam_md5s=bam_checksums.md5
genome="/gscratch/srlab/sam/data/S_salar/genomes/GCF_000233375.1_ICSASG_v2_genomic.fa"
gtf_md5=gtf_checksum.md5
transcriptome="/gscratch/srlab/sam/data/S_salar/transcriptomes/GCF_000233375.1_ICSASG_v2_genomic.gtf"

# Paths to programs
stringtie="/gscratch/srlab/programs/stringtie-2.1.4.Linux_x86_64/stringtie"

## Inititalize arrays
chromosome_array=()

# Programs associative array
declare -A programs_array
programs_array=(
[stringtie]="${stringtie}"
)

###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Create array of chromosome IDs from Shelly's genome subset
chromosome_array=($(grep ">" ${genome} | awk '{print $1}' | tr -d '>'))

# Create comma-separated list of IDs for StringTie to use for alignment
ref_list=$(echo "${chromosome_array[@]}" | sed 's/ /,/g')

# Run StringTie
for bam in "${bam_dir}"*.bam
do
  # Parse out sample name by removing all text up to and including the last period.
  sample_name_no_path=${bam##*/}
  sample_name=${sample_name_no_path%%.*}

  # Exectute StringTie
  # Use list of of chromosome IDs (ref_list)
  # Output an abundance file with TPM and FPKM data in dedicated columns
  ${programs_array[stringtie]} \
  ${bam} \
  -G ${transcriptome} \
  -A ${sample_name}_gene-abund.tab \
  -x ${ref_list} \
  -p ${threads}

  # Generate BAM MD5 checksums
  md5sum "${bam}" >> "${bam_md5s}"
done


# Generate GTF MD5 checksum
md5sum "${transcriptome}" >> "${gtf_md5}"

# Capture program options
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
  	cp --preserve ~/.multiqc_config.yaml .
  fi
done


# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log
