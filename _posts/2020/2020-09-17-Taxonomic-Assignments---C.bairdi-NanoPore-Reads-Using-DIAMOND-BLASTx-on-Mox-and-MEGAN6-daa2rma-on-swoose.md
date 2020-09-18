---
layout: post
title: Taxonomic Assignments - C.bairdi NanoPore Reads Using DIAMOND BLASTx on Mox and MEGAN6 daa2rma on swoose
date: '2020-09-17 08:16'
tags:
  - Tanner crab
  - DIAMOND
  - BLASTx
  - mox
  - Chionoecetes bairdi
  - MEGAN6
  - NanoPore
categories:
  - Miscellaneous
---
Earlier today I [quality filtered (>=Q7) our _C.baird_ NanoPore reads](https://robertslab.github.io/sams-notebook/2020/09/17/Data-Wrangling-C.bairdi-NanoPore-Quality-Filtering-Using-NanoFilt-on-Mox.html). One of the things I'd like to do now is to attempt to filter reads taxonomically, since the NanoPore data came from both an uninfected crab and _Hematodinium_-infected crab.

I ran DIAMOND BLASTx (on Mox), followed by MEGAN6 `daa2rma` (on swoose - MEGAN6 requires some weird Java X11 thingy that won't work on Mox) to convert the DIAMOND output to the proper MEGAN6 format for visualizing taxonomic assignments.

SBATCH script (GitHub) for DIAMOND BLASTx on Mox:

- [20200917_cbai_diamond_blastx_nanopore_all_Q7.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200917_cbai_diamond_blastx_nanopore_all_Q7.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_blastx_DIAMOND_nanopore_all
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200917_cbai_diamond_blastx_nanopore_all_Q7

# Script to run DIAMOND BLASTx on all quality filtered (Q7) C.bairdi NanoPore reads
# from 20200917 using the --long-reads option
# for subsequent import into MEGAN6 to try to separate reads taxonomically.

###################################################################################
# These variables need to be set by user

# Input FastQ file
fastq=/gscratch/srlab/sam/data/C_bairdi/DNAseq/20200917_cbai_nanopore_all_quality-7.fastq

# DIAMOND Output filename prefix
prefix=20200917_cbai_diamond_blastx_nanopore_all_Q7

# Set number of CPUs to use
threads=28

# Program paths
diamond=/gscratch/srlab/programs/diamond-0.9.29/diamond

# DIAMOND UniProt database
dmnd_db=/gscratch/srlab/blastdbs/uniprot_sprot_20200123/uniprot_sprot.dmnd


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
--block-size 15.0 \
--index-chunks 4 \
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

Bash script (GitHub) for `daa2rma` on Emu:

- [20200917_cbai_nanopore_diamond_blastx_daa2rma.sh](https://github.com/RobertsLab/sams-notebook/blob/master/bash_scripts/20200917_cbai_nanopore_diamond_blastx_daa2rma.sh)

```shell
#!/bin/bash

# Script to run MEGAN6 daa2rma on DIAMOND DAA files from
# 20200917_cbai_diamond_blastx_nanopore_all_Q7.
# Utilizes the --longReads option

# Requires MEGAN mapping file from:
# http://ab.inf.uni-tuebingen.de/data/software/megan6/download/


# MEGAN mapping file
megan_map=/home/sam/data/databases/MEGAN6/megan-map-Jul2020-2.db

# Programs array
declare -A programs_array
programs_array=(
[daa2rma]="/home/shared/megan_6.19.9/tools/daa2rma"
)

threads=16

#########################################################################

# Exit script if any command fails
set -e


## Run daa2rma

# Capture start "time"
# Uses builtin bash variable called ${SECONDS}
start=${SECONDS}

for daa in *.daa
do
  start_loop=${SECONDS}
  sample_name=$(basename --suffix ".blastx.daa" "${daa}")

  echo "Now processing ${sample_name}.daa2rma.rma6"
  echo ""

  # Run daa2rma with long reads option
  ${programs_array[daa2rma]} \
  --in "${daa}" \
  --longReads \
  --mapDB ${megan_map} \
  --out "${sample_name}".daa2rma.rma6 \
  --threads ${threads} \
  2>&1 | tee --append daa2rma_log.txt

  end_loop=${SECONDS}
  loop_runtime=$((end_loop-start_loop))


  echo "Finished processing ${sample_name}.daa2rma.rma6 in ${loop_runtime} seconds."
  echo ""

done

# Caputure end "time"
end=${SECONDS}

runtime=$((end-start))

# Print daa2rma runtime, in seconds

{
  echo ""
  echo "---------------------"
  echo ""
  echo "Total runtime was: ${runtime} seconds"
} >> daa2rma_log.txt

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

# Document programs in PATH
{
date
echo ""
echo "System PATH:"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log
```

---

#### RESULTS

DIAMOND runtime was quick (as usual), 53s:

![DIAMOND BLASTx runtime of C.baird Q7 NanoPore reads on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200917_cbai_diamond_blastx_nanopore_all_Q7_runtime.png?raw=true)

DIAMOND BLASTx Output folder:

- [20200917_cbai_diamond_blastx_nanopore_all_Q7/](https://gannet.fish.washington.edu/Atumefaciens/20200917_cbai_diamond_blastx_nanopore_all_Q7/)

  - DIAMOND BLASTx DAA file:

    - [20200917_cbai_diamond_blastx_nanopore_all_Q7/20200917_cbai_diamond_blastx_nanopore_all_Q7.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200917_cbai_diamond_blastx_nanopore_all_Q7/20200917_cbai_diamond_blastx_nanopore_all_Q7.blastx.daa) (47MB)

daa2rma Output folder:

- [20200917_cbai_nanopore_diamond_blastx_daa2rma/](https://gannet.fish.washington.edu/Atumefaciens/20200917_cbai_nanopore_diamond_blastx_daa2rma/)

  - RMA6 file:

    - [20200917_cbai_nanopore_diamond_blastx_daa2rma/20200917_cbai_diamond_blastx_nanopore_all_Q7.daa2rma.rma6](https://gannet.fish.washington.edu/Atumefaciens/20200917_cbai_nanopore_diamond_blastx_daa2rma/20200917_cbai_diamond_blastx_nanopore_all_Q7.daa2rma.rma6)

I opened the RMA6 file in MEGAN6 to see the taxonomic breakdown and this is what I got:

![screencap of MEGAN6 C.bairdi NanoPore Q7 - no taxonomic assignments](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200917_cbai_nanopore_Q7_MEGAN6_no-assignments.png?raw=true)

No taxonomic assignments!!

Well, that was anti-climatic (and unhelpful)... Maybe after I complete the assembly, I can try again using the FastA...
