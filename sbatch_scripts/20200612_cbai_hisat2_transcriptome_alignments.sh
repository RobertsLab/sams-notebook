#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_hisat2_transcriptome_alignments
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=20-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200612_cbai_hisat2_transcriptome_alignments


###################################################################################
# These variables need to be set by user

# Assign Variables
reads_dir=/gscratch/srlab/sam/data/C_bairdi/RNAseq
transcriptomes_dir=/gscratch/srlab/sam/data/C_bairdi/transcriptomes
threads=28

# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
transcriptomes_array=(
"${transcriptomes_dir}"/cbai_transcriptome_v1.0.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v1.5.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v1.6.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v1.7.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v2.0.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v2.1.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v3.0.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v3.1.fasta
)


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log

# Program directories
hisat2_dir="/gscratch/srlab/programs/hisat2-2.2.0/"
samtools_dir="/gscratch/srlab/programs/samtools-1.10/samtools"

# Programs array
declare -A programs_array
programs_array=(
[hisat2]="${hisat2_dir}hisat2" \
[hisat2_build]="${hisat2_dir}hisat2-build" \
[samtools_view]="${samtools_dir} view" \
[samtools_sort]="${samtools_dir} sort"
)


# Loop through each transcriptome
for transcriptome in "${!transcriptomes_array[@]}"
do

  ## Inititalize arrays
  R1_array=()
  R2_array=()
  reads_array=()

  # Variables
  R1_list=""
  R2_list=""

  # Strip leading path from transcriptome filename
  transcriptome_name="${transcriptomes_array[$transcriptome]##*/}"


  # Capture FastA checksums for verification
  echo "Generating checksum for ${transcriptome_name}"
  md5sum "${transcriptomes_array[transcriptome]}" >> fasta.checksums.md5
  echo "Finished generating checksum for ${transcriptome_name}"
  echo ""

  if [[ "${transcriptome_name}" == "cbai_transcriptome_v1.0.fasta" ]]; then

    reads_array=("${reads_dir}"/20200[15][13][138]*megan*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/20200[15][13][138]*megan*R1.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/20200[15][13][138]*megan*R2.fq)



  elif [[ "${transcriptome_name}" == "cbai_transcriptome_v1.5.fasta" ]]; then

    reads_array=("${reads_dir}"/20200[145][13][138]*megan*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/20200[145][13][138]*megan*R1.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/20200[145][13][138]*megan*R2.fq)

  elif [[ "${transcriptome_name}" == "cbai_transcriptome_v1.6.fasta" ]]; then

    reads_array=("${reads_dir}"/*megan*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/*megan*R1.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/*megan*R2.fq)

  elif [[ "${transcriptome_name}" == "cbai_transcriptome_v1.7.fasta" ]]; then

    reads_array=("${reads_dir}"/20200[145][13][189]*megan*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/20200[145][13][189]*megan*R1.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/20200[145][13][189]*megan*R2.fq)

  elif [[ "${transcriptome_name}" == "cbai_transcriptome_v2.0.fasta" ]] \
  || [[ "${transcriptome_name}" == "cbai_transcriptome_v2.1.fasta" ]]; then

    reads_array=("${reads_dir}"/*fastp-trim*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/*R1*fastp-trim*.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/*R2*fastp-trim*.fq)

  elif [[ "${transcriptome_name}" == "cbai_transcriptome_v3.0.fasta" ]] \
  || [[ "${transcriptome_name}" == "cbai_transcriptome_v3.1.fasta" ]]; then

    reads_array=("${reads_dir}"/*fastp-trim*20[12][09][01][24]1[48]*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/*R1*fastp-trim*20[12][09][01][24]1[48]*.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/*R2*fastp-trim*20[12][09][01][24]1[48]*.fq)


  fi

  # Create list of fastq files used in analysis
  ## Uses parameter substitution to strip leading path from filename
  printf "%s\n" "${reads_array[@]##*/}" >> "${transcriptome_name}".fastq.list.txt

  # Create comma-separated lists of FastQ reads
  R1_list=$(echo "${R1_array[@]}" | tr " " ",")
  R2_list=$(echo "${R2_array[@]}" | tr " " ",")


done


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
