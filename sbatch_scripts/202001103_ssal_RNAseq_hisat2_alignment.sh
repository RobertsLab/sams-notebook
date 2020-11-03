#!/bin/bash
## Job Name
#SBATCH --job-name=202001103_ssal_RNAseq_hisat2_alignment
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/202001103_ssal_RNAseq_hisat2_alignment


### S.salar RNAseq Hisat2 alignment.




###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=27

# Input/output files
fastq_checksums=fastq_checksums.md5
fastq_dir="/gscratch/srlab/sam/data/S_salar/RNAseq/"
genome_fasta="/gscratch/srlab/sam/data/S_salar/genomes/GCF_000233375.1_ICSASG_v2_genomic.fa"

genome_index_name="GCF_000233375.1_ICSASG_v2"

# Paths to programs
hisat2_dir="/gscratch/srlab/programs/hisat2-2.1.0"
hisat2="${hisat2_dir}/hisat2"
hisat2_build="${hisat2_dir}/hisat2-build"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"

## Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()
names_array=()



# Programs associative array
declare -A programs_array
programs_array=(
[hisat2]="${hisat2}" \
[hisat2-build]="${hisat2_build}"
[samtools_index]="${samtools} index" \
[samtools_sort]="${samtools} sort" \
[samtools_view]="${samtools} view"
)


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Capture date
timestamp=$(date +%Y%m%d)

# Create array of fastq R1 files
for fastq in "${fastq_dir}"*_1.fastp-trim.20201029.fq.gz
do
    fastq_array_R1+=("${fastq}")
  # Create array of sample names
  ## Uses parameter substitution to strip leading path from filename
  ## Uses awk to parse out sample name from filename
  names_array+=($(echo "${fastq#${fastq_dir}}" | awk -F"[_]" '{print $1 "_" $2}'))
done

# Create array of fastq R2 files
for fastq in "${fastq_dir}"*_2.fastp-trim.20201029.fq.gz
do
  fastq_array_R2+=("${fastq}")
done


# Build Hisat2 reference index
"${programs_array[$hisat2_build]}" \
"${genome_fasta}" \
"${genome_index_name}" \
-p "${threads}" \
2> hisat2_build.err


# Hisat2 alignments
for index in "${!fastq_array_R1[@]}"
do
  # Get current sample name
  sample_name=$(echo "${names_array[index]}")

  # Run Hisat2
  # Sets --dta which tailors output for downstream transcriptome assemblers (e.g. Stringtie)
  # Sets --new-summary option for use with MultiQC
  "${programs_array[$hisat2]}" \
  -x "${genome_index_name}" \
  --dta \
  --new-summary \
  -1 "${fastq_array_R1[index]}" \
  -2 "${fastq_array_R2[index]}" \
  -S "${sample_name}".sam \
  2> "${sample_name}"_hisat2.err
# Sort SAM files, convert to BAM
  "${programs_array[$samtools_view]}" \
  -@ "${threads}" \
  -Su "${sample_name}".sam \
  | "${programs_array[$samtools_sort]}" - \
  -@ "${threads}" \
  -o "${sample_name}".sorted.bam
  # Index sorted BAM file
  "${programs_array[$samtools_index]}" "${sample_name}".sorted.bam
done

# Create list of fastq files used in analysis
## Uses parameter substitution to strip leading path from filename
for fastq in "${fastq_dir}"*fastp-trim.20201029.fq.gz
do
  echo "${fastq#${fastq_dir}}" >> fastq.list.txt
  md5sum "${fastq}" >> ${fastq_checksums}
done

# Capture program options
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${program}: "
	echo ""
	${programs_array[$program]} -h
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true

  # If MultiQC is in programs_array, copy the config file to this directory.
  if [[ "${program}" == "multiqc" ]]; then
  	cp --preserve ~/.multiqc_config.yaml "${timestamp}_multiqc_config.yaml"
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
