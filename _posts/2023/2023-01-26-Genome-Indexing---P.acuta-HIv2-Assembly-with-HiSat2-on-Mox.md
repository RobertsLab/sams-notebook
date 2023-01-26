---
layout: post
title: Genome Indexing - P.acuta HIv2 Assembly with HiSat2 on Mox
date: '2023-01-26 14:06'
tags: 
  - Pocillopora acuta
  - coral
  - HIv2
  - hisat2
  - mox
  - index
categories: 
  - Miscellaneous
---
Working on [this Issue regarding adding coral genomes to our Handbook](https://github.com/RobertsLab/resources/issues/1571) (GitHub) and needed to generate a [`HISAT2`](https://daehwankimlab.github.io/hisat2/) index to add to [The Roberts Lab Handbook Genomic Resources](https://robertslab.github.io/resources/Genomic-Resources/).

Of note, I was unable to create exon and splice site files from [the GTF created earlier today](https://robertslab.github.io/sams-notebook/2023/01/26/Data-Wrangling-P.acuta-Genome-GFF-to-GTF-Conversion-Using-gffread.html). The [`HISAT2`](https://daehwankimlab.github.io/hisat2/) scripts used to generate the exon and splice site files end up empty. Some brief troubleshooting with those two Python scripts don't yield any output of any kind - no error messages... So, skipping this aspect of genome indexing for now.

Ran [`HISAT2`](https://daehwankimlab.github.io/hisat2/) on Mox.

SBATCH script (GitHub):

- [20230126-pacu-HIv2.assembly-hisat2-build-index.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20230126-pacu-HIv2.assembly-hisat2-build-index.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20230126-pacu-HIv2.assembly-hisat2-build-index
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=5-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230126-pacu-HIv2-hisat2-build-index

## Script using HiSat2 to build a genome index, identify exons, and splice sites in P.acuta genome assembly using Hisat2.

## Genome and GFF from here: http://cyanophora.rutgers.edu/Pocillopora_acuta/

## FYI - can't seem to get exon/splice sites to work with the GTF generated on 20260126 by SJW:
## https://robertslab.github.io/sams-notebook/2023/01/26/Data-Wrangling-P.acuta-Genome-GFF-to-GTF-Conversion-Using-gffread.html

###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=40

# Set desired index name
genome_index_name="Pocillopora_acuta_HIv2"

# Paths to programs
hisat2_dir="/gscratch/srlab/programs/hisat2-2.2.0"
hisat2_build="${hisat2_dir}/hisat2-build"

# Input/output files
genome_dir="/gscratch/srlab/sam/data/P_acuta/genomes"
genome_fasta="${genome_dir}/Pocillopora_acuta_HIv2.assembly.fasta"


# Programs associative array
declare -A programs_array
programs_array=(
[hisat2_build]="${hisat2_build}"
)


###################################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Build Hisat2 reference index using splice sites and exons
echo "Beginning HiSat2 genome indexing..."
echo ""
"${programs_array[hisat2_build]}" \
"${genome_fasta}" \
"${genome_index_name}" \
-p "${threads}" \
2> "${genome_index_name}-hisat2_build.stats.txt"
echo "HiSat2 genome index files completed."
echo ""

# Tar/gzip index files into single gzip-ed tarball
tar cvzf "${genome_index_name}-hisat2-indices.tar.gz" *.ht2

# Remove individual index files
rm *.ht2

# Copy Hisat2 index files to my data directory for later use with StringTie
echo "rsync-ing HiSat2 genome index files to ${genome_dir}."
rsync -av "${genome_index_name}"*-hisat2-indices.tar.gz "${genome_dir}"
echo "rsync completed."
echo ""

# Generate checksums for all files
echo "Generating checksums..."
md5sum ./* | tee --append checksums.md5
echo ""
echo "Finished generating checksums. See file: checksums.md5"
echo ""

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
```


---

#### RESULTS

Run time was fast, just over 3mins:

![Screenshot showing HiSat2 indexing of P.acuta HIv2 genome run time of 3mins 11secs on Mox.](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20230126-pacu-HIv2.assembly-hisat2-build-index_runtime.png?raw=true)

Output folder:

- [20230126-pacu-HIv2-hisat2-build-index/](https://gannet.fish.washington.edu/Atumefaciens/20230126-pacu-HIv2-hisat2-build-index/)

  #### HiSat2 Genome Index

    - [20230126-pacu-HIv2-hisat2-build-index/Pocillopora_acuta_HIv2-hisat2-indices.tar.gz](https://gannet.fish.washington.edu/Atumefaciens/20230126-pacu-HIv2-hisat2-build-index/Pocillopora_acuta_HIv2-hisat2-indices.tar.gz) (tarball gzip; 564MB)

    - MD5 checksum: `589bdcd2c9e5eb161ceff072f5eda531`

    - Needs to be unpacked before use!