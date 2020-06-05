---
layout: post
title: Transcriptome Annotation - C.bairdi Transcriptomes v2.0 and v3.0 with DIAMOND BLASTx on Mox
date: '2020-06-04 09:02'
tags:
  - Tanner crab
  - transcritpome
  - annotation
  - DIAMOND
  - BLASTx
  - mox
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
Continuing to try to identify the best [_C.bairdi_ transcriptome](https://github.com/RobertsLab/resources/wiki/Genomic-Resources#transcriptomes), we decided to extract all non-dinoflagellate sequences from `cbai_transcriptome_v2.0` (RNAseq shorthand: 2018, 2019, 2020-GW, 2020-UW) and `cbai_transcriptome_v3.0` (RNAseq shorthand: 2018, 2019, 2020-UW). Both of these transcriptomes were assembled _without_ any taxonomic filter applied.

We'll do this by:

1. Running BLASTx on the transcriptomes (this notebook).

2. Converting BLASTx output to MEGAN6 RMA6 format (this notebook).

3. Use MEGAN6 to extract all non-dinoflagellate sequences (different notebook).

Initial DIAMOND BLASTx was run on Mox.

Due to usage of X11, the subsequent conversion of the DIAMOND BLASTx output to RMA6 can't be performed on Mox, so was performed on my computer, swoose. Scripts for both jobs are below.


SBATCH script (GitHub):

- [20200604_cbai_v2.0_v3.0_diamond_blastx.sh](https://github.com/RobertsLab/sams-notebook/blob/9f61124210ef4389d40a98143bd4eb2190574ff8/sbatch_scripts/20200604_cbai_v2.0_v3.0_diamond_blastx.sh) (commit 9f61124)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_blastx_DIAMOND
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=1-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200604_cbai_v2.0_v3.0_diamond_blastx

## Perform DIAMOND BLASTx on Chionoecetes bairdi (Tanner crab) transcriptome assemblies:
## v2.0 and v3.0 for subsequent taxonomic filtering with MEGAN6.

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# SegFault fix?
export THREADS_DAEMON_MODEL=1

# Document programs in PATH (primarily for program version ID)

{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log



# Program paths
diamond=/gscratch/srlab/programs/diamond-0.9.29/diamond

# DIAMOND NCBI nr database
dmnd=/gscratch/srlab/blastdbs/ncbi-nr-20190925/nr.dmnd

# Capture program options
{
echo "Program options for DIAMOND: "
echo ""
"${diamond}" help
echo ""
echo ""
echo "----------------------------------------------"
echo ""
echo ""
} &>> program_options.log || true

# Transcriptomes directory
transcriptome_dir=/gscratch/srlab/sam/data/C_bairdi/transcriptomes/


# Loop through transcriptome FastA files, log filenames to fasta_list.txt.
# Run DIAMOND on each FastA
for fasta in ${transcriptome_dir}cbai_transcriptome_v[23]*.fasta
do
	# Record md5 checksums
	md5sum "${fasta}" >> transcriptomes_checkums.md5

	# Strip leading path and extensions
	no_path=$(echo "${fasta##*/}")

	# Run DIAMOND with blastx
	# Output format 100 produces a DAA binary file for use with MEGAN
	${diamond} blastx \
	--db ${dmnd} \
	--query "${fasta}" \
	--out "${no_path}".blastx.daa \
	--outfmt 100 \
	--top 5 \
	--block-size 15.0 \
	--index-chunks 4
done
```


---

#### RESULTS

Took a little over 2hrs:

![cbai transcritpomes 2.0 and 3.0 diamond blastx runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200604_cbai_v2.0_v3.0_diamond_blastx_runtime.png?raw=true)

Output folder:

- [20200604_cbai_v2.0_v3.0_diamond_blastx](https://gannet.fish.washington.edu/Atumefaciens/20200604_cbai_v2.0_v3.0_diamond_blastx/)
