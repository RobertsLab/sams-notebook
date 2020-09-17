#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_blastx_DIAMOND_nanopore_all
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200917_cbai_diamond_blastx_nanopore_all_Q7

# Script to run DIAMOND BLASTx on all quality filtered (Q7) C.bairdi NanoPore reads
# from 20200917 using the --long-reads option
# for subsequent import into MEGAN6 to try to separate reads taxonomically.

###################################################################################
# These variables need to be set by user

# Input FastQ file
fastq=/gscratch/srlab/sam/data/C_bairdi/DNAseq/20200917_cbai_nanopore_all_quality-7.fastq

# DIAMOND Output filename prefix
prefix=20200917_cbai_diamond_blastx_nanopore_all_Q7

# Set number of CPUs to use
threads=28

# Program paths
diamond=/gscratch/srlab/programs/diamond-0.9.29/diamond

# DIAMOND UniProt database
dmnd_db=/gscratch/srlab/blastdbs/uniprot_sprot_20200123/uniprot_sprot.dmnd


###################################################################################
# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# SegFault fix?
export THREADS_DAEMON_MODEL=1


# Inititalize arrays
programs_array=()


# Programs array
programs_array=("${diamond}")


md5sum "${fastq}" > fastq_checksums.md5


# Run DIAMOND with blastx
# Output format 6 produces a standard BLAST tab-delimited file
# Run DIAMOND with blastx
# Output format 100 produces a DAA binary file for use with MEGAN
${diamond} blastx \
--long-reads \
--db ${dmnd_db} \
--query "${fastq}" \
--out "${prefix}".blastx.daa \
--outfmt 100 \
--top 5 \
--block-size 15.0 \
--index-chunks 4 \
--threads ${threads}

# Capture program options
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${programs_array[program]}: "
	echo ""
	${programs_array[program]} help
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true
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
