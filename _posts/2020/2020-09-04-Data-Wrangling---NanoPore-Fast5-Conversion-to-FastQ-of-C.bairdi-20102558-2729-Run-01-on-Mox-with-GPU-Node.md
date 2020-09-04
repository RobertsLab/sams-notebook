---
layout: post
title: Data Wrangling - NanoPore Fast5 Conversion to FastQ of C.bairdi 20102558-2729 Run-01 on Mox with GPU Node
date: '2020-09-04 13:37'
tags:
  - guppy
  - mox
  - Tanner crab
  - Fast5
  - FastQ
  - NanoPore
  - ONT
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
Time to start working with [the NanoPore data that I generated back in _January_(???!!!)](https://robertslab.github.io/sams-notebook/2020/01/09/NanoPore-Sequencing-C.bairdi-gDNA-Sample-20102558-2729.html). In order to proceed, I first need to convert the raw Fast5 files to FastQ. To do so, I'll use the NanoPore program `guppy`.

Prior to running this, I did some quick test runs on Mox using different settings for `--num_callers` and `--cpu_threads_per_caller` to gauge how long the job might take. Using a small (~45MB) Fast5 file, conversion ranged from ~1 - 1.5hrs! Considering there are 26 files in this set, this might take a while. Poking around a bit to see how I could leverage multiple nodes in an high performance computing (HPC) environment like Mox, I came across the fact that using a GPU instead of a CPU could cut the runtime by a factor of 10!

I decided to see if we could access a GPU node on Mox and it turns out that we can! A quick test with the GPU node confirmed a _massive_ time reduction! The same Fast5 used in the CPU threads/callers test converted in <10 _seconds_!! Amazing! The only rub is that since we don't own a GPU node, any jobs we submit are:

- lowest priority in any queue

- can get interrupted at any time by jobs submitted by the node owner

I'll be submitting these very early in the morning and with runtimes this fast, I shouldn't encounter any issues. Exciting!

SBATCH script (GitHub):

- [20200110_cbai_guppy_nanopore_20102558-2729.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200110_cbai_guppy_nanopore_20102558-2729.sh)


```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_guppy_nanopore_20102558-2729
## Allocation Definition
#SBATCH --account=srlab-ckpt
#SBATCH --partition=ckpt
## Resources
## GPU
#SBATCH --gres=gpu:P100:1
#SBATCH --constraint=gpu_default
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
## basecalling (i.e. convert raw ONT Fast5 to FastQ) of NanaPore data generated
## on 20200109 from C.bairdi 20102558-2729 gDNA.

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
```

---

#### RESULTS

Took 11mins to convert 26 Fast5 files to FastQ with the Mox GPU node:

![Fast5 to FastQ conversion runtime for 26 Fast5 files using Mox GPU node](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200110_cbai_guppy_nanopore_20102558-2729_runtime.png?raw=true)

Output folder:

- [20200110_cbai_guppy_nanopore_20102558-2729/](https://gannet.fish.washington.edu/Atumefaciens/20200110_cbai_guppy_nanopore_20102558-2729/)

Sequencing Summary (17MB; TXT)

- [20200110_cbai_guppy_nanopore_20102558-2729/sequencing_summary.txt](https://gannet.fish.washington.edu/Atumefaciens/20200110_cbai_guppy_nanopore_20102558-2729/sequencing_summary.txt)

  - Useful with downstream analysis tools, like [NanoPlot](https://github.com/wdecoster/NanoPlot).

All the resulting FastQ files can be accessed in the output folder linked above with this pattern:

- `*.fastq`

Unbeknownst to me, I misinterpreted the behavior of the program. I thought the FastQs from all of the Fast5 would be concatenated into a single FastQ. However, that's not the case. Each Fast5 got converted to its own FastQ. So, I now have 26 FastQ files instead of just one. Not a big deal as I can concatenate these at a later date.

Now, I'll get these run through some QC software (FastQC, NanoPlot) to get an idea of how things look before processing them further.
