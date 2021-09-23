---
layout: post
title: Transcriptome Assembly - C.bairdi Trimmed RNAseq Using Trinity on Mox
date: '2019-12-18 13:27'
tags:
  - trinity
  - assembly
  - transcriptome
  - RNAseq
  - tanner crab
  - mox
  - 20191218_cbai_trinity_RNAse
categories:
  - Tanner Crab RNAseq
---
Earlier today, [I trimmed our existing _C.bairdi_ RNAseq data](https://robertslab.github.io/sams-notebook/2019/12/18/TrimmingFastQCMultiQC-C.bairdi-RNAseq-FastQ-with-fastp-on-Mox.html), as part of producing generating a transcriptome ([per this GitHub issue](https://github.com/RobertsLab/resources/issues/808)). After trimming, I performed a _de novo_ assembly using [Trinity (v2.9.0)](https://github.com/trinityrnaseq/trinityrnaseq) with the stranded library option (`--SS_lib_type RF`) on Mox.

List of input files used (text):

- [20191218_cbai_trinity_RNAseq/fastq.list.tx](https://gannet.fish.washington.edu/Atumefaciens/20191218_cbai_trinity_RNAseq/fastq.list.txt)


SBATCH script (GitHub):

- [20191218_cbai_trinity_RNAseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20191218_cbai_trinity_RNAseq.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=trin_cbai
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=30-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20191218_cbai_trinity_RNAseq

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
reads_dir=/gscratch/scrubbed/samwhite/outputs/20191218_cbai_fastp_RNAseq_trimming
threads=27
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
R1_array=(${reads_dir}/*_R1_*.gz)

# Create array of fastq R2 files
R2_array=(${reads_dir}/*_R2_*.gz)

# Create list of fastq files used in analysis
## Uses parameter substitution to strip leading path from filename
for fastq in ${reads_dir}/*.gz
do
  echo "${fastq##*/}" >> fastq.list.txt
done

# Create comma-separated lists of FastQ reads
R1_list=$(echo "${R1_array[@]}" | tr " " ",")
R2_list=$(echo "${R2_array[@]}" | tr " " ",")


# Run Trinity using "stranded" setting (--SS_lib_type)
${trinity_dir}/Trinity \
--seqType fq \
--max_memory 500G \
--CPU ${threads} \
--SS_lib_type RF \
--left "${R1_list}" \
--right "${R2_list}"

# Rename generic assembly FastA
mv trinity_out_dir/Trinity.fasta trinity_out_dir/${fasta_name}

# Assembly stats
${trinity_dir}/util/TrinityStats.pl trinity_out_dir/${fasta_name} \
> ${assembly_stats}

# Create gene map files
${trinity_dir}/util/support_scripts/get_Trinity_gene_to_trans_map.pl \
trinity_out_dir/${fasta_name} \
> trinity_out_dir/${fasta_name}.gene_trans_map

# Create FastA index
${samtools} faidx \
trinity_out_dir/${fasta_name}
```


---

#### RESULTS

This ran relatively quickly (~14hrs), but the Mox email system appeared to be significantly delayed (~8rs difference between email notifications and actual start/stop times of the job):

![screencap of C.bai trinity runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20191218_cbai_trinity_RNAseq_runtime.png?raw=true)

Output folder:

- [20191218_cbai_trinity_RNAseq/](https://gannet.fish.washington.edu/Atumefaciens/20191218_cbai_trinity_RNAseq/)

Trinity FastA:

- [20191218_cbai_trinity_RNAseq/trinity_out_dir/20191218.C_bairdi.Trinity.fasta](https://gannet.fish.washington.edu/Atumefaciens/20191218_cbai_trinity_RNAseq/trinity_out_dir/20191218.C_bairdi.Trinity.fasta)

Trinity FastA index (via `samtools`):

- [20191218_cbai_trinity_RNAseq/trinity_out_dir/20191218.C_bairdi.Trinity.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20191218_cbai_trinity_RNAseq/trinity_out_dir/20191218.C_bairdi.Trinity.fasta.fai)

Trinity gene trans map:

- [20191218_cbai_trinity_RNAseq/trinity_out_dir/20191218.C_bairdi.Trinity.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20191218_cbai_trinity_RNAseq/trinity_out_dir/20191218.C_bairdi.Trinity.fasta.gene_trans_map)

Trinity assembly stats (txt):

- [20191218_cbai_trinity_RNAseq/assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20191218_cbai_trinity_RNAseq/assembly_stats.txt)

```


################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	110785
Total trinity transcripts:	313589
Percent GC: 46.11

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 4395
	Contig N20: 3382
	Contig N30: 2773
	Contig N40: 2337
	Contig N50: 1961

	Median contig length: 689
	Average contig: 1146.98
	Total assembled bases: 359680329


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 4529
	Contig N20: 3430
	Contig N30: 2780
	Contig N40: 2276
	Contig N50: 1821

	Median contig length: 405
	Average contig: 882.36
	Total assembled bases: 97752083
```
