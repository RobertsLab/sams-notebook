---
layout: post
title: Transcriptome Annotation - C.bairdi Using DIAMOND BLASTx on Mox and MEGAN6 Meganizer
date: '2020-01-03 10:05'
tags:
  - tanner crab
  - mox
  - MEGAN
  - DIAMOND
  - BLASTx
  - meganizer
  - Chionoecetes bairdi
categories:
  - Tanner Crab RNAseq
---
Although I previously [annotated](https://robertslab.github.io/sams-notebook/2019/12/25/Transcriptome-Annotation-C.bairdi-Trinity-Assembly-Trinotate-on-Mox.html) our [_C.bairdi_ transcriptome from 20191218](https://robertslab.github.io/sams-notebook/2019/12/18/Transcriptome-Assembly-C.bairdi-Trimmed-RNAseq-Using-Trinity-on-Mox.html), I realized that the assembly and annotations were combine infected/uninfected samples, possibly making separating crab/_Hematodinium_ sequences a bit more difficult.

I also realized that the MEGAN6 software that I'd previously used for metagenomic taxonomic classification can actually extract sequencing reads. So, I decided to run all of our Tanner crab RNAseq reads through the MEGAN6 process. At the end, I'll separate out reads, based on taxonomy, and then generate "clean" _de novo_ assemblies of Tanner crab and _Hematodinium_!

To start this process, the trimmed reads need to be annotated using DIAMOND BLASTx. Then, the DIAMOND output files need to be "meganized" for importing to MEGAN6.

DIAMOND BLASTx took place on Mox, while "meganization" took place on my lab computer (`swoose`); this is due to the way that MEGAN6 uses Java - it doesn't run properly on Mox.

For reference, these include RNAseq data using a newly established "shorthand": 2018, 2019.

SBATCH script (GitHub):

- [20200103_cbai_diamond_blastx.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200103_cbai_diamond_blastx.sh)

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
#SBATCH --time=20-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200103_cbai_diamond_blastx

## Perform DIAMOND BLASTx on trimmed Chionoecetes bairdi (Tanner crab) FastQ files.

## Trimmed FastQ files originated here:
## https://gannet.fish.washington.edu/Atumefaciens/20191218_cbai_fastp_RNAseq_trimming/

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


# FastQ files directory
fastq_dir=/gscratch/srlab/sam/data/C_bairdi/RNAseq/


# Loop through FastQ files, log filenames to fastq_list.txt.
# Run DIAMOND on each FastQ
for fastq in ${fastq_dir}*fastp-trim*.fq.gz
do
	# Log input FastQs
	echo "${fastq}" >> fastq_list.txt

	# Strip leading path and extensions
	no_path=$(echo "${fastq##*/}")
	no_ext=$(echo "${no_path%%.*}")

	# Run DIAMOND with blastx
	# Output format 100 produces a DAA binary file for use with MEGAN
	${diamond} blastx \
	--db ${dmnd} \
	--query "${fastq}" \
	--out "${no_ext}".blastx.daa \
	--outfmt 100 \
	--top 5 \
	--block-size 15.0 \
	--index-chunks 4
done
```


MEGANIZER script (GitHub):

- [20200107_cbai_diamond_blastx_meganizer.sh](https://github.com/RobertsLab/sams-notebook/blob/master/bash_scripts/20200107_cbai_diamond_blastx_meganizer.sh)

```shell
#!/bin/bash

# Script to run MEGAN6 meganizer on DIAMOND DAA files from
# 20200103_cbai_diamond_blastx Mox job.

# Requires MEGAN mapping files from:
# http://ab.inf.uni-tuebingen.de/data/software/megan6/download/

# Program path
meganizer=/home/sam/programs/megan/tools/daa-meganizer

# MEGAN mapping files
prot_acc2tax=/home/sam/data/databases/MEGAN/prot_acc2tax-Jul2019X1.abin
acc2interpro=/home/sam/data/databases/MEGAN/acc2interpro-Jul2019X.abin
acc2eggnog=/home/sam/data/databases/MEGAN/acc2eggnog-Jul2019X.abin

# Variables
threads=20

## Run MEGANIZER

# Capture start "time"
start=${SECONDS}
for daa in *.daa
do
  ${meganizer} \
  --in "${daa}" \
	--threads "${threads}" \
	--acc2taxa ${prot_acc2tax} \
	--acc2interpro2go ${acc2interpro} \
	--acc2eggnog ${acc2eggnog}
done

# Caputure end "time"
end=${SECONDS}

runtime=$((end-start))

# Print MEGANIZER runtime, in seconds
echo "Runtime was: ${runtime} seconds"
```

---

#### RESULTS

Runtime was just a bit over two days (but, it sat in the queue for a full day before being able to run):

![DIAMOND BLASTx runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200103_cbai_diamond_blastx_runtime.png?raw=true)

Output folder:

- [20200103_cbai_diamond_blastx/](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/)


Now that this is complete, I will proceed with using importing into MEGAN6, to create `rma6` file and then separately extract crab reads and _Hematodinium_ reads. These will then be used to generate "clean" transcriptome assemblies for Tanner crab and _Hematodinium_.

Here's the full list of MEGANIZED DIAMOND `daa` files and their sizes (note: they're _huge_ files):

- [304428_S1_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/304428_S1_L001_R1_001.blastx.daa) (56GB)

- [304428_S1_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/304428_S1_L001_R2_001.blastx.daa) (54GB)

- [304428_S1_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/304428_S1_L002_R1_001.blastx.daa) (54GB)

- [304428_S1_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/304428_S1_L002_R2_001.blastx.daa) (52GB)

- [329774_S1_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329774_S1_L001_R1_001.blastx.daa) (39GB)

- [329774_S1_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329774_S1_L001_R2_001.blastx.daa) (36GB)

- [329774_S1_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329774_S1_L002_R1_001.blastx.daa) (34GB)

- [329774_S1_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329774_S1_L002_R2_001.blastx.daa) (32GB)

- [329775_S2_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329775_S2_L001_R1_001.blastx.daa) (40GB)

- [329775_S2_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329775_S2_L001_R2_001.blastx.daa) (36GB)

- [329775_S2_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329775_S2_L002_R1_001.blastx.daa) (37GB)

- [329775_S2_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329775_S2_L002_R2_001.blastx.daa) (32GB)

- [329776_S3_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329776_S3_L001_R1_001.blastx.daa) (35GB)

- [329776_S3_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329776_S3_L001_R2_001.blastx.daa) (32GB)

- [329776_S3_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329776_S3_L002_R1_001.blastx.daa) (30GB)

- [329776_S3_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329776_S3_L002_R2_001.blastx.daa) (29GB)

- [329777_S4_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329777_S4_L001_R1_001.blastx.daa) (40GB)

- [329777_S4_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329777_S4_L001_R2_001.blastx.daa) (34GB)

- [329777_S4_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329777_S4_L002_R1_001.blastx.daa) (36GB)

- [329777_S4_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/329777_S4_L002_R2_001.blastx.daa) (31GB)
