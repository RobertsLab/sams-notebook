#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_nanoplot_fastqc_multiqc_nanopore-data
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200909_cbai_nanoplot_fastqc_multiqc_nanopore-data




###################################################################################
# These variables need to be set by user

# Load Miniconda Mox module for Anaconda module availability
module load contrib/Miniconda3/3.0

# Activate the NanoPlot Anaconda environment
conda activate /gscratch/srlab/programs/miniconda3/envs/nanoplot/

# Set number of CPUs to use
threads=28

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5

# Paths to programs
nanoplot=/gscratch/srlab/programs/miniconda3/envs/nanoplot/bin/NanoPlot
fastqc=/gscratch/srlab/programs/fastqc_v0.11.8/fastqc
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc


###################################################################################


# Exit script if any command fails
set -e



# Capture date
timestamp=$(date +%Y%m%d)

# Capture this directory
wd=$(pwd)

# Inititalize array
programs_array=()


# Programs array
programs_array=("${nanoplot}" "${multiqc}" "${fastqc}")

raw_reads_dir_array=(
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL58500_04bb4d86_20102558-2729" \
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL58500_94244ffd_20102558-2729" \
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL86873_d8db260e_cbai_6129_403_26"
)

for directory in "${!raw_reads_dir_array[@]}"
do

  ## Inititalize arrays
  fastq_array=()

  # Capture NanoPore directory name
  dir_name=${raw_reads_dir_array[directory]##*/}

  # Make new directory and change to that directory
  mkdir ${dir_name} $$ cd $_


  # Run NanoPlot
  ${programs_array[nanoplot]} \


  # Create array of fastq files
  for fastq in ${raw_reads_dir_array[directory]}/*.fastq
  do
    fastq_array+=("${fastq}")

    # Create list of fastq files used in analysis
    echo "${fastq}" >> fastq.list.txt

    # Create checksums
    md5sum "${fastq}" >> checksums.md5

    # Run FastQC
    ## Pass array contents to new variable in a space-delimited list
    fastqc_list=$(echo "${fastq_array[*]}")

    ${fastqc} --threads ${threads} \
    ${fastqc_list}


    # Run MultiQC
    ${multiqc} .

  done

  # Change back to working directory
  cd ${wd}

done


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
