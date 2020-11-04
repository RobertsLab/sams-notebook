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



chromosome_array=($(grep "^NC" ${transcriptome} | awk '{print $1}' | sort -u))


ref_list=$(echo ${chromosome_array[@]}| sed 's/ /,/g')
