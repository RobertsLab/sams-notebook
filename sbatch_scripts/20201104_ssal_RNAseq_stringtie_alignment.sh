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


### S.salar RNAseq Hisat2 alignment.

### Uses fastp-trimmed FastQ files from 20201029.

### Uses GCF_000233375.1_ICSASG_v2_genomic.fa as reference,
### created by Shelly Trigg.
### This is a subset of the NCBI RefSeq GCF_000233375.1_ICSASG_v2_genomic.fna.
### Includes only "chromosome" sequence entries.



###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=27

# Input/output files
transcriptome="/gscratch/srlab/sam/data/S_salar/transcriptomes/GCF_000233375.1_ICSASG_v2_genomic.gtf"
genome="/gscratch/srlab/sam/data/S_salar/genomes/GCF_000233375.1_ICSASG_v2_genomic.fa"

# Paths to programs
stringtie="/gscratch/srlab/programs/stringtie-2.1.4.Linux_x86_64"

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

# Capture date
timestamp=$(date +%Y%m%d)


# Create array of chromosome IDs from Shelly's genome subset
chromosome_array=($(grep ">" ${genome} | awk '{print $1}' | tr -d '>'))

# Create comma-separated list of IDs for StringTie to use for alignment
ref_list=$(echo ${chromosome_array[@]}| sed 's/ /,/g')




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
  	cp --preserve ~/.multiqc_config.yaml "${timestamp}_multiqc_config.yaml"
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
