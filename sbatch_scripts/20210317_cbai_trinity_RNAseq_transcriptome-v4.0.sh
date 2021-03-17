#!/bin/bash
## Job Name
#SBATCH --job-name=20210317_cbai_trinity_RNAseq_transcriptome-v4.0
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=20-00:00:00
## Memory per node
#SBATCH --mem=200G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210317_cbai_trinity_RNAseq_transcriptome-v4.0

## Script for running BLASTx (using DIAMOND) with all of our C.bairdi RNAseq data to-date.
## BLASTx against C.opilio _(snow crab) NCBI protein FastA
## Output will be in standard BLAST output format 6, but only query ID.
## Output will be used to extract just reads with matches to to C.opilio genome,
## for downstream transcriptome assembly

###################################################################################
# These variables need to be set by user

# Path to this script
script_path=/gscratch/scrubbed/samwhite/outputs/20210317_cbai_trinity_RNAseq_transcriptome-v4.0/20210317_cbai_trinity_RNAseq_transcriptome-v4.0.sh

# RNAseq FastQs directory
reads_dir=/gscratch/scrubbed/samwhite/outputs/20210316_cbai-vs-copi_reads_extractions

# CPU threads
threads=40

# Capture specified RAM from this script
# Carrot needed to limit grep to line starting with #SBATCH
# Avoids grep-ing the command below.
max_mem=$(grep "^#SBATCH --mem=" ${script_path} | awk -F [=] '{print $2}')

# Paths to programs
trinity_dir="/gscratch/srlab/programs/trinityrnaseq-v2.9.0"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"


# Programs array
declare -A programs_array
programs_array=(
[samtools_faidx]="${samtools} faidx" \
[trinity]="${trinity_dir}/Trinity" \
[trinity_stats]="${trinity_dir}/util/TrinityStats.pl" \
[trinity_gene_trans_map]="${trinity_dir}/util/support_scripts/get_Trinity_gene_to_trans_map.pl" \
[trinity_fasta_seq_length]="${trinity_dir}/util/misc/fasta_seq_length.pl"
)

# FastQ array
fastq_array=(${reads_dir}/*copi-BLASTx-match.fq.gz)


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017




###################################################################################

# Capture program options
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
