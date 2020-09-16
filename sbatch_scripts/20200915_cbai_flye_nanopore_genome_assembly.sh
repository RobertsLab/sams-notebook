#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_flye_nanopore_genome_assembly
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=25-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200915_cbai_flye_nanopore_genome_assembly




###################################################################################
# These variables need to be set by user

# Load Anaconda
# Uknown why this is needed, but Anaconda will not run if this line is not included.
. "/gscratch/srlab/programs/anaconda3/etc/profile.d/conda.sh"


# Activate the flye Anaconda environment
conda activate flye-2.8.1_env

# Set number of CPUs to use
threads=28

# Paths to reads
raw_reads_dir_array=(
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL58500_04bb4d86_20102558-2729" \
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL58500_94244ffd_20102558-2729" \
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL86873_d8db260e_cbai_6129_403_26"
)

# Paths to programs
flye=flye


###################################################################################


# Exit script if any command fails
set -e


# Capture this directory
wd=$(pwd)

# Inititalize arrays
programs_array=()
fastq_array=()


# Programs array
programs_array=("${flye}")


# Loop through NanoPore data directories
# to create array of FastQ files from each flowcell
for fastq in "${raw_reads_dir_array[@]}/"*.fastq
do
  # Populate array with FastQ files
  fastq_array+=("${fastq}")

  # Create checksums file
  md5sum "${fastq}" >> fastq_checksums.md5
done

# Create space-delimited list of FastQ files
fastq_list="${fastq_array[*]}"

# Run flye
${flye} \
--nano-raw ${fastq_list} \
--out-dir ${wd} \
--threads ${threads}



# Capture program options
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${programs_array[program]}: "
	echo ""
	${programs_array[program]} -h
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true
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
