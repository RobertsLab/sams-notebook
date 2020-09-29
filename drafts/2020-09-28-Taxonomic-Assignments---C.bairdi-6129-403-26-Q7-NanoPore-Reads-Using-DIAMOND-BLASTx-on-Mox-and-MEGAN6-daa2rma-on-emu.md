---
layout: post
title: Taxonomic Assignments - C.bairdi 6129-403-26-Q7 NanoPore Reads Using DIAMOND BLASTx on Mox and MEGAN6 daa2rma on emu
date: '2020-09-28 19:49'
tags:
  - Chionoecetes bairdi
  - Tanner crab
  - mox
  - BLASTx
  - DIAMOND
  - nanopore
  - emu
categories:
  - Miscellaneous
---


SBATCH script (GitHub):

- [20200928_cbai_diamond_blastx_nanopore_6129_403_26_Q7.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200928_cbai_diamond_blastx_nanopore_6129_403_26_Q7.sh)


```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_blastx_DIAMOND_nanopore_6129_403_26_Q7
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200928_cbai_diamond_blastx_nanopore_6129_403_26_Q7

# Script to run DIAMOND BLASTx on 6129_403_26 quality filtered (Q7) C.bairdi NanoPore reads
# from 20200928 using the --long-reads option
# for subsequent import into MEGAN6 to evaluate reads taxonomically.

###################################################################################
# These variables need to be set by user

# Input FastQ file
fastq=/gscratch/srlab/sam/data/C_bairdi/DNAseq/20200928_cbai_nanopore_6129_403_26_quality-7.fastq

# DIAMOND Output filename prefix
prefix=20200928_cbai_nanopore_6129_403_26_Q7

# Set number of CPUs to use
threads=28

# Program paths
diamond=/gscratch/srlab/programs/diamond-2.0.4/diamond

# DIAMOND NCBI nr database with taxonomy dumps
dmnd_db=/gscratch/srlab/blastdbs/ncbi-nr-20190925/nr.dmnd


###################################################################################
# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# SegFault fix?
export THREADS_DAEMON_MODEL=1


# Inititalize arrays
programs_array=()


# Programs array
programs_array=("${diamond}")


md5sum "${fastq}" > fastq_checksums.md5


# Run DIAMOND with blastx
# Output format 6 produces a standard BLAST tab-delimited file
# Run DIAMOND with blastx
# Output format 100 produces a DAA binary file for use with MEGAN
${diamond} blastx \
--long-reads \
--db ${dmnd_db} \
--query "${fastq}" \
--out "${prefix}".blastx.daa \
--outfmt 100 \
--top 5 \
--block-size 8.0 \
--index-chunks 1 \
--threads ${threads}

# Capture program options
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${programs_array[program]}: "
	echo ""
	${programs_array[program]} help
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

Pretty quick, a little over 31mins:

![DIAMOND BLASTx and MEGAN daa2rma conversion for 6129-403-26-Q7 runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200928_cbai_diamond_blastx_nanopore_6129_403_26_Q7_runtime.png?raw=true)

Output folder:

- []()
