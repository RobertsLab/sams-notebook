---
layout: post
title: Genome Indexing - M.capitata NCBI GCA_006542545.1 with HiSat2 on Mox
date: '2023-01-25 10:57'
tags: 
  - hisat2
  - Montipora capitata
  - coral
  - GCA_006542545.1
  - mox
categories: 
  - Miscellaneous
---
Working on [this Issue regarding adding coral genomes to our Handbook](https://github.com/RobertsLab/resources/issues/1571) (GitHub) and needed to generate a [`HISAT2`](https://daehwankimlab.github.io/hisat2/) index to add to [The Roberts Lab Handbook Genomic Resources](https://robertslab.github.io/resources/Genomic-Resources/).

Ran [`HISAT2`](https://daehwankimlab.github.io/hisat2/) on Mox.

SBATCH script (GitHub):

- [20230125-mcap-hisat2-GCA_006542545.1-index.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20230125-mcap-hisat2-GCA_006542545.1-index.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20230125-mcap-hisat2-GCA_006542545.1-index
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=4-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230125-mcap-hisat2-GCA_006542545.1-index

## Script for creating HiSat2 genome index file for M.capitata NCBI genome GCA_006542545.1.

###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=28

# Set species abbreviation
species="mcap"

# Index name for Hisat2 use
# Needs to match index naem used in previous Hisat2 indexing step
genome_index_name="${species}-GCA_006542545.1"

# Paths to programs
hisat2_dir="/gscratch/srlab/programs/hisat2-2.1.0"
hisat2_build="${hisat2_dir}/hisat2-build"

# Input/output files
genome_dir="/gscratch/srlab/sam/data/M_capitata/genomes"
genome_fasta="${genome_dir}/GCA_006542545.1_Mcap_UHH_1.1_genomic.fna"

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
echo "Rsyncing HiSat2 genome index files to ${genome_dir}."
rsync -av "${genome_index_name}"*-hisat2-indices.tar.gz "${genome_dir}"
echo "Rsync completed."
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

Output folder:

- []()

