---
layout: post
title: FastQ Read Alignment and Quantification - P.generosa Water Metagenomic Libraries to MetaGeneMark Assembly with Hisat2 on Mox
date: '2020-07-31 13:41'
tags:
  - metagenemark
  - alignment
  - hisat2
  - Panopea generosa
  - geoduck
  - metagenomics
  - mox
categories:
  - Miscellaneous
---


SBATCH script (GitHub):

- [20200731_metagenome_hisat2_alignments.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200731_metagenome_hisat2_alignments.sh)


```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_hisat2_transcriptome_alignments
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=7-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200731_metagenome_hisat2_alignments


###################################################################################
# These variables need to be set by user

# Assign Variables
reads_dir=/gscratch/srlab/sam/data/metagenomics/P_generosa/sequencing
assembly=/gscratch/srlab/sam/data/metagenomics/P_generosa/assemblies/20190103-mgm-nucleotides.fa
threads=28
# Set hisat2 basename
hisat2_basename=20190103-mgm

# Array of the various comparisons to evaluate
libraries_array=(
MG_1 \
MG_2 \
MG_3 \
MG_5 \
MG_6 \
MG_7
)


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
## Hisat2 requires Python2. Fails with syntax error if using Python3
#module load intel-python3_2017
module load intel-python2_2017

# Program directories
hisat2_dir="/gscratch/srlab/programs/hisat2-2.2.0/"
samtools_dir="/gscratch/srlab/programs/samtools-1.10/samtools"

# Programs array
declare -A programs_array
programs_array=(
[hisat2]="${hisat2_dir}hisat2" \
[hisat2_build]="${hisat2_dir}hisat2-build" \
[samtools_view]="${samtools_dir} view" \
[samtools_sort]="${samtools_dir} sort" \
[samtools_index]="${samtools_dir} index"
)

# Capture FastA checksums for verification
echo "Generating checksum for ${assembly}"
md5sum "${assembly}" >> fasta.checksums.md5
echo "Finished generating checksum for ${assembly}"
echo ""

# Build hisat2 index
${programs_array[hisat2_build]} \
-f "${assembly}" \
"${hisat2_basename}" \
-p ${threads}

# Loop through each library
for library in "${libraries_array[@]}"
do

  ## Inititalize arrays
  R1_array=()
  R2_array=()
  reads_array=()

  # Variables
  R1_list=""
  R2_list=""


  if [[ "${library}" == "MG_1" ]]; then

    reads_array=("${reads_dir}"/*MG_1*.fq.gz)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/*MG_1*R1.fq.gz)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/*MG_1*R2.fq.gz)



  elif [[ "${library}" == "MG_2" ]]; then

    reads_array=("${reads_dir}"/*MG_2*.fq.gz)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/*MG_2*R1.fq.gz)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/*MG_2*R2.fq.gz)

  elif [[ "${library}" == "MG_3" ]]; then

    reads_array=("${reads_dir}"/*MG_3*.fq.gz)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/*MG_3*R1.fq.gz)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/*MG_3*R2.fq.gz)

  elif [[ "${library}" == "MG_5" ]]; then

    reads_array=("${reads_dir}"/*MG_5*.fq.gz)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/*MG_5*R1.fq.gz)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/*MG_5*R2.fq.gz)

  elif [[ "${library}" == "MG_6" ]]; then

    reads_array=("${reads_dir}"/*MG_6*.fq.gz)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/*MG_6*R1.fq.gz)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/*MG_6*R2.fq.gz)

  elif [[ "${library}" == "MG_7" ]]; then

    reads_array=("${reads_dir}"/*MG_7*.fq.gz)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/*MG_7*R1.fq.gz)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/*MG_7*R2.fq.gz)


  fi

  # Create list of fastq files used in analysis
  ## Uses parameter substitution to strip leading path from filename
  printf "%s\n" "${reads_array[@]##*/}" >> "${library}".fastq.list.txt

  # Create comma-separated lists of FastQ reads
  R1_list=$(echo "${R1_array[@]}" | tr " " ",")
  R2_list=$(echo "${R2_array[@]}" | tr " " ",")

  # Align reads to metagenome assembly
  ${programs_array[hisat2]} \
  --threads ${threads} \
  -x "${hisat2_basename}" \
  -q \
  -1 "${R1_list}" \
  -2 "${R2_list}" \
  -S "${library}".sam \
  2>&1 | tee "${library}".alignment_stats.txt

  # Convert SAM file to BAM
  ${programs_array[samtools_view]} \
  --threads ${threads} \
  -b "${library}".sam \
  > "${library}".bam

  # Sort BAM
  ${programs_array[samtools_sort]} \
  --threads ${threads} \
  "${library}".bam \
  -o "${library}".sorted.bam

  # Index for use in IGV
  ##-@ specifies thread count; --thread option not available in samtools index
  ${programs_array[samtools_index]} \
  -@ ${threads} \
  "${library}".sorted.bam

  # Remove original SAM and unsorted BAM
  rm "${library}".bam "${library}".sam


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


# Capture program options
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${program}: "
	echo ""
	${programs_array[$program]} --help
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
  } &>> program_options.log || true
done
```

---

#### RESULTS

Output folder:

- []()
