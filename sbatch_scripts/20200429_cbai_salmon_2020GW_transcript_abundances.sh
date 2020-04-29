#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_DEG_basic
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200429_cbai_salmon_2020GW_transcript_abundances

# Script to generate set of transcript abundances for all C.bairdi Genewiz 2020 data.
#
# C.bairdi-specific reads were extracted with MEGAN6:
# https://robertslab.github.io/sams-notebook/2020/03/30/RNAseq-Reads-Extractions-C.bairdi-Taxonomic-Reads-Extractions-with-MEGAN6-on-swoose.html
#
# Transcriptome was produced here: https://robertslab.github.io/sams-notebook/2020/03/30/Transcriptome-Assembly-C.bairdi-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html
# Transcriptome is the same as: cbai_transcriptome_v1.5.fasta
#
# Salmon index generated during a previous gene expression analysis:
# https://robertslab.github.io/sams-notebook/2020/04/22/Gene-Expression-C.bairdi-Pairwise-DEG-Comparisons-with-2019-RNAseq-using-Trinity-Salmon-EdgeR-on-Mox.html



###################################################################################################################
# BEGIN USER SETTINGS


# Programs array
declare -A programs_array
programs_array=([salmon]="/gscratch/srlab/programs/salmon-1.2.1_linux_x86_64/bin/salmon")

## Designate input files and locations
fastq_dir="/gscratch/srlab/sam/data/C_bairdi/RNAseq/"
salmon_index="/gscratch/srlab/sam/data/C_bairdi/transcriptomes/20200408.C_bairdi.megan.Trinity.fasta.salmon.idx"

# Set number of CPU threads
# Salmon default is 56 threads - so not needed
# threads=28

# END USER SETTINGS
####################################################################################################################

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

# Caputure working directory
#wd="$(pwd)"


# Capture program options
## NOTE: This particular instance is specific to salmon!
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${programs_array[program]}: "
	echo ""
	${programs_array[program]} quant --help
	echo ""
	${programs_array[program]} quant --help-reads
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
  } &>> program_options.log || true
done

# Populate array with FastQ files
reads_array=("${fastq_dir}"*.fq)

# Loop through read pairs
# Increment by 2 to process next pair of FastQ files
for (( i=0; i<${#reads_array[@]} ; i+=2 ))
do

	# Create list of FastQ files used
	{
	echo "${reads_array[i]}"
	echo "${reads_array[i+1]}"
} >> fastq-list.txt

  # Strip path and save just filename
  sample=${reads_array[i]##*/}

	# Run salmon
	# Library type (stranded or not) is set to auto (A)
	${programs_array[salmon]} \
	--index ${salmon_index} \
	--libType A \
	--validateMappings \
	--output quants/"${sample}"_quant
done
