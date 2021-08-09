---
layout: post
title: RNAseq Alignments - C.virginica Gonad Data to GCF_002022765.2 Genome Using StringTie on Mox
date: '2021-07-20 10:00'
tags: 
  - stringtie
  - mox
  - RNAseq
  - Crassostrea virginica
  - Eastern oyster
categories: 
  - Miscellaneous
---
As part of identifying alternative transcripts in the [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) gonad RNAseq data we have, I previously used [`HISAT2`](https://daehwankimlab.github.io/hisat2/) to index the NCBI [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) genome and identify exon/splice sites [on 20210720](https://robertslab.github.io/sams-notebook/2021/07/20/Genome-Annotations-Splice-Site-and-Exon-Extractions-for-C.virginica-GCF_002022765.2-Genome-Using-Hisat2-on-Mox.html). Then, I used this genome index to run [`StringTie`](https://ccb.jhu.edu/software/stringtie/) on Mox in order to map sequencing reads to the genome/alternative isoforms.

SBATCH Script (GitHub):

- [20210720_cvir_stringtie_GCF_002022765.2_isoforms.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210720_cvir_stringtie_GCF_002022765.2_isoforms.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210726_cvir_stringtie_GCF_002022765.2_isoforms
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=5-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210726_cvir_stringtie_GCF_002022765.2_isoforms

## Script using Stringtie with NCBI C.virginica genome assembly
## and HiSat2 index generated on 20210714.

## Expects FastQ input filenames to match <sample name>_R1.fastq.gz


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

## Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()
names_array=()

# Copy Hisat2 genome index files
rsync -av "${genome_index_dir}"/${genome_index_name}*.ht2 .

# Create array of fastq R1 files
# and generated MD5 checksums file.
for fastq in "${fastq_dir}"*R1*.gz
do
  fastq_array_R1+=("${fastq}")
  echo "Generating checksum for ${fastq}..."
  md5sum "${fastq}" >> input_fastqs_checksums.md5
  echo "Checksum for ${fastq} completed."
  echo ""
done

# Create array of fastq R2 files
for fastq in "${fastq_dir}"*R2*.gz
do
  fastq_array_R2+=("${fastq}")
  echo "Generating checksum for ${fastq}..."
  md5sum "${fastq}" >> input_fastqs_checksums.md5
  echo "Checksum for ${fastq} completed."
  echo ""
done

# Create array of sample names
## Uses parameter substitution to strip leading path from filename
## Uses awk to parse out sample name from filename
for R1_fastq in "${fastq_dir}"*R1*.gz
do
  names_array+=("$(echo "${R1_fastq#${fastq_dir}}" | awk -F"_" '{print $1}')")
done

# Hisat2 alignments
for index in "${!fastq_array_R1[@]}"
do
  sample_name="${names_array[index]}"

  # Create and switch to dedicated sample directory
  mkdir "${sample_name}" && cd "$_"

  # Generate HiSat2 alignments
  "${programs_array[hisat2]}" \
  -x "${genome_index_name}" \
  -1 "${fastq_array_R1[index]}" \
  -2 "${fastq_array_R2[index]}" \
  -S "${sample_name}".sam \
  2> "${sample_name}"_hisat2.err

  # Sort SAM files, convert to BAM, and index
  ${programs_array[samtools_view]} \
  -@ "${threads}" \
  -Su "${sample_name}".sam \
  | ${programs_array[samtools_sort]} - \
  -@ "${threads}" \
  -o "${sample_name}".sorted.bam
  ${programs_array[samtools_index]} "${sample_name}".sorted.bam

  # Run stringtie on alignments
  # Uses "-B" option to output tables intended for use in Ballgown
  # Uses "-e" option; recommended when using "-B" option.
  # Limits analysis to only reads alignments matching reference.
  "${programs_array[stringtie]}" "${sample_name}".sorted.bam \
  -p "${threads}" \
  -o "${sample_name}".gtf \
  -G "${genome_gff}" \
  -C "${sample_name}.cov_refs.gtf" \
  -B \
  -e

  # Add GTFs to list file, only if non-empty
  # Identifies GTF files that only have header
  gtf_lines=$(wc -l < "${sample_name}".gtf )
  if [ "${gtf_lines}" -gt 2 ]; then
    echo "$(pwd)/${sample_name}.gtf" >> ../"${gtf_list}"
  fi

  # Delete unneded SAM files
  rm ./*.sam


  # Generate checksums
  for file in *
  do
    md5sum "${file}" >> ${sample_name}_checksums.md5
  done

  cd ../

  # Create singular transcript file, using GTF list file
  "${programs_array[stringtie]}" --merge \
  "${gtf_list}" \
  -p "${threads}" \
  -G "${genome_gff}" \
  -o "${genome_index_name}".stringtie.gtf

done


# Delete unneccessary index files
rm "${genome_index_name}"*.ht2


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

Run time was a bit more than 2.5 days:

![StringTie runtime screencap on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210720_cvir_stringtie_GCF_002022765.2_isoforms_runtime.png?raw=true)

Output folder:

- [20210720_cvir_stringtie_GCF_002022765.2_isoforms/](https://gannet.fish.washington.edu/Atumefaciens/20210720_cvir_stringtie_GCF_002022765.2_isoforms/)

The output files consist of the following:

- `cov_refs.gtf`: GTF of fully covered transcripts which match the _C.virginica_ reference genome.
- `.gtf`: GTF of all transcripts/isoforms identified by StringTie in _C.virginica_ reference genome.
- `.sorted.bam`: Sorted BAM file of alignments.
- `.sored.bam.bai`: Corresponding BAM index file.

Links to all files will be at the end of this post. 


| Sample | Overall Alignment Rate |
|--------|------------------------|
| S23M   | 16.51%                 |
| S48M   | 19.93%                 |
| S13M   | 20.66%                 |
| S6M    | 22.04%                 |
| S9M    | 24.54%                 |
| S12M   | 26.33%                 |
| S7M    | 28.05%                 |
| S59M   | 38.13%                 |
| S31M   | 38.90%                 |
| S54F   | 39.25%                 |
| S29F   | 39.57%                 |
| S52F   | 41.24%                 |
| S53F   | 41.60%                 |
| S64M   | 42.08%                 |
| S41F   | 43.26%                 |
| S35F   | 43.95%                 |
| S36F   | 44.49%                 |
| S22F   | 45.04%                 |
| S39F   | 45.80%                 |
| S44F   | 45.89%                 |
| S19F   | 46.90%                 |
| S76F   | 47.24%                 |
| S50F   | 47.80%                 |
| S3F    | 48.89%                 |
| S16F   | 50.29%                 |
| S77F   | 50.31%                 |