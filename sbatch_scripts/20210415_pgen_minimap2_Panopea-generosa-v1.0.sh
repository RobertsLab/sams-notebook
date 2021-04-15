#!/bin/bash
## Job Name
#SBATCH --job-name=20210415_pgen_minimap2_Panopea-generosa-v1.0
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=30-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210415_pgen_minimap2_Panopea-generosa-v1.0

### Map trimmed 10x Genomics reads to Panopea-generosa_v1.0 assembly
### for use with BlobToolKit
### Output is BAM file


###################################################################################
# These variables need to be set by user

# Set working directory
wd=$(pwd)

# Set number of CPUs to use
threads=40

# Input/output files
genome_fasta=/gscratch/srlab/sam/data/P_generosa/genomes/Panopea-generosa-v1.0.fa
fastq_checksums=fastq_checksums.md5
trimmed_reads_dir=/gscratch/scrubbed/samwhite/outputs/20210401_pgen_fastp_10x-genomics
bam_out=20210415_pgen_10x-genomics_Pgen-v1.0-assembly.reads

# Programs
## Minimap2
minimap2=/gscratch/srlab/programs/minimap2-2.18_x64-linux/minimap2

## Samtools
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"


# Programs associative array
declare -A programs_array
programs_array=(
[minimap2]=${minimap2} \
[samtools_sort]="${samtools} sort"
)


###################################################################################

# Exit script if any command fails
set -e

# Rename orginal FastA to comply with BTK naming requirements
rsync -av ${orig_fasta} ${genome_fasta}

# Generate checksum for "new" FastA
md5sum ${genome_fasta} > genome_fasta.md5

# Concatenate all R1 reads
for fastq in "${trimmed_reads_dir}"/*R1*.fq.gz
do
  echo ""
  echo "Generating checksum for ${fastq}"
  md5sum "${fastq}" >> ${fastq_checksums}
  echo "Checksum generated for ${fastq}."

  echo ""
  echo "Concatenating ${fastq} to reads_1.fastq.gz"
  cat "${fastq}" >> reads_1.fastq.gz
  echo "Finished concatenating ${fastq} to reads_1.fastq.gz"
done

# Concatenate all R2 reads
for fastq in "${trimmed_reads_dir}"/*R2*.fq.gz
do
  echo ""
  echo "Generating checksum for ${fastq}"
  md5sum "${fastq}" >> ${fastq_checksums}
  echo "Checksum generated for ${fastq}."

  echo ""
  echo "Concatenating ${fastq} to reads_2.fastq.gz"
  cat "${fastq}" >> reads_2.fastq.gz
  echo "Finished concatenating ${fastq} to reads_2.fastq.gz"
done

# Run minimap2
${programs_array[minimap2]} \
-ax sr \
-t ${threads} \
${genome_fasta} \
reads_1.fastq.gz \
reads_2.fastq.gz \
| ${programs_array[samtools_sort]} \
--threads ${threads} \
--output-fmt BAM \
-o ${bam_out}

###################################################################################

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

echo "Finished logging system PATH"