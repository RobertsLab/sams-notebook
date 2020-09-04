---
layout: post
title: Data Wrangling - NanoPore Fast5 Conversion to FastQ of C.bairdi 6129_403_26 on Mox with GPU Node
date: '2020-09-04 13:48'
tags:
  - guppy
  - mox
  - Tanner crab
  - Fast5
  - FastQ
  - NanoPore
categories:
  - Miscellaneous
---
Time to start working with [the NanoPore data that I generated back in March (???!!!)](https://robertslab.github.io/sams-notebook/2020/03/11/NanoPore-Sequencing-C.bairdi-gDNA-6129_403_26.html). In order to proceed, I first need to convert the raw Fast5 files to FastQ. To do so, I'll use the NanoPore program `guppy`.

As noted in [a previous conversion](https://robertslab.github.io/sams-notebook/2020/09/04/Data-Wrangling-NanoPore-Fast5-Conversion-to-FastQ-of-C.bairdi-20102558-2729-Run-01-on-Mox-with-GPU-Node.html), I'll b processing this with a GPU node on Mox. Using a Mox GPU node decreases processing time by a ridiculous amount, compared to using CPUs. The only rub is that since we don't own a GPU node, any jobs we submit are:

- lowest priority in any queue

- can get interrupted at any time by jobs submitted by the node owner

I'll be submitting these very early in the morning and with runtimes this fast, I shouldn't encounter any issues. Exciting!

SBATCH script (GitHub):

- [20200314_cbai_guppy_nanopore_6129_403_26.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200314_cbai_guppy_nanopore_6129_403_26.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_guppy_nanopore_6129_403_26
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
#SBATCH --time=0-02:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200314_cbai_guppy_nanopore_6129_403_26

## Script for running ONT guppy to perform
## basecalling (i.e. convert raw ONT Fast5 to FastQ) of NanaPore data generated
## on 20200311 from C.bairdi 6129_403_26 gDNA.

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
fast5_dir=/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL86873_d8db260e_cbai_6129_403_26

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

Took just a bit over an hour to process 127 files:

![Fast5 to FastQ conversion runtime using Mox GPU node](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200314_cbai_guppy_nanopore_6129_403_26_runtime.png?raw=true)

Output folder:

- [20200314_cbai_guppy_nanopore_6129_403_26/](https://gannet.fish.washington.edu/Atumefaciens/20200314_cbai_guppy_nanopore_6129_403_26/)

Sequencing Summary (113MB; TXT)

- [20200314_cbai_guppy_nanopore_6129_403_26/sequencing_summary.txt](https://gannet.fish.washington.edu/Atumefaciens/20200314_cbai_guppy_nanopore_6129_403_26/sequencing_summary.txt)

  - Useful with downstream analysis tools, like [NanoPlot](https://github.com/wdecoster/NanoPlot).

All the resulting FastQ files can be accessed in the output folder linked above with this pattern:

- `*.fastq`

Unbeknownst to me, I misinterpreted the behavior of the program. I thought the FastQs from all of the Fast5 would be concatenated into a single FastQ. However, that's not the case. Each Fast5 got converted to its own FastQ. So, I now have 126 FastQ files instead of just one. Not a big deal as I can concatenate these at a later date.

Now, I'll get these run through some QC software (FastQC, NanoPlot) to get an idea of how things look before processing them further.
