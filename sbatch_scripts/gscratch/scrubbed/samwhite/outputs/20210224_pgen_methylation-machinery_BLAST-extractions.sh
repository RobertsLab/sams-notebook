#!/bin/bash
## Job Name
#SBATCH --job-name=20210224_pgen_methylation-machinery_BLAST-extractions
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210224_pgen_methylation-machinery_BLAST-extractions


# Requires Bash >=4.0, as script uses associative arrays.


###################################################################################
# These variables need to be set by user

# Assign Variables
wd=$(pwd)
data_dir=/gscratch/srlab/sam/data/P_generosa/genomes
threads=40

# Programs array
declare -A programs_array
programs_array=(
[blastx]="/gscratch/srlab/programs/ncbi-blast-2.10.1+/bin/blastx" \
[diamond_blastx]="/gscratch/srlab/programs/diamond-2.0.4/diamond" \
[seqtk]="/gscratch/srlab/programs/seqkit-0.15.0"
)


# Input/output files
genes_fasta="${data_dir}/Panopea-generosa-vv0.74.a4.5d9637f372b5d-publish.genes.fna"
genes_gff="${data_dir}/Panopea-generosa-vv0.74.a4.gene.gff3"
meth_machinery_list="20210219_methylation_list.txt"


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017






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

echo ""
echo "Finished logging program options."
echo ""

echo ""
echo "Logging system PATH."
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
