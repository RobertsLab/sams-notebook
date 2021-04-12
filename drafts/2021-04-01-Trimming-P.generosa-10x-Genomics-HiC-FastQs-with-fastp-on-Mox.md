---
layout: post
title: Trimming P.generosa 10x Genomics HiC FastQs with fastp on Mox
date: '2021-04-01 11:33'
tags: 
  - HiC
  - mox
  - fastp
  - trimming
  - Panopea generosa
  - geoduck
  - 10x genomics
categories: 
  - Miscellaneous
---
[Steven asked me to try running Blob Tool Kit](https://github.com/RobertsLab/resources/issues/1118) to identify potential contaminating sequence in our [_Panopea generosa_ (Pacific geoduck)](http://en.wikipedia.org/wiki/Geoduck) genome assembly (v1.0). In preparation for running [Blob Tool Kit](https://blobtoolkit.genomehubs.org/), I needed to trim the 10x Genomics FastQ data used by Phase Genomics. Files were trimmed using [`fastp`](https://github.com/OpenGene/fastp) on Mox.

SBATCH script (GitHub):

- [20210401_pgen_fastp_10x-genomics.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210401_pgen_fastp_10x-genomics.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210401_pgen_fastp_10x-genomics
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210401_pgen_fastp_10x-genomics


### Fastp 10x Genomics data used for P.generosa genome assembly by Phase Genomics.
### In preparation for use in BlobToolKit

### Expects input filenames to be in format: *.fastq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=40

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5
raw_reads_dir=/gscratch/scrubbed/samwhite/data/P_generosa/DNAseq/
fastq_checksums=raw_fastq_checksums.md5

# Paths to programs
fastp=/gscratch/srlab/programs/fastp-0.20.0/fastp
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc

## Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()


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
"${raw_reads_dir}"*.fastq.gz .

# Create arrays of fastq R1 files and sample names
for fastq in *R1*.fastq.gz
do
  fastq_array_R1+=("${fastq}")
done

# Create array of fastq R2 files
for fastq in *R2*.fastq.gz
do
  fastq_array_R2+=("${fastq}")
done


# Run fastp on files
# Trim 10bp from 5' from each read
# Adds JSON report output for downstream usage by MultiQC
for index in "${!fastq_array_R1[@]}"
do
  # Remove .fastq.gz from end of file names
  R1_sample_name=$(echo "${fastq_array_R1[index]}" | sed 's/.fastq.gz//')
  R2_sample_name=$(echo "${fastq_array_R2[index]}" | sed 's/.fastq.gz//')

  # Get sample name without R1/R2 labels
  sample_name=$(echo "${fastq_array_R1[index]}" | sed 's/_R[12].*//')

  echo ""
  echo "fastp started on ${sample_name} FastQs."

  # Run fastp
  # Specifies reports in HTML and JSON formats
  ${fastp} \
  --in1 ${fastq_array_R1[index]} \
  --in2 ${fastq_array_R2[index]} \
  --detect_adapter_for_pe \
  --thread ${threads} \
  --html "${sample_name}".fastp-trim."${timestamp}".report.html \
  --json "${sample_name}".fastp-trim."${timestamp}".report.json \
  --out1 "${R1_sample_name}".fastp-trim."${timestamp}".fq.gz \
  --out2 "${R2_sample_name}".fastp-trim."${timestamp}".fq.gz

  echo "fastp completed on ${sample_name} FastQs"
  echo ""

  # Generate md5 checksums for newly trimmed files
  {
  md5sum "${R1_sample_name}".fastp-trim."${timestamp}".fq.gz
  md5sum "${R2_sample_name}".fastp-trim."${timestamp}".fq.gz
  } >> "${trimmed_checksums}"


  # Create MD5 checksum for reference
  {
    md5sum "${fastq_array_R1[index]}"
    md5sum "${fastq_array_R2[index]}"
  }  >> ${fastq_checksums}

  # Remove original FastQ files
  rm "${fastq_array_R1[index]}" "${fastq_array_R2[index]}"
done

# Run MultiQC
${programs_array[multiqc]} .

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
```


---

#### RESULTS

There's a lot of data, so this took a pretty long time. Just under 7hrs!

![Fastp runtime screencap](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210401_pgen_fastp_10x-genomics_runtime.png?raw=true)

Output folder:

- [20210401_pgen_fastp_10x-genomics/](https://gannet.fish.washington.edu/Atumefaciens/20210401_pgen_fastp_10x-genomics/)

  - List of input FastQ files (text):

    - [raw_fastq_checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20210401_pgen_fastp_10x-genomics/raw_fastq_checksums.md5)

  - [`MultiQC`](https://multiqc.info/) Report (HTML; open in browser):

    - [multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20210401_pgen_fastp_10x-genomics/multiqc_report.html)

  - Trimmed FastQ list/checksums (text):

    - [trimmed_fastq_checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20210401_pgen_fastp_10x-genomics/trimmed_fastq_checksums.md5)

Alrighty, I will use these trimmed FastQ files in a subsequent run of [Blob Tool Kit](https://blobtoolkit.genomehubs.org/) with out [_Panopea generosa_ (Pacific geoduck)](http://en.wikipedia.org/wiki/Geoduck) v1.0 genome assembly and see what we find!