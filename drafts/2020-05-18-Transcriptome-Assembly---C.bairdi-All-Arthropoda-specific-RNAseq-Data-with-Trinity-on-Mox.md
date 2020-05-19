---
layout: post
title: Transcriptome Assembly - C.bairdi All Arthropoda-specific RNAseq Data with Trinity on Mox
date: '2020-05-18 11:33'
tags:
  - Chionoecetes bairdi
  - Tanner crab
  - trinity
  - mox
  - assembly
  - transcriptome
  - MEGAN6
categories:
  - Miscellaneous
---
As part of annotating [cbai_transcriptome_v3.0.fasta from 20200518](https://robertslab.github.io/sams-notebook/2020/05/18/Transcriptome-Assembly-C.bairdi-All-Pooled-RNAseq-Data-Without-Taxonomic-Filters-with-Trinity-on-Mox.html), I need to run DIAMOND BLASTx to use with Trinotate.

Ran DIAMOND BLASTx against the UniProt/SwissProt database (downloaded 20200123) on Mox.

SBATCH script (GitHub):

- [20200519_cbai_diamond_blastx_transcriptome_v3.0.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200519_cbai_diamond_blastx_transcriptome_v3.0.sh)

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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200519_cbai_diamond_blastx_transcriptome_v3.0

### BLASTx of Trinity de novo assembly of all pooled C.bairdi RNAseq data:
### cbai_transcriptome_v3.0.fasta (orginal name, used below, is 20200518.C_bairdi.Trinity.fasta)
### Includes "descriptor_1" short-hand of: 2020-UW, 2019, 2018.

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
fasta=/gscratch/srlab/sam/data/C_bairdi/transcriptomes/20200518.C_bairdi.Trinity.fasta

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

Output folder:

- []()
