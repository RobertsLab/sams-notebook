---
layout: post
title: Genome Annotations - Splice Site and Exon Extractions for C.virginica GCF_002022765.2 Genome Using Hisat2 on Mox
date: '2021-07-20 10:09'
tags: 
  - Hisat2
  - mox
  - Crassostrea virginica
  - Eastern oyster
categories: 
  - Miscellaneous
---
Previously performed quality trimming on the [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) gonad/sperm RNAseq data on [20210714](https://robertslab.github.io/sams-notebook/2021/07/14/Trimming-C.virginica-Gonad-RNAseq-with-FastP-on-Mox.html). Next, I needed to identify exons and splice sites, as well as generate a genome index using [`HISAT2`](https://daehwankimlab.github.io/hisat2/) to be used with [`StringTie`](https://ccb.jhu.edu/software/stringtie/) downstream to identify potential alternative transcripts. This utilized the following NCBI genome files:

- FastA: `GCF_002022765.2_C_virginica-3.0_genomic.fna`

- GFF: `GCF_002022765.2_C_virginica-3.0_genomic.gff`

- GTF: `GCF_002022765.2_C_virginica-3.0_genomic.gtf`

Metadata for this project is here:

https://github.com/RobertsLab/project-oyster-comparative-omics/blob/master/metadata/Virginica-Final-DNA-RNA-Yield.csv

This was run on Mox.

SBATCH script (GitHub):

- [20210720_cvir_GCF_002022765.2_hisat2-build-index-exons-splices.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210720_cvir_GCF_002022765.2_hisat2-build-index-exons-splices.sh)


```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210720_cvir_GCF_002022765.2_hisat2-build-index-exons-splices
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=5-00:00:00
## Memory per node
#SBATCH --mem=200G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210720_cvir_GCF_002022765.2_hisat2-build-index-exons-splices

## Script using HiSat2 to build a genome index, identify exons, and splice sites in NCBI C.virginica genome assemlby using Hisat2.


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use


threads=40
genome_index_name="cvir_GCF_002022765.2"

# Paths to programs
hisat2_dir="/gscratch/srlab/programs/hisat2-2.1.0"
hisat2_build="${hisat2_dir}/hisat2-build"
hisat2_exons="${hisat2_dir}/hisat2_extract_exons.py"
hisat2_splice_sites="${hisat2_dir}/hisat2_extract_splice_sites.py"

# Input/output files
exons="cvir_GCF_002022765.2_hisat2_exons.tab"
genome_dir="/gscratch/srlab/sam/data/C_virginica/genomes"
genome_gff="${genome_dir}/GCF_002022765.2_C_virginica-3.0_genomic.gff"
genome_fasta="${genome_dir}/GCF_002022765.2_C_virginica-3.0_genomic.fna"
splice_sites="cvir_GCF_002022765.2_hisat2_splice_sites.tab"
transcripts_gtf="${genome_dir}/GCF_002022765.2_C_virginica-3.0_genomic.gtf"

# Programs associative array
declare -A programs_array
programs_array=(
[hisat2_build]="${hisat2_build}" \
[hisat2_exons]="${hisat2_exons}" \
[hisat2_splice_sites]="${hisat2_splice_sites}"
)


###################################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Create Hisat2 exons tab file
"${programs_array[hisat2_exons]}" \
"${transcripts_gtf}" \
> "${exons}"

# Create Hisat2 splice sites tab file
"${programs_array[hisat2_splice_sites]}" \
"${transcripts_gtf}" \
> "${splice_sites}"

# Build Hisat2 reference index using splice sites and exons
"${programs_array[hisat2_build]}" \
"${genome_fasta}" \
"${genome_index_name}" \
--exon "${exons}" \
--ss "${splice_sites}" \
-p "${threads}" \
2> hisat2_build.err

# Generate checksums for all files
md5sum * >> checksums.md5

# Copy Hisat2 index files to my data directory for later use with StringTie
rsync -av "${genome_index_name}"*.ht2 "${genome_dir}"


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

Runtime was fast, only 12mins:

![Runtime for Hisat2 indexing for C.virginica GCF_002022765.2 on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210720_cvir_GCF_002022765.2_hisat2-build-index-exons-splices_runtime.png?raw=true)

Output folder:

- []()

