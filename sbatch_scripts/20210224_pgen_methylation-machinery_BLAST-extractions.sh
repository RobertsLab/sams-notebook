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

# Script to extract P.generosa gene IDs based on matches to
# list of methylation machinery gene IDs.
#
# List of methylation machinery gene IDs were provided in this GitHub issue:
# https://github.com/RobertsLab/resources/issues/1116
#
# P.generosa annotated GFF and FastA from 20190928 GenSAS v074-a4 genome annotation:
# https://robertslab.github.io/sams-notebook/2019/09/28/Genome-Annotation-Pgenerosa_v074-a4-Using-GenSAS.html
#
# Requires Bash >=4.0, as script uses associative arrays.


###################################################################################
# These variables need to be set by user

# Assign Variables
data_dir=/gscratch/srlab/sam/data/P_generosa/genomes
threads=40

# Programs array
declare -A programs_array
programs_array=(
[blastx]="/gscratch/srlab/programs/ncbi-blast-2.10.1+/bin/blastx" \
[diamond]="/gscratch/srlab/programs/diamond-2.0.4/diamond" \
[seqkit]="/gscratch/srlab/programs/seqkit-0.15.0"
)


# Input/output files
## Input file
meth_machinery_list="20210219_methylation_list.txt"

## BLAST databases
diamond_blast_db="/gscratch/srlab/blastdbs/uniprot_sprot_20200123/uniprot_sprot.dmnd"
ncbi_blast_db="/gscratch/srlab/blastdbs/ncbi-sp-v5_20210224/swissprot"

## Genome files
genes_fasta="${data_dir}/Panopea-generosa-vv0.74.a4.5d9637f372b5d-publish.genes.fna"
genes_gff="${data_dir}/Panopea-generosa-vv0.74.a4.gene.gff3"

## Output files
diamond_blastx_out="diamond_blastx.outfmt6"
ncbi_blastx_out="ncbi_blastx.outfmt6"
results_table="results_table.tab"
unique_pgen_match_IDs="unique_pgen_match_IDs.tab"


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Create FastA Index
${programs_array[seqkit]} faidx "${genes_fasta}"

# Create results file and header
printf "%s\t%s\t%s\t%s\n" "gene_name" "gene_ID" "NCBI_evalue" "DIAMOND_evalue" \
> ${results_table}

# Pull out unique list of pgen IDs matching methylation machinery list
while read -r line
do
  # Search GFF for methylation gene name
  pgen_match_IDs=$(grep --ignore-case "|${line}" "${genes_gff}" | awk -F'[=;]' '{print $2}')
  printf "%s\t%s\n" "${pgen_match_IDs}" "${line}"
done < ${meth_machinery_list} | sort -u >> ${unique_pgen_match_IDs}

# Use matched pgen IDs to extract FastAs and run BLASTx
while IFS=$'\t' read -r pgen_ID meth_machinery
do
  # Create a temporary file to store seqkit outpout
  query="$(mktemp)"

  # Run seqkit using pgen_ID to extract corresponding FastA sequnce
  ${programs_array[seqkit]} faidx "${genes_fasta}" "${pgen_ID}" \
  > "${query}"

  # Run NCBI BLASTx to generate single match for each query
  ncbi_eval=$(${programs_array[blastx]} \
  -query ${query} \
  -db ${ncbi_blast_db} \
  -outfmt 6 \
  -threads "${threads}" \
  -max_hsps 1 \
  -max_target_seqs 1 \
  | tee --append ${ncbi_blastx_out} \
  | cut -f11)


  # Run DIAMOND with blastx
  # Output format 6 produces a standard BLAST tab-delimited file
  # Block size and index chunks improve speed of DIAMOND BLAST
  diamond_eval=$(${programs_array[diamond] blastx} \
  --db ${diamond_blast_db} \
  --query ${query} \
  --outfmt 6 \
  --max-target-seqs 1 \
  --max-hsps 1 \
  --block-size 15.0 \
  --index-chunks 4 \
  | tee --append ${diamond_blastx_out} \
  | cut -f11)

  # Print to results table file
  printf "%s\t%s\t%s\t%s\n" "${pgen_ID}" "${meth_machinery}" "${ncbi_eval}" "${diamond_eval}" \
  >> ${results_table}

done < ${unique_pgen_match_IDs}







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
