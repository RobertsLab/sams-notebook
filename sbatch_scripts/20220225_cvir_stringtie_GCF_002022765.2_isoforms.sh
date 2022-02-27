#!/bin/bash
## Job Name
#SBATCH --job-name=20220225_cvir_stringtie_GCF_002022765.2_isoforms
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=9-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20220225_cvir_stringtie_GCF_002022765.2_isoforms


## Script using Stringtie with NCBI C.virginica genome assembly
## and HiSat2 index generated on 20210714.

## Expects FastQ input filenames to match <sample name>_R[12].fastp-trim.20bp-5prime.20220224.fq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=28

# Index name for Hisat2 use
# Needs to match index naem used in previous Hisat2 indexing step
genome_index_name="cvir_GCF_002022765.2"

# Location of Hisat2 index files
# Must keep variable name formatting, as it's used by HiSat2
HISAT2_INDEXES=$(pwd)
export HISAT2_INDEXES

# Paths to programs
hisat2_dir="/gscratch/srlab/programs/hisat2-2.1.0"
hisat2="${hisat2_dir}/hisat2"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"
stringtie="/gscratch/srlab/programs/stringtie-1.3.6.Linux_x86_64/stringtie"

# Input/output files
genome_index_dir="/gscratch/srlab/sam/data/C_virginica/genomes"
genome_gff="${genome_index_dir}/GCF_002022765.2_C_virginica-3.0_genomic.gff"
fastq_dir="/gscratch/srlab/sam/data/C_virginica/RNAseq/"
gtf_list="gtf_list.txt"

# Declare associative array of sample names and metadata
declare -A samples_associative_array=()

# Set total number of samples (NOT number of FastQ files)
total_samples=26

# Programs associative array
declare -A programs_array
programs_array=(
[hisat2]="${hisat2}" \
[samtools_index]="${samtools} index" \
[samtools_sort]="${samtools} sort" \
[samtools_view]="${samtools} view" \
[stringtie]="${stringtie}"
)


###################################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

## Load associative array
## Only need to use one set of reads to capture sample name

# Set sample counter for array verification
sample_counter=0

# Load array
for fastq in "${fastq_dir}"*_R1.fastp-trim.20bp-5prime.20220224.fq.gz
do
  # Increment counter
  ((sample_counter+=1))

  # Remove path
  sample_name="${fastq##*/}"

  # Get sample name from first _-delimited field
  sample_name=$(echo "${sample_name}" | awk -F "_" '{print $1}')
  
  # Set treatment condition for each sample
  if [[ "${sample_name}" == "12M" ]] \
  || [[ "${sample_name}" == "22F" ]] \
  || [[ "${sample_name}" == "23M" ]] \
  || [[ "${sample_name}" == "29F" ]] \
  || [[ "${sample_name}" == "31M" ]] \
  || [[ "${sample_name}" == "35F" ]] \
  || [[ "${sample_name}" == "36F" ]] \
  || [[ "${sample_name}" == "3F" ]] \
  || [[ "${sample_name}" == "41F" ]] \
  || [[ "${sample_name}" == "48F" ]] \
  || [[ "${sample_name}" == "50F" ]] \
  || [[ "${sample_name}" == "59M" ]] \
  || [[ "${sample_name}" == "77F" ]] \
  || [[ "${sample_name}" == "9M" ]]
  then
    treatment="exposed"
  else
    treatment="control"
  fi

  # Append to associative array
  samples_associative_array+=(["${sample_name}"]="${treatment}")

done

# Check array size to confirm it has all expected samples
# Exit if mismatch
if [[ "${#samples_associative_array[@]}" != "${sample_counter}" ]] \
|| [[ "${#samples_associative_array[@]}" != "${total_samples}" ]]
  then
    echo "samples_associative_array doesn't have all 26 samples."
    echo ""
    echo "samples_associative_array contents:"
    echo ""
    for item in "${!samples_associative_array[@]}"
    do
      printf "%s\t%s\n" "${item}" "${samples_associative_array[${item}]}"
    done

    exit
fi

# Copy Hisat2 genome index files
rsync -av "${genome_index_dir}"/${genome_index_name}*.ht2 .

for sample in "${!samples_associative_array[@]}"
do

  ## Inititalize arrays
  fastq_array_R1=()
  fastq_array_R2=()

  # Create array of fastq R1 files
  # and generated MD5 checksums file.
  for fastq in "${fastq_dir}""${sample}"*_R1.fastp-trim.20bp-5prime.20220224.fq.gz
  do
    fastq_array_R1+=("${fastq}")
    echo "Generating checksum for ${fastq}..."
    md5sum "${fastq}" >> input_fastqs_checksums.md5
    echo "Checksum for ${fastq} completed."
    echo ""
  done

  # Create array of fastq R2 files
  for fastq in "${fastq_dir}""${sample}"*_R2.fastp-trim.20bp-5prime.20220224.fq.gz
  do
    fastq_array_R2+=("${fastq}")
    echo "Generating checksum for ${fastq}..."
    md5sum "${fastq}" >> input_fastqs_checksums.md5
    echo "Checksum for ${fastq} completed."
    echo ""
  done

  # Create comma-separated lists of FastQs for Hisat2
  printf -v joined_R1 '%s,' "${fastq_array_R1[@]}"
  fastq_list_R1=$(echo "${joined_R1%,}")

  printf -v joined_R2 '%s,' "${fastq_array_R2[@]}"
  fastq_list_R2=$(echo "${joined_R2%,}")

  # Create and switch to dedicated sample directory
  mkdir "${sample_name}" && cd "$_"

  # Hisat2 alignments
  # Sets read group info (RG) using samples array
  "${programs_array[hisat2]}" \
  -x "${genome_index_name}" \
  -1 "${fastq_list_R1}" \
  -2 "${fastq_list_R2}" \
  -S "${sample}".sam \
  --rg-id "${sample}" \
  --rg "SM:""${samples_associative_array[$sample]}" \
  2> "${sample}"_hisat2.err

  # Sort SAM files, convert to BAM, and index
  ${programs_array[samtools_view]} \
  -@ "${threads}" \
  -Su "${sample}".sam \
  | ${programs_array[samtools_sort]} - \
  -@ "${threads}" \
  -o "${sample}".sorted.bam
  # Index BAM
  ${programs_array[samtools_index]} "${sample}".sorted.bam


  # Run stringtie on alignments
  # Uses "-B" option to output tables intended for use in Ballgown
  # Uses "-e" option; recommended when using "-B" option.
  # Limits analysis to only reads alignments matching reference.
  "${programs_array[stringtie]}" "${sample}".sorted.bam \
  -p "${threads}" \
  -o "${sample}".gtf \
  -G "${genome_gff}" \
  -C "${sample}.cov_refs.gtf" \
  -B \
  -e

# Add GTFs to list file, only if non-empty
# Identifies GTF files that only have header
  gtf_lines=$(wc -l < "${sample}".gtf )
  if [ "${gtf_lines}" -gt 2 ]; then
    echo "${sample}.gtf" >> ../"${gtf_list}"
  fi

  # Delete unneeded SAM files
  rm ./*.sam

  # Generate checksums
  for file in *
  do
    md5sum "${file}" >> ${sample}_checksums.md5
  done

  # Move up to orig. working directory
  cd ../

done

# Create singular transcript file, using GTF list file
"${programs_array[stringtie]}" --merge \
"${gtf_list}" \
-p "${threads}" \
-G "${genome_gff}" \
-o "${genome_index_name}".stringtie.gtf

# Delete unneccessary index files
rm "${genome_index_name}"*.ht2


# Generate checksums
for file in *
do
  md5sum "${file}" >> checksums.md5
done

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
