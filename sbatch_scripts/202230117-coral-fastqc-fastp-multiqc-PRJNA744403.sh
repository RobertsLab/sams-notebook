#!/bin/bash
## Job Name
#SBATCH --job-name=202230113-coral-fastqc-fastp-multiqc-PRJNA744403
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=2-00:00:00
## Memory per node
#SBATCH --mem=200G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/202230113-coral-fastqc-fastp-multiqc-PRJNA744403

### FastQC and fastp trimming coral metagenome SRA BioProject PRJNA744403 sequencing data.

### fastp expects input FastQ files to be in format: *.fastp-trim.20220706.fq.gz



###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=40

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5
reads_dir=/gscratch/srlab/sam/data/S_namaycush/RNAseq/
fastq_checksums=input_fastq_checksums.md5

# FastQC output directory
output_dir=$(pwd)

# Paths to programs
fastp=/gscratch/srlab/programs/fastp-0.20.0/fastp
fastqc=/gscratch/srlab/programs/fastqc_v0.11.9/fastqc
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc

## Inititalize arrays
fastq_array_R1=()
R1_names_array=()
trimmed_fastq_array_R1=()


# Programs associative array
declare -A programs_array
programs_array=(
[fastqc]="${fastqc}"
[fastp]="${fastp}" \
[multiqc]="${multiqc}"
)


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Capture date
timestamp=$(date +%Y%m%d)

# Sync raw FastQ files to working directory
rsync --archive --verbose \
"${reads_dir}"*.fastq .

# Create arrays of fastq files and sample names
for fastq in *.fastq
do
  fastq_array_R1+=("${fastq}")
  R1_names_array+=("$(echo "${fastq}" | awk 'FS = "." {print $1}')")
done

# Pass array contents to new variable
raw_fastqc_list=$(echo "${fastq_array_R1[*]}")

# Create MD5 checksums for reference
for fastq in *.fastq
do
  echo "Generating checksum for ${fastq}"
  md5sum ${fastq} | tee --append ${fastq_checksums}
  echo ""
done

# Run FastQC
# NOTE: Do NOT quote ${raw_fastqc_list}
${programs_array[fastqc]} \
--threads ${threads} \
--outdir ${output_dir} \
${raw_fastqc_list}

# Run fastp on files
# Adds JSON report output for downstream usage by MultiQC
for index in "${!fastq_array_R1[@]}"
do
  R1_sample_name=$(echo "${R1_names_array[index]}")
  ${programs_array[fastp]} \
  --in1 ${fastq_array_R1[index]} \
  --thread ${threads} \
  --html "${R1_sample_name}".trimmed."${timestamp}".report.html \
  --json "${R1_sample_name}".trimmed."${timestamp}".report.json \
  --out1 "${R1_sample_name}".trimmed."${timestamp}".fq.gz

  # Generate md5 checksums for newly trimmed files
  {
      md5sum "${R1_sample_name}".trimmed."${timestamp}".fq.gz
  } >> "${trimmed_checksums}"
done



### Run FastQC
### NOTE: Do NOT quote ${trimmed_fastqc_list}

# Create array of trimmed FastQs
trimmed_fastq_array=(*trimmed*.fq.gz)

# Pass array contents to new variable as space-delimited list
trimmed_fastqc_list=$(echo "${trimmed_fastq_array[*]}")

# Run FastQC
${programs_array[fastqc]} \
--threads ${threads} \
--outdir ${output_dir} \
${trimmed_fastqc_list}

# Run MultiQC
${programs_array[multiqc]} .

####################################################################

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
fi


# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log
