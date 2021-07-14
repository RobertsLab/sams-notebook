---
layout: post
title: Trimming - C.virginica Gonad RNAseq with FastP on Mox
date: '2021-07-14 10:57'
tags: 
  - fastp
  - mox
  - Crassostrea virginica
  - Eastern oyster
categories: 
  - Miscellaneous
---
Needed to trim the [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) gonad RNAseq data we [received on 20210528](https://robertslab.github.io/sams-notebook/2021/05/28/Data-Received-Yaamini's-C.virginica-WGBS-and-RNAseq-Data-from-ZymoResearch.html). Decided to run [`fastp`](https://github.com/OpenGene/fastp), followed with [`MultiQC`](https://multiqc.info/), on Mox.

SBATCH script (GitHub):

- []()

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210714_cvir_gonad_RNAseq_fastp_trimming
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-00:00:00
## Memory per node
#SBATCH --mem=200G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210714_cvir_gonad_RNAseq_fastp_trimming


### Yaamini's C.virginica gonad RNAseq trimming using fastp, and MultiQC.

### Expects input FastQ files to be in format: *_R1.fastq.gz



###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=40

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5
raw_reads_dir=/gscratch/scrubbed/samwhite/data/C_virginica/RNAseq/
fastq_checksums=raw_fastq_checksums.md5

# Paths to programs
fastp=/gscratch/srlab/programs/fastp-0.20.0/fastp
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc

## Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()
R1_names_array=()
R2_names_array=()


# Programs associative array
declare -A programs_array
programs_array=(
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
"${raw_reads_dir}"*.gz .

# Create arrays of fastq R1 files and sample names
for fastq in *_R1.fastq.gz
do
  fastq_array_R1+=("${fastq}")
  R1_names_array+=("$(echo "${fastq}" | awk 'BEGIN {FS = "[._]";OFS = "_"} {print $1, $2}')")
done

# Create array of fastq R2 files
for fastq in *_R2.fastq.gz
do
  fastq_array_R2+=("${fastq}")
  R2_names_array+=("$(echo "${fastq}" |awk 'BEGIN {FS = "[._]";OFS = "_"} {print $1, $2}')")
done

# Create list of fastq files used in analysis
# Create MD5 checksum for reference
for fastq in *.gz
do
  echo "${fastq}" >> input.fastq.list.txt
  md5sum ${fastq} >> ${fastq_checksums}
done

# Run fastp on files
# Adds JSON report output for downstream usage by MultiQC
for index in "${!fastq_array_R1[@]}"
do
  R1_sample_name=$(echo "${R1_names_array[index]}")
  R2_sample_name=$(echo "${R2_names_array[index]}")
  ${fastp} \
  --in1 ${fastq_array_R1[index]} \
  --in2 ${fastq_array_R2[index]} \
  --detect_adapter_for_pe \
  --thread ${threads} \
  --html "${R1_sample_name}".fastp-trim."${timestamp}".report.html \
  --json "${R1_sample_name}".fastp-trim."${timestamp}".report.json \
  --out1 "${R1_sample_name}".fastp-trim."${timestamp}".fq.gz \
  --out2 "${R2_sample_name}".fastp-trim."${timestamp}".fq.gz

  # Generate md5 checksums for newly trimmed files
  {
      md5sum "${R1_sample_name}".fastp-trim."${timestamp}".fq.gz
      md5sum "${R2_sample_name}".fastp-trim."${timestamp}".fq.gz
  } >> "${trimmed_checksums}"
  # Remove original FastQ files
  echo ""
  echo " Removing ${fastq_array_R1[index]} and ${fastq_array_R2[index]}."
  rm "${fastq_array_R1[index]}" "${fastq_array_R2[index]}"
done

# Run MultiQC
${multiqc} .

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
```


---

#### RESULTS

Output folder:

- []()

