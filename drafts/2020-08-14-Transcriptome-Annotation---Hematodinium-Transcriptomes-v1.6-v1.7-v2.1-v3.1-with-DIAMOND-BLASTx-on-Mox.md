---
layout: post
title: Transcriptome Annotation - Hematodinium Transcriptomes v1.6 v1.7 v2.1 v3.1 with DIAMOND BLASTx on Mox
date: '2020-08-14 22:30'
tags:
  - BLASTx
  - mox
  - DIAOMOND
  - Hematodinium
  - transcriptome annotation
categories:
  - Miscellaneous
---
Needed to annotate the _Hematodinium sp._ transcriptomes that I've assembled using DIAMOND BLASTx. This will also be used for additional downstream annotation (TransDecoder, Trinotate):

- [hemat_transcriptome_v1.6.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.6.fasta_trinity_out_dir/hemat_transcriptome_v1.6.fasta) (38MB; from [20200814](https://robertslab.github.io/sams-notebook/2020/08/14/Transcriptome-Assembly-Hematodinium-Transcriptomes-v1.6-and-v1.7-with-Trinity-on-Mox.html))

- [hemat_transcriptome_v1.7.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.7.fasta_trinity_out_dir/hemat_transcriptome_v1.7.fasta) (22MB; from [20200814](https://robertslab.github.io/sams-notebook/2020/08/14/Transcriptome-Assembly-Hematodinium-Transcriptomes-v1.6-and-v1.7-with-Trinity-on-Mox.html))

- [hemat_transcriptome_v2.1.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200605_cbai_v2.0_v3.0_megan_seq_extractions/hemat_transcriptome_v2.1.fasta) (65MB; from [20200605](https://robertslab.github.io/sams-notebook/2020/06/05/Sequence-Extractions-C.bairdi-Transcriptomes-v2.0-and-v3.0-Excluding-Alveolata-with-MEGAN6-on-Swoose.html))

- [hemat_transcriptome_v3.1.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200605_cbai_v2.0_v3.0_megan_seq_extractions/hemat_transcriptome_v3.1.fasta) (65MB; from [20200605](https://robertslab.github.io/sams-notebook/2020/06/05/Sequence-Extractions-C.bairdi-Transcriptomes-v2.0-and-v3.0-Excluding-Alveolata-with-MEGAN6-on-Swoose.html))

All of the above transcriptomes were assembled with different combinations of the crab RNAseq data we generated. Here's a link to an overview of the various assemblies:

- [hemat_transcriptome_comp](https://docs.google.com/spreadsheets/d/1A81cFdFw5Mlks5DWMmq0-8eVqyTXqmoCsHNWs95N_p4/edit?usp=sharing) (Google Sheet)

DIAMOND BLASTx was run on Mox.


SBATCH script (GitHub):

- [20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1


## Script for running BLASTx (using DIAMOND) to annotate
## Hematodinium transcriptomes v1.6, v1.7, v2.1 and v3.1 against SwissProt database.
## Output will be in standard BLAST output format 6.

###################################################################################
# These variables need to be set by user

# Programs array
declare -A programs_array
programs_array=(
[diamond]="/gscratch/srlab/programs/diamond-0.9.29/diamond"
)

# Establish variables for more readable code
transcriptomes_dir=/gscratch/srlab/sam/data/Hematodinium/transcriptomes

# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
transcriptomes_array=(
"${transcriptomes_dir}"/hemat_transcriptome_v1.6.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v1.7.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v2.1.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v3.1.fasta
)

# DIAMOND UniProt database
dmnd=/gscratch/srlab/blastdbs/uniprot_sprot_20200123/uniprot_sprot.dmnd

###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017


for fasta in "${!transcriptomes_array[@]}"
do

  # Remove path from transcriptome using parameter substitution
  transcriptome_name="${transcriptomes_array[$fasta]##*/}"

  # Generate checksums for reference
  md5sum "${transcriptomes_array[$fasta]}">> fasta.checksums.md5

  # Run DIAMOND with blastx
  # Output format 6 produces a standard BLAST tab-delimited file
  ${programs_array[diamond]} blastx \
  --db ${dmnd} \
  --query "${transcriptomes_array[$fasta]}" \
  --out "${transcriptome_name}".blastx.outfmt6 \
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

Just under 40 seconds (!!) to annotate the four transcriptomes:

![DIAMOND BLASTx cumulative runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1_runtimes.png?raw=true)

Output folder:

- [20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1/](https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1/)

##### `hemat_transcriptome_v1.6.fasta.blastx.outfmt6`

- [20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1/hemat_transcriptome_v1.6.fasta.blastx.outfmt6](https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1/hemat_transcriptome_v1.6.fasta.blastx.outfmt6) (text; 2.0MB)

##### `hemat_transcriptome_v1.7.fasta.blastx.outfmt6`

- [20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1/hemat_transcriptome_v1.7.fasta.blastx.outfmt6](https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1/hemat_transcriptome_v1.7.fasta.blastx.outfmt6) (text; 1.3MB)

##### `hemat_transcriptome_v2.1.fasta.blastx.outfmt6`

- [20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1/hemat_transcriptome_v2.1.fasta.blastx.outfmt6](https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1/hemat_transcriptome_v2.1.fasta.blastx.outfmt6) (text; 1.5MB)


##### `hemat_transcriptome_v3.1.fasta.blastx.outfmt6`

- [20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1/hemat_transcriptome_v3.1.fasta.blastx.outfmt6](https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1/hemat_transcriptome_v3.1.fasta.blastx.outfmt6) (text; 1.4MB)
