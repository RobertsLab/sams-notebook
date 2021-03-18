---
layout: post
title: Transcriptome Annotation - DIAMOND BLASTx on C.bairdi Transcriptome v4.0 on Mox
date: '2021-03-18 10:10'
tags:
  - DIAMOND
  - BLASTx
  - mox
  - Tanner crab
  - transcriptome
  - annotation
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
Continued annotation of `cbai_transcriptome_v4.0.fasta` [Trinity _de novo_ assembly from 20210317(https://robertslab.github.io/sams-notebook/2021/03/17/Transcriptome-Assembly-C.bairdi-Transcriptome-v4.0-Using-Trinity-on-Mox.html)] using [`DIAMOND`](https://github.com/bbuchfink/diamond) BLASTx on Mox. This will be used as a component of Trinotate annotation downstream.

SBATCH script (GitHub):

- [20210318_cbai_diamond_blastx_transcriptome-v4.0.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210318_cbai_diamond_blastx_transcriptome-v4.0.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210318_cbai_diamond_blastx_transcriptome-v4.0
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210318_cbai_diamond_blastx_transcriptome-v4.0

### BLASTx of Trinity de novo assembly of all C.bairdi RNAseq with BLASTx matches to C.opilio genome.
### cbai_transcriptome_v4.0.fasta
### Includes RNAseq short-hand of: 2020-GW, 2020-UW, 2019, 2018.


###################################################################################
# These variables need to be set by user

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# SegFault fix?
export THREADS_DAEMON_MODEL=1


# Programs array
declare -A programs_array
programs_array=(
[diamond]="/gscratch/srlab/programs/diamond-0.9.29/diamond"
)

# DIAMOND UniProt database
dmnd=/gscratch/srlab/blastdbs/uniprot_sprot_20200123/uniprot_sprot.dmnd


# Trinity assembly (FastA)
fasta=/gscratch/srlab/sam/data/C_bairdi/transcriptomes/cbai_transcriptome_v4.0.fasta

###################################################################################

# Strip leading path and extensions
no_path=$(echo "${fasta##*/}")
no_ext=$(echo "${no_path%.*}")

# Run DIAMOND with blastx
# Output format 6 produces a standard BLAST tab-delimited file
${programs_array[diamond]} blastx \
--db ${dmnd} \
--query "${fasta}" \
--out "${no_ext}".blastx.outfmt6 \
--outfmt 6 \
--evalue 1e-4 \
--max-target-seqs 1 \
--block-size 15.0 \
--index-chunks 4

# Generate checksums for future reference
echo ""
echo "Generating checksum for ${fasta}."
md5sum "${fasta}">> fastq.checksums.md5
echo "Completed checksum for ${fasta}."
echo ""

###################################################################################

# Capture program options
echo "Logging program options..."
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${program}: "
	echo ""
  # Handle samtools help menus
  if [[ "${program}" == "samtools_index" ]] \
  || [[ "${program}" == "samtools_sort" ]] \
  || [[ "${program}" == "samtools_view" ]]
  then
    ${programs_array[$program]}

  # Handle DIAMOND BLAST menu
  elif [[ "${program}" == "diamond" ]]; then
    ${programs_array[$program]} help

  # Handle NCBI BLASTx menu
  elif [[ "${program}" == "blastx" ]]; then
    ${programs_array[$program]} -help
  fi
	${programs_array[$program]} -h
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true

  # If MultiQC is in programs_array, copy the config file to this directory.
  if [[ "${program}" == "multiqc" ]]; then
  	cp --preserve ~/.multiqc_config.yaml multiqc_config.yaml
  fi
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

echo "Finished logging system PATH"
```

---

#### RESULTS

Runtime was the usual [`DIAMOND`](https://github.com/bbuchfink/diamond) BLASTx quickness; 11 seconds!

![DIAMOND BLASTx of C.bairdi transcriptome v4.0 vs. SwissProt database](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210318_cbai_diamond_blastx_transcriptome-v4.0_runtime.png?raw=true)

Next up, run everything through Trinotate.

Output folder:

- [20210318_cbai_diamond_blastx_transcriptome-v4.0/](https://gannet.fish.washington.edu/Atumefaciens/20210318_cbai_diamond_blastx_transcriptome-v4.0/)

  - FastA MD5 checksum (TXT):

    - [20210318_cbai_diamond_blastx_transcriptome-v4.0/fastq.checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20210318_cbai_diamond_blastx_transcriptome-v4.0/fastq.checksums.md5) (NOTE: filename typo in code)

  - BLASTX output format 6 (TXT):

    - [cbai_transcriptome_v4.0.blastx.outfmt6](https://gannet.fish.washington.edu/Atumefaciens/20210318_cbai_diamond_blastx_transcriptome-v4.0/cbai_transcriptome_v4.0.blastx.outfmt6)
