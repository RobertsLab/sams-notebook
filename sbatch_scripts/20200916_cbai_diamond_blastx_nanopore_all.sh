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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200916_cbai_diamond_blastx_nanopore_all

# Script to run DIAMOND BLASTx on all C.bairdi NanoPore reads using the --long-reads option
# for subsequent import into MEGAN6 to try to separate reads taxonomically.

###################################################################################
# These variables need to be set by user

# FastQ concatenation filename
fastq_cat=20200916_cbai_nanopore_all.fastq

# DIAMOND Output filename prefix
prefix=20200916_cbai_diamond_blastx_nanopore_all

# Set number of CPUs to use
threads=28

# Declare array
raw_reads_dir_array=()

# Paths to reads
raw_reads_dir_array=(
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL58500_04bb4d86_20102558-2729" \
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL58500_94244ffd_20102558-2729" \
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL86873_d8db260e_cbai_6129_403_26"
)

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


# Loop through NanoPore data directories
# to create array of FastQ files from each flowcell
for fastq in "${!raw_reads_dir_array[@]}"
do

  # Concatenate all FastQ files into single file
  # for DIAMOND BLASTx and generate MD5 checksums
  find ${fastq} \
  -name "*.fastq" \
  -exec cat {} >> ${fastq_cat} \; \
  -exec md5sum {} >> fastq_checksums.md5 \;

done

md5sum "${fastq_cat}" >> fastq_checksums.md5


# Run DIAMOND with blastx
# Output format 6 produces a standard BLAST tab-delimited file
# Run DIAMOND with blastx
# Output format 100 produces a DAA binary file for use with MEGAN
${diamond} blastx \
--long-reads \
--db ${dmnd_db} \
--query "${fastq_cat}" \
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
