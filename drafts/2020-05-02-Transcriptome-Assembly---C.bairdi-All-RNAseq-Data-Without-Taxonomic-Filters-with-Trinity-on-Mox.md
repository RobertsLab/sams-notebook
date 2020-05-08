---
layout: post
title: Transcriptome Assembly - C.bairdi All RNAseq Data Without Taxonomic Filters with Trinity on Mox
date: '2020-05-02 22:01'
tags:
  - trinity
  - mox
  - Tanner crab
  - RNAseq
  - Chionoecetes bairdi
  - transcriptome
  - assembly
categories:
  - Miscellaneous
---
[Steven asked that I assemble an unfiltered (i.e. no taxonomic selection) transcriptome](https://github.com/RobertsLab/resources/issues/923) with all of our _C.bairdi_ RNAseq data (see the FastQ list file linked in the Results section below). A _de novo_ assembly was run using Trinity on Mox. It should be noted that this assembly is a mixture of stranded/non-stranded library preps.


SBATCH Script (GitHub):

- [20200502_cbai_trinity_all_RNAseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200502_cbai_trinity_all_RNAseq.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=trinity_cbai
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=9-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200502_cbai_trinity_all_RNAseq

# Exit script if a command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log

# User-defined variables
reads_dir=/gscratch/srlab/sam/data/C_bairdi/RNAseq
transcriptome_dir=/gscratch/srlab/sam/data/C_bairdi/transcriptomes
threads=28
assembly_stats=assembly_stats.txt
timestamp=$(date +%Y%m%d)
fasta_name="${timestamp}.C_bairdi.Trinity.fasta"

# Paths to programs
trinity_dir="/gscratch/srlab/programs/trinityrnaseq-v2.9.0"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"


## Inititalize arrays
R1_array=()
R2_array=()

# Variables for R1/R2 lists
R1_list=""
R2_list=""

# Create array of fastq R1 files
R1_array=("${reads_dir}"/*_R1*fastp-trim*.fq.gz)

# Create array of fastq R2 files
R2_array=("${reads_dir}"/*_R2*fastp-trim*.fq.gz)

# Create list of fastq files used in analysis
## Uses parameter substitution to strip leading path from filename
for fastq in "${reads_dir}"/*fastp-trim*.fq.gz
do
  echo "${fastq##*/}" >> fastq.list.txt
done

# Create comma-separated lists of FastQ reads
R1_list=$(echo "${R1_array[@]}" | tr " " ",")
R2_list=$(echo "${R2_array[@]}" | tr " " ",")


# Run Trinity
## Not running as "stranded", due to mix of library types
${trinity_dir}/Trinity \
--seqType fq \
--max_memory 500G \
--CPU ${threads} \
--left "${R1_list}" \
--right "${R2_list}"

# Rename generic assembly FastA
mv trinity_out_dir/Trinity.fasta trinity_out_dir/"${fasta_name}"

# Assembly stats
${trinity_dir}/util/TrinityStats.pl trinity_out_dir/"${fasta_name}" \
> ${assembly_stats}

# Create gene map files
${trinity_dir}/util/support_scripts/get_Trinity_gene_to_trans_map.pl \
trinity_out_dir/"${fasta_name}" \
> trinity_out_dir/"${fasta_name}".gene_trans_map

# Create sequence lengths file (used for differential gene expression)
${trinity_dir}/util/misc/fasta_seq_length.pl \
trinity_out_dir/"${fasta_name}" \
> trinity_out_dir/"${fasta_name}".seq_lens

# Create FastA index
${samtools} faidx \
trinity_out_dir/"${fasta_name}"

# Copy files to transcriptome directory
rsync -av \
trinity_out_dir/"${fasta_name}"* \
${transcriptome_dir}
```
---

#### RESULTS

There were some hiccups (Mox crashes, weird Trinity error that interrupted job), but overall, it took ~4 days of actual run time.

![cbai Trinity all RNAseq runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200502_cbai_trinity_all_RNAseq_runtime.png?raw=true)

Output folder:

- [20200502_cbai_trinity_all_RNAseq/](https://gannet.fish.washington.edu/Atumefaciens/20200502_cbai_trinity_all_RNAseq/)

FastQ list (text):

- [20200502_cbai_trinity_all_RNAseq/fastq.list.txt](https://gannet.fish.washington.edu/Atumefaciens/20200502_cbai_trinity_all_RNAseq/fastq.list.txt)

FastA (904MB):

- [20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta)

FastA MD5 checksum:

`01adbd54298495c147767b19ee5c0de9`

FastA Index (text):

- [20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta.fai)


Trinity gene trans map (text; useful for downstream gene expression/annotation with Trinity/Trinotate):

- [20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta.gene_trans_map)

Trinity FastA sequence lengths file (text; useful for downstream gene expression/annotation with Trinity/Trinotate):

- [20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta.seq_lens](https://gannet.fish.washington.edu/Atumefaciens/20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta.seq_lens)

Assemby stats (text):

- [20200502_cbai_trinity_all_RNAseq/assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20200502_cbai_trinity_all_RNAseq/assembly_stats.txt)

```
################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	783006
Total trinity transcripts:	1412254
Percent GC: 45.41

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 3733
	Contig N20: 2571
	Contig N30: 1863
	Contig N40: 1285
	Contig N50: 811

	Median contig length: 325
	Average contig: 579.92
	Total assembled bases: 819000346


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 3093
	Contig N20: 1768
	Contig N30: 933
	Contig N40: 576
	Contig N50: 431

	Median contig length: 285
	Average contig: 434.16
	Total assembled bases: 339947966
```
