#!/bin/bash
## Job Name
#SBATCH --job-name=20201208_cgig_STAR_RNAseq-to-NCBI-GCA_000297895.1_oyster_v9
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201208_cgig_STAR_RNAseq-to-NCBI-GCA_000297895.1_oyster_v9


### C.gigas RNAseq alignment to NCBI genome file GCA_000297895.1_oyster_v9.
### Mackenzie Gavery asked for help to evaluate RNAseq read mappings to mt genome.


###################################################################################
# These variables need to be set by user

# Working directory
wd=$(pwd)

# Set number of CPUs to use
threads=28

# Input/output files
fastq_checksums=fastq_checksums.md5
fastq_list=fastq_list.txt
rnaseq_reads_dir=/gscratch/srlab/sam/data/C_gigas/RNAseq
gtf=/gscratch/srlab/sam/data/C_gigas/transcriptomes/GCA_000297895.1_oyster_v9_genomic.gtf
genome_dir=${wd}/genome_dir
genome_fasta=GCA_000297895.1_oyster_v9_genomic.fna

# Paths to programs
star=/gscratch/srlab/programs/STAR-2.7.6a/bin/Linux_x86_64_static/STAR
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc


# Programs associative array
declare -A programs_array
programs_array=(
[star]="${star}" \
[multiqc]="${multiqc}"
)

###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Load GCC OMP compiler. Might/not be needed for STAR
module load gcc_8.2.1-ompi_4.0.2

# Sync raw FastQ files to working directory
rsync --archive --verbose \
"${raw_reads_dir}"zr3644*.fq.gz .

# Populate array with FastQ files
fastq_array=(*.fq.gz)

# Pass array contents to new variable
fastqc_list=$(echo "${fastq_array[*]}")



# Create list of fastq files used in analysis
echo "${fastqc_list}" | tr " " "\n" >> ${fastq_list}

# Generate checksums for reference
while read -r line
do

	# Generate MD5 checksums for each input FastQ file
	echo "Generating MD5 checksum for ${line}."
	md5sum "${line}" >> "${checksums}"
	echo "Completed: MD5 checksum for ${line}."
	echo ""

	# Remove fastq files from working directory
	echo "Removing ${line} from directory"
	rm "${line}"
	echo "Removed ${line} from directory"
	echo ""
done < ${fastq_list}

# Run MultiQC
${programs_array[multiqc]} .


# Capture program options
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


# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log
