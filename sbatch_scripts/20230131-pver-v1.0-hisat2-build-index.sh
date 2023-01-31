#!/bin/bash
## Job Name
#SBATCH --job-name=20230131-pver-v1.0-hisat2-build-index
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230131-pver-v1.0-hisat2-build-index

## Script using HiSat2 to build a genome index, identify exons, and splice sites in P.verrucosa genome assembly using Hisat2.

## Genome and GFF from here: http://pver.reefgenomics.org/download/

## GTF generated on 20260127 by SJW:
## https://robertslab.github.io/sams-notebook/2023/01/27/Data-Wrangling-P.verrucosa-Genome-GFF-to-GTF-Using-gffread.html

###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=40

# Set desired index name
genome_index_name="Pver_genome_assembly_v1.0"

# Paths to programs
hisat2_dir="/gscratch/srlab/programs/hisat2-2.2.0"
hisat2_build="${hisat2_dir}/hisat2-build"
hisat2_exons="${hisat2_dir}/hisat2_extract_exons.py"
hisat2_splice_sites="${hisat2_dir}/hisat2_extract_splice_sites.py"

# Input/output files
exons="Pver_genome_assembly_v1.0_hisat2_exons.tab"
genome_dir="/gscratch/srlab/sam/data/P_verrucosa/genomes"
genome_fasta="${genome_dir}/Pver_genome_assembly_v1.0.fasta"
genome_gff="${genome_index_dir}/Pver_genome_assembly_v1.0.gff3"
splice_sites="Pver_genome_assembly_v1.0_hisat2_splice_sites.tab"
transcripts_gtf="${genome_dir}/Pver_genome_assembly_v1.0.gtf"


# Programs associative array
declare -A programs_array
programs_array=(
[hisat2]="${hisat2}" \
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
echo "Generating Hisat2 exons file..."
"${programs_array[hisat2_exons]}" \
"${transcripts_gtf}" \
> "${exons}"
echo "Exons file created: ${exons}."
echo ""

# Create Hisat2 splice sites tab file
echo "Generating Hisat2 splice sites file..."
"${programs_array[hisat2_splice_sites]}" \
"${transcripts_gtf}" \
> "${splice_sites}"
echo "Splice sites file created: ${splice_sites}."
echo ""


# Build Hisat2 reference index using splice sites and exons
echo "Beginning HiSat2 genome indexing..."
echo ""
"${programs_array[hisat2_build]}" \
"${genome_fasta}" \
"${genome_index_name}" \
--exon "${exons}" \
--ss "${splice_sites}" \
-p "${threads}" \
2> "${genome_index_name}-hisat2_build.stats.txt"
echo "HiSat2 genome index files completed."
echo ""

# Tar/gzip index files into single gzip-ed tarball
tar -cvzf "${genome_index_name}-hisat2-indices.tar.gz" *.ht2

# Remove individual index files
rm *.ht2

# Copy Hisat2 index files to my data directory for later use with StringTie
echo "rsync-ing HiSat2 genome index files to ${genome_dir}."
rsync -avP "${genome_index_name}"*-hisat2-indices.tar.gz "${genome_dir}"
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