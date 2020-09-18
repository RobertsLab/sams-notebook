---
layout: post
title: Genome Assembly - C.bairdi - cbai_v1.0 - Using All NanoPore Data With Flye on Mox
date: '2020-09-17 11:08'
tags:
  - genome assembly
  - Tanner crab
  - Hematodinium
  - Chionoecetes bairdi
  - mox
  - flye
categories:
  - Genome Assembly
---
After [quality filtering the _C.bairdi_ NanoPore data earlier today](https://robertslab.github.io/sams-notebook/2020/09/17/Data-Wrangling-C.bairdi-NanoPore-Quality-Filtering-Using-NanoFilt-on-Mox.html), I performed a _de novo_ assembly using [Flye](https://github.com/fenderglass/Flye) on Mox.

SBATCH script (GitHub):

- [20200917_cbai_flye_nanopore_genome_assembly.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200917_cbai_flye_nanopore_genome_assembly.sh)

```shell
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

# Script to run Flye long read assembler on all quality filtered (Q7) C.bairdi NanoPore reads
# from 20200917

###################################################################################
# These variables need to be set by user

# Load Anaconda
# Uknown why this is needed, but Anaconda will not run if this line is not included.
. "/gscratch/srlab/programs/anaconda3/etc/profile.d/conda.sh"


# Activate the flye Anaconda environment
conda activate flye-2.8.1_env

# Set number of CPUs to use
threads=28

# Paths to programs
flye=flye

# Input FastQ
fastq=/gscratch/srlab/sam/data/C_bairdi/DNAseq/20200917_cbai_nanopore_all_quality-7.fastq

###################################################################################


# Exit script if any command fails
set -e


# Capture this directory
wd=$(pwd)

# Inititalize arrays
programs_array=()


# Programs array
programs_array=("${flye}")

# Run flye
${flye} \
--nano-raw ${fastq} \
--out-dir ${wd} \
--threads ${threads}

# Generate checksum file
md5sum "${fastq}" > fastq_checksums.md5

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
```


---

#### RESULTS

Runtime was very fast; just over 1hr!

![Flye runtime for C.bairdi Q7 NanoPore assembly](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200917_cbai_flye_nanopore_genome_assembly_runtime.png?raw=true)

Output folder:

- []()
