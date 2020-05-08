---
layout: post
title: Transcriptome Annotation - C.bairdi Transcriptome v2.0 Using DIAMOND BLASTx on Mox
date: '2020-05-08 07:50'
tags:
  - Tanner crab
  - mox
  - BLASTx
  - Chionoecetes bairdi
  - DIAMOND
categories:
  - Miscellaneous
---
As part of annotating the _C.bairdi_ [v2.0 transcriptome assembly from 20200502](https://robertslab.github.io/sams-notebook/2020/05/02/Transcriptome-Assembly-C.bairdi-All-RNAseq-Data-Without-Taxonomic-Filters-with-Trinity-on-Mox.html), I need to run DIAMOND BLASTx to use with Trinotate.

Ran DIAMOND BLASTx against the UniProt/SwissProt database (downloaded 20200123) on Mox.

SBATCH script (GitHub):

- [20200508_cbai_diamond_blastx_transcriptome-v2.0.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200508_cbai_diamond_blastx_transcriptome-v2.0.sh)

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
#SBATCH --time=10-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200508_cbai_diamond_blastx_transcriptome-v2.0

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

# DIAMOND UniProt database
dmnd=/gscratch/srlab/blastdbs/uniprot_sprot_20200123/uniprot_sprot.dmnd


# Trinity assembly (FastA)
fasta=/gscratch/srlab/sam/data/C_bairdi/transcriptomes/20200507.C_bairdi.Trinity.fasta

# Strip leading path and extensions
no_path=$(echo "${fasta##*/}")
no_ext=$(echo "${no_path%.*}")

# Run DIAMOND with blastx
# Output format 6 produces a standard BLAST tab-delimited file
${diamond} blastx \
--db ${dmnd} \
--query "${fasta}" \
--out "${no_ext}".blastx.outfmt6 \
--outfmt 6 \
--evalue 1e-4 \
--max-target-seqs 1 \
--block-size 15.0 \
--index-chunks 4
```

---

#### RESULTS

I'll never _not_ be amazed at how fast this runs! 51 seconds!

![diamond blastx runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200508_cbai_diamond_blastx_transcriptome-v2.0_runtime.png?raw=true)

Output folder:

- [20200508_cbai_diamond_blastx_transcriptome-v2.0/](https://gannet.fish.washington.edu/Atumefaciens/20200508_cbai_diamond_blastx_transcriptome-v2.0/)

BLASTx output - BLAST format 6 (tab):

- [20200508_cbai_diamond_blastx_transcriptome-v2.0/20200507.C_bairdi.Trinity.blastx.outfmt6](https://gannet.fish.washington.edu/Atumefaciens/20200508_cbai_diamond_blastx_transcriptome-v2.0/20200507.C_bairdi.Trinity.blastx.outfmt6)

Will proceed with Trinotate.
