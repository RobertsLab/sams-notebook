#!/bin/bash
## Job Name
#SBATCH --job-name=hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=0-08:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1


## Script for running BLASTx (using DIAMOND) to annotate
## Hematodinium transcriptomes v1.6, v1.7, v2.1 and v3.1 against SwissProt database.
## Output will be in standard BLAST output format 6.

###################################################################################
# These variables need to be set by user

# Programs array
declare -A programs_array
programs_array=(
[diamond]="/gscratch/srlab/programs/diamond-0.9.29/diamond"
)

# Establish variables for more readable code
transcriptomes_dir=/gscratch/srlab/sam/data/Hematodinium/transcriptomes

# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
transcriptomes_array=(
"${transcriptomes_dir}"/hemat_transcriptome_v1.6.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v1.7.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v2.1.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v3.1.fasta
)

# DIAMOND UniProt database
dmnd=/gscratch/srlab/blastdbs/uniprot_sprot_20200123/uniprot_sprot.dmnd

###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017


for fasta in "${!transcriptomes_array[@]}"
do

  # Remove path from transcriptome using parameter substitution
  transcriptome_name="${transcriptomes_array[$fasta]##*/}"

  # Generate checksums for reference
  md5sum "${transcriptomes_array[$fasta]}">> fasta.checksums.md5

  # Run DIAMOND with blastx
  # Output format 6 produces a standard BLAST tab-delimited file
  ${programs_array[diamond]} blastx \
  --db ${dmnd} \
  --query "${transcriptomes_array[$fasta]}" \
  --out "${transcriptome_name}".blastx.outfmt6 \
  --outfmt 6 \
  --evalue 1e-4 \
  --max-target-seqs 1 \
  --block-size 15.0 \
  --index-chunks 4
done


###################################################################################

# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : n
} >> system_path.log


# Capture program options
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${program}: "
	echo ""
	${programs_array[$program]} --help
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true
done
