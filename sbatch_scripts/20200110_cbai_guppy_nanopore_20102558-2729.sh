#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_guppy_nanopore_20102558-2729
## Allocation Definition
#SBATCH --account=srlab-ckpt
#SBATCH --partition=ckpt
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=0-01:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200110_cbai_guppy_nanopore_20102558-2729

## Script for running ONT guppy to perform
## basecalling (i.e. convert raw ONT Fast5 to FastQ)

## This script utilizes a GPU node. These nodes are only available as part of the checkpoint
## partition/account. Since we don't own a GPU node, our GPU jobs are lowest priority and
## can be interrupted at any time if the node owner submits a new job.

###################################################################################
# These variables need to be set by user

wd=$(pwd)

# Programs array
declare -A programs_array
programs_array=(
[guppy_basecaller]="/gscratch/srlab/programs/ont-guppy_4.0.15_linux64/bin/guppy_basecaller"
)

# Establish variables for more readable code

# Input files directory
fast5_dir=/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL58500_94244ffd_20102558-2729

# Output directory
out_dir=${wd}

# CPU threads
threads=28

# Flowcell type
flowcell="FLO-MIN106"

# Sequencing kit used
kit="SQK-RAD004"

# GPU devices setting
GPU_devices=auto

# Set number of FastQ sequences written per file (0 means all in one file)
records_per_fastq=0

###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Load CUDA GPU module
module load cuda/10.1.105_418.39


${programs_array[guppy_basecaller]} \
--input_path ${fast5_dir} \
--save_path ${out_dir} \
--flowcell ${flowcell} \
--kit ${kit} \
--device ${GPU_devices} \
--records_per_fastq ${records_per_fastq} \
--num_callers ${threads}

###################################################################################

# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : n
} >> system_path.log


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
