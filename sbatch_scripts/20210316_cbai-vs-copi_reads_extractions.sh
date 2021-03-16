#!/bin/bash
## Job Name
#SBATCH --job-name=20210316_cbai-vs-copi_reads_extractions
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210316_cbai-vs-copi_reads_extractions

## Script for extracting C.bairdi RNAseq reads that matched to C.opilio
## genome via BLASTx on 20210312.
## Inputs are lists of RNAseq IDs
## Outputs are gzipped FastQ files of extracted reads

###################################################################################
# These variables need to be set by user

threads=40

# FastQ directory
reads_dir=/gscratch/srlab/sam/data/C_bairdi/RNAseq

# BLASTx results directory
blastx_dir=/gscratch/scrubbed/samwhite/outputs/20210312_cbai-vs-copi_diamond_blastx


# Programs array
declare -A programs_array
programs_array=(
[seqkit]="/gscratch/srlab/programs/seqkit-0.15.0" \
[seqkit_grep]="/gscratch/srlab/programs/seqkit-0.15.0 grep"
)

# FastQ array
fastq_array=(${reads_dir}/*fastp-trim*.fq.gz)

# BLASTx results files with query (FastQ read ID) only
blastx_array=(${blastx_dir}/*.blastx.outfmt6-query)


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017


# BLASTx FastQ files
for file in "${!fastq_array[@]}"
do

  # Remove path from transcriptome using parameter substitution
  no_path="${fastq_array[$file]##*/}"
	# Remove extensions from filename
	no_ext=${no_path%.fq.gz}

	# Set output filename
	out_file="${no_ext}_copi-BLASTx-match.fq.gz"

  # Generate checksums for reference
  echo ""
  echo "Generating checksum for ${fastq_array[$file]}."
  md5sum "${fastq_array[$file]}" >> fastq.checksums.md5
  echo "Completed checksum for ${fastq_array[$file]}."
  echo ""

  # Extract reads using results from BLASTx files
  ${programs_array[seqkit_grep]} \
	--pattern-file ${blastx_array[$file]} \
	${fastq_array[$file]} \
	--out-file ${out_file} \
	--threads ${threads}

	# Generate checksums of extracted reads reference
  echo ""
  echo "Generating checksum for ${out_file}."
  md5sum "${out_file}" >> fastq.checksums.md5
  echo "Completed checksum for ${out_file}."
  echo ""

done


###################################################################################

# Capture program options
echo "Logging program options..."
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${program}: "
	echo ""
  # Handle blank argument for help menus
  if [[ "${program}" == "samtools_index" ]] \
  || [[ "${program}" == "samtools_sort" ]] \
  || [[ "${program}" == "samtools_view" ]] \
	|| [[ "${program}" == "seqkit" ]]
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
