#!/bin/bash
## Job Name
#SBATCH --job-name=20230221-pver-diamond-meganizer-E5_RNAseq
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=3-12:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230221-pver-diamond-meganizer-E5_RNAseq

## Perform DIAMOND BLASTx on trimmed P.verrucosa RNA-seq files from 20230215.
## Will be used to view taxonomic breakdown of sequencing reads.

## Expects input FastQ files to be match this pattern: *.fastp-trim.20230215.fq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

fastq_pattern='*.fastp-trim.20230215.fq.gz'

# Program paths
diamond=/gscratch/srlab/programs/diamond-v2.1.1/diamond
meganizer=/gscratch/srlab/programs/MEGAN-6.22.0/tools/daa-meganizer

# DIAMOND NCBI nr database
dmnd_db=/gscratch/srlab/blastdbs/20230215-ncbi-nr/20230215-ncbi-nr.dmnd

# MEGAN mapping files
megan_mapping_dir=/gscratch/srlab/sam/data/databases/MEGAN
megan_mapdb="${megan_mapping_dir}/megan-map-Feb2022.db"

# FastQ files directory
fastq_dir=/gscratch/srlab/sam/data/P_verrucosa/RNAseq

# CPU threads
threads=40

# Programs associative array
declare -A programs_array
programs_array=(
[diamond]="${diamond}" \
[meganizer]="${meganizer}"
)

###################################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017


# Loop through FastQ files, log filenames to fastq_list.txt.
# Run DIAMOND on each FastQ, followed by "MEGANization"
# DO NOT QUOTE ${fastq_pattern}
for fastq in "${fastq_dir}"/${fastq_pattern}
do
	# Log input FastQs
    echo ""
    echo "Generating MD5 checksum for ${fastq}..."
	md5sum "${fastq}" | tee --append input_fastqs-checksums.md5
    echo ""

	# Strip leading path and extensions
	no_path=$(echo "${fastq##*/}")
	no_ext=$(echo "${no_path%%.*}")

	# Run DIAMOND with blastx
	# Output format 100 produces a DAA binary file for use with MEGAN
    echo "Running DIAMOND BLASTx on ${fastq}."
    echo ""
	"${programs_array[diamond]}" blastx \
	--db ${dmnd_db} \
	--query "${fastq}" \
	--out "${no_ext}".blastx.meganized.daa \
	--outfmt 100 \
	--top 5 \
	--block-size 15.0 \
	--index-chunks 4 \
    --threads ${threads}
    echo "DIAMOND BLASTx on ${fastq} complete: ${no_ext}.blastx.meganized.daa"
    echo ""

    # Meganize DAA files
    # Used for ability to import into MEGAN6
    echo "Now MEGANizing ${no_ext}.blastx.meganized.daa"
    "${programs_array[meganizer]}" \
    --in "${no_ext}".blastx.meganized.daa \
    --threads ${threads} \
    --mapDB ${megan_mapdb}
    echo "MEGANization of ${no_ext}.blastx.meganized.daa completed."
    echo ""

done

# Generate MD5 checksums
for file in *
do
  echo ""
  echo "Generating MD5 checksums for ${file}:"
  md5sum "${file}" | tee --append checksums.md5
  echo ""
done

# Generate checksum for MEGAN database(s)
{
    md5sum "${megan_mapdb}"
    md5sum "${dmnd_db}"
} >> checksums.md5

#######################################################################################################

# Capture program options
if [[ "${#programs_array[@]}" -gt 0 ]]; then
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
  echo "Finished logging programs options."
  echo ""
fi


# Document programs in PATH (primarily for program version ID)
echo "Logging system $PATH..."
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log
echo "Finished logging system $PATH."
