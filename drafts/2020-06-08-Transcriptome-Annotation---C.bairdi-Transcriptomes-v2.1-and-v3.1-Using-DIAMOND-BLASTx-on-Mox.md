---
layout: post
title: Transcriptome Annotation - C.bairdi Transcriptomes v2.1 and v3.1 Using DIAMOND BLASTx on Mox
date: '2020-06-08 10:31'
tags:
  - Chionoecetes bairdi
  - Tanner crab
  - mox
  - BLASTx
  - DIAMOND
  - annotation
  - transcriptome
categories:
  - Miscellaneous
---
Decided to annotate the two _C.bairdi_ transcriptomes , `cbai_transcriptome_v2.1` and `cbai_transcriptome_v3.1`, [generated on 20200605](https://robertslab.github.io/sams-notebook/2020/06/05/Sequence-Extractions-C.bairdi-Transcriptomes-v2.0-and-v3.0-Excluding-Alveolata-with-MEGAN6-on-Swoose.html)

SBATCH script (GitHub):

- [20200608_cbai_diamond_blastx_v2.1_v3.1.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200608_cbai_diamond_blastx_v2.1_v3.1.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_diamond_blastx_v2.1_v3.1
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=0-08:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200608_cbai_diamond_blastx_v2.1_v3.1


## Script for running BLASTx (using DIAMOND) to annotate
## C.bairdi transcriptomes v2.1 and v3.1 against SwissProt database.
## Output will be in standard BLAST output format 6.

###################################################################################
# These variables need to be set by user

threads=28

# Programs array
declare -A programs_array
programs_array=(
[diamond]="/gscratch/srlab/programs/diamond-0.9.29/diamond"
)

# Transcriptomes arrays
transcriptomes_dir="/gscratch/srlab/sam/data/C_bairdi/transcriptomes"
transcriptomes=("${transcriptomes_dir}/cbai_transcriptome_v2.1.fasta" \
"${transcriptomes_dir}/cbai_transcriptome_v3.1.fasta")

# DIAMOND UniProt database
dmnd=/gscratch/srlab/blastdbs/uniprot_sprot_20200123/uniprot_sprot.dmnd

###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017


for fasta in "${!transcriptomes[@]}"
do
  # Generate checksums for reference
  md5sum "${transcriptomes[$fasta]}">> fasta.checksums.md5

  # Strip leading path and extensions
  no_path="${transcriptomes[$fasta]##*/}"
  no_ext="${no_path%.*}"

  # Run DIAMOND with blastx
  # Output format 6 produces a standard BLAST tab-delimited file
  ${programs_array[diamond]} blastx \
  --db ${dmnd} \
  --query "${transcriptomes[$fasta]}" \
  --out "${no_ext}".blastx.outfmt6 \
  --outfmt 6 \
  --evalue 1e-4 \
  --max-target-seqs 1 \
  --block-size 15.0 \
  --index-chunks 4
done


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

Super fast - 40 seconds to process both transcriptomes:

![cbai v2.1 and v3.1 diamond blastx runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200608_cbai_diamond_blastx_v2.1_v3.1_runtime.png?raw=true)

Output folder:

- [20200608_cbai_diamond_blastx_v2.1_v3.1](https://gannet.fish.washington.edu/Atumefaciens/20200608_cbai_diamond_blastx_v2.1_v3.1)

BLASTx output files (BLAST output format 6 text):

- [cbai_transcriptome_v2.1.blastx.outfmt6](https://gannet.fish.washington.edu/Atumefaciens/20200608_cbai_diamond_blastx_v2.1_v3.1/cbai_transcriptome_v2.1.blastx.outfmt6)

- [cbai_transcriptome_v3.1.blastx.outfmt6](https://gannet.fish.washington.edu/Atumefaciens/20200608_cbai_diamond_blastx_v2.1_v3.1/cbai_transcriptome_v3.1.blastx.outfmt6)
