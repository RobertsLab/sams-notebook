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

![StringTie runtime screencap on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210726_cvir_stringtie_GCF_002022765.2_isoforms_runtime.png?raw=true)

Output folder:

- [20210720_cvir_stringtie_GCF_002022765.2_isoforms/](https://gannet.fish.washington.edu/Atumefaciens/20210720_cvir_stringtie_GCF_002022765.2_isoforms/)

The output files consist of the following:

- `cov_refs.gtf`: GTF of fully covered transcripts which match the _C.virginica_ reference genome.
- `*.ctab`: Ballgown input files. [Described on Ballgown GitHub page.](https://github.com/alyssafrazee/ballgown#ballgown-readable-expression-output)
- `.err`: Standard error output.
- `.gtf`: GTF of all transcripts/isoforms identified by StringTie in _C.virginica_ reference genome.
- `.sorted.bam`: Sorted BAM file of alignments.
- `.sored.bam.bai`: Corresponding BAM index file.

List of all files will be at the end of this post. 

I noticed something when glancing at the data. Alignment rates are consistently low/lower in males, compared to the females. Not sure of what this means, but figured I'd share it.

Here's a table. The letter `M` or `F` in the sample name column indicates sex.

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


---

Output directory contents:

```
├── [6.1K]  20210726_cvir_stringtie_GCF_002022765.2_isoforms.sh
├── [143M]  cvir_GCF_002022765.2.stringtie.gtf
├── [2.5K]  gtf_list.txt
├── [4.8K]  input_fastqs_checksums.md5
├── [ 12K]  program_options.log
├── [4.7G]  S12M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S12M_checksums.md5
│   ├── [1.3M]  S12M.cov_refs.gtf
│   ├── [136M]  S12M.gtf
│   ├── [ 638]  S12M_hisat2.err
│   ├── [4.5G]  S12M.sorted.bam
│   ├── [1.3M]  S12M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.8G]  S13M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S13M_checksums.md5
│   ├── [637K]  S13M.cov_refs.gtf
│   ├── [136M]  S13M.gtf
│   ├── [ 637]  S13M_hisat2.err
│   ├── [3.6G]  S13M.sorted.bam
│   ├── [861K]  S13M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.2G]  S16F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S16F_checksums.md5
│   ├── [ 15M]  S16F.cov_refs.gtf
│   ├── [136M]  S16F.gtf
│   ├── [ 638]  S16F_hisat2.err
│   ├── [3.0G]  S16F.sorted.bam
│   ├── [1.1M]  S16F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.2G]  S19F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S19F_checksums.md5
│   ├── [ 12M]  S19F.cov_refs.gtf
│   ├── [136M]  S19F.gtf
│   ├── [ 638]  S19F_hisat2.err
│   ├── [3.0G]  S19F.sorted.bam
│   ├── [1.1M]  S19F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.7G]  S22F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S22F_checksums.md5
│   ├── [ 13M]  S22F.cov_refs.gtf
│   ├── [136M]  S22F.gtf
│   ├── [ 638]  S22F_hisat2.err
│   ├── [3.5G]  S22F.sorted.bam
│   ├── [1.2M]  S22F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [5.3G]  S23M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S23M_checksums.md5
│   ├── [1.1M]  S23M.cov_refs.gtf
│   ├── [136M]  S23M.gtf
│   ├── [ 637]  S23M_hisat2.err
│   ├── [5.1G]  S23M.sorted.bam
│   ├── [1004K]  S23M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.2G]  S29F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S29F_checksums.md5
│   ├── [ 12M]  S29F.cov_refs.gtf
│   ├── [137M]  S29F.gtf
│   ├── [ 637]  S29F_hisat2.err
│   ├── [3.0G]  S29F.sorted.bam
│   ├── [1.0M]  S29F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.2G]  S31M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S31M_checksums.md5
│   ├── [571K]  S31M.cov_refs.gtf
│   ├── [136M]  S31M.gtf
│   ├── [ 638]  S31M_hisat2.err
│   ├── [3.0G]  S31M.sorted.bam
│   ├── [1.1M]  S31M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [2.7G]  S35F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S35F_checksums.md5
│   ├── [ 11M]  S35F.cov_refs.gtf
│   ├── [136M]  S35F.gtf
│   ├── [ 637]  S35F_hisat2.err
│   ├── [2.5G]  S35F.sorted.bam
│   ├── [952K]  S35F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [2.9G]  S36F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S36F_checksums.md5
│   ├── [ 11M]  S36F.cov_refs.gtf
│   ├── [136M]  S36F.gtf
│   ├── [ 638]  S36F_hisat2.err
│   ├── [2.7G]  S36F.sorted.bam
│   ├── [1.0M]  S36F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.3G]  S39F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S39F_checksums.md5
│   ├── [ 12M]  S39F.cov_refs.gtf
│   ├── [136M]  S39F.gtf
│   ├── [ 638]  S39F_hisat2.err
│   ├── [3.0G]  S39F.sorted.bam
│   ├── [1.1M]  S39F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [2.9G]  S3F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 468]  S3F_checksums.md5
│   ├── [ 13M]  S3F.cov_refs.gtf
│   ├── [136M]  S3F.gtf
│   ├── [ 637]  S3F_hisat2.err
│   ├── [2.7G]  S3F.sorted.bam
│   ├── [1022K]  S3F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.1G]  S41F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S41F_checksums.md5
│   ├── [ 13M]  S41F.cov_refs.gtf
│   ├── [137M]  S41F.gtf
│   ├── [ 638]  S41F_hisat2.err
│   ├── [2.9G]  S41F.sorted.bam
│   ├── [1.0M]  S41F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.4G]  S44F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S44F_checksums.md5
│   ├── [ 14M]  S44F.cov_refs.gtf
│   ├── [137M]  S44F.gtf
│   ├── [ 638]  S44F_hisat2.err
│   ├── [3.2G]  S44F.sorted.bam
│   ├── [1.1M]  S44F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [8.3G]  S48M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S48M_checksums.md5
│   ├── [1.1M]  S48M.cov_refs.gtf
│   ├── [136M]  S48M.gtf
│   ├── [ 640]  S48M_hisat2.err
│   ├── [8.1G]  S48M.sorted.bam
│   ├── [1.9M]  S48M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [2.7G]  S50F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S50F_checksums.md5
│   ├── [ 13M]  S50F.cov_refs.gtf
│   ├── [136M]  S50F.gtf
│   ├── [ 637]  S50F_hisat2.err
│   ├── [2.5G]  S50F.sorted.bam
│   ├── [980K]  S50F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.3G]  S52F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S52F_checksums.md5
│   ├── [ 16M]  S52F.cov_refs.gtf
│   ├── [137M]  S52F.gtf
│   ├── [ 638]  S52F_hisat2.err
│   ├── [3.1G]  S52F.sorted.bam
│   ├── [1.1M]  S52F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.1G]  S53F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S53F_checksums.md5
│   ├── [ 12M]  S53F.cov_refs.gtf
│   ├── [136M]  S53F.gtf
│   ├── [ 637]  S53F_hisat2.err
│   ├── [2.9G]  S53F.sorted.bam
│   ├── [996K]  S53F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.2G]  S54F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S54F_checksums.md5
│   ├── [ 12M]  S54F.cov_refs.gtf
│   ├── [136M]  S54F.gtf
│   ├── [ 637]  S54F_hisat2.err
│   ├── [3.0G]  S54F.sorted.bam
│   ├── [1023K]  S54F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.1G]  S59M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S59M_checksums.md5
│   ├── [8.8M]  S59M.cov_refs.gtf
│   ├── [136M]  S59M.gtf
│   ├── [ 637]  S59M_hisat2.err
│   ├── [2.9G]  S59M.sorted.bam
│   ├── [934K]  S59M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.6G]  S64M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S64M_checksums.md5
│   ├── [7.2M]  S64M.cov_refs.gtf
│   ├── [136M]  S64M.gtf
│   ├── [ 638]  S64M_hisat2.err
│   ├── [3.4G]  S64M.sorted.bam
│   ├── [1.4M]  S64M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [5.5G]  S6M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 468]  S6M_checksums.md5
│   ├── [1.0M]  S6M.cov_refs.gtf
│   ├── [136M]  S6M.gtf
│   ├── [ 638]  S6M_hisat2.err
│   ├── [5.3G]  S6M.sorted.bam
│   ├── [1.3M]  S6M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.4G]  S76F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S76F_checksums.md5
│   ├── [ 12M]  S76F.cov_refs.gtf
│   ├── [136M]  S76F.gtf
│   ├── [ 638]  S76F_hisat2.err
│   ├── [3.2G]  S76F.sorted.bam
│   ├── [1.1M]  S76F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [3.6G]  S77F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S77F_checksums.md5
│   ├── [ 14M]  S77F.cov_refs.gtf
│   ├── [136M]  S77F.gtf
│   ├── [ 639]  S77F_hisat2.err
│   ├── [3.4G]  S77F.sorted.bam
│   ├── [1.2M]  S77F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.1G]  S7M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 468]  S7M_checksums.md5
│   ├── [1.4M]  S7M.cov_refs.gtf
│   ├── [136M]  S7M.gtf
│   ├── [ 638]  S7M_hisat2.err
│   ├── [3.9G]  S7M.sorted.bam
│   ├── [1.2M]  S7M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [5.1G]  S9M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 468]  S9M_checksums.md5
│   ├── [992K]  S9M.cov_refs.gtf
│   ├── [136M]  S9M.gtf
│   ├── [ 638]  S9M_hisat2.err
│   ├── [4.9G]  S9M.sorted.bam
│   ├── [1.3M]  S9M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [ 11K]  slurm-2112475.out
└── [ 996]  system_path.log
```