---
layout: post
title: Transcriptome Assembly - C.bairdi All Pooled Arthropoda-only RNAseq Data with Trinity on Mox
date: '2020-05-27 08:52'
tags:
  - mox
  - Tanner crab
  - Trinity
  - RNAseq
  - transcriptome
  - assembly
  - Chionoecetes bairdi
  - MEGAN6
categories:
  - Miscellaneous
---
For completeness sake, I wanted to create an additional _C.bairdi_ transcriptome assembly that consisted of _Arthropoda_ only sequences from just pooled RNAseq data (since I [recently generated a similar assembly _without_ taxonomically filtered reads on 20200518](https://robertslab.github.io/sams-notebook/2020/05/18/Transcriptome-Assembly-C.bairdi-All-Pooled-RNAseq-Data-Without-Taxonomic-Filters-with-Trinity-on-Mox.html)). This constitutes samples we have designated: 2018, 2019, 2020-UW. A _de novo_ assembly was run using Trinity on Mox. Since all pooled RNAseq libraries were stranded, I added this option to Trinity command.

The resulting assembly will be referred to as:

- `cbai_transcriptome_v1.7.fasta`

SBATCH script (GitHub):

- [20200527_cbai_trinity_arthropoda_pooled_RNAseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200527_cbai_trinity_arthropoda_pooled_RNAseq.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=trinity_cbai_v1.7
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200527_cbai_trinity_arthropoda_pooled_RNAseq


### Trinity de novo assembly of all pooled C.bairdi Arthropoda-only RNAseq data.
### Includes "descriptor_1" short-hand of: 2020-UW, 2019, 2018.
### See fastq.list.txt file for list of input files used for assembly.

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
fasta_name="cbai_transcriptome_v1.7.fasta"

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
R1_array=("${reads_dir}"/*3[80][804]*R1.fq)

# Create array of fastq R2 files
R2_array=("${reads_dir}"/*3[80][804]*R2.fq)

# Create list of fastq files used in analysis
## Uses parameter substitution to strip leading path from filename
for fastq in "${reads_dir}"/*3[80][804]*.fq
do
  echo "${fastq##*/}" >> fastq.list.txt
done

# Create comma-separated lists of FastQ reads
R1_list=$(echo "${R1_array[@]}" | tr " " ",")
R2_list=$(echo "${R2_array[@]}" | tr " " ",")


# Run Trinity
${trinity_dir}/Trinity \
--seqType fq \
--max_memory 500G \
--CPU ${threads} \
--SS_lib_type RF \
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

# Generate FastA MD5 checksum
# See last line of SLURM output file
cd trinity_out_dir/
md5sum "${fasta_name}" > "${fasta_name}".checksum.md5
```


---

#### RESULTS

Remarkably quick; only ~1.5hrs:

![Trinity pooled Arthropoda RNAseq runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200527_cbai_trinity_arthropoda_pooled_RNAseq_runtime.png?raw=true)


Output folder:

- [20200527_cbai_trinity_arthropoda_pooled_RNAseq](https://gannet.fish.washington.edu/Atumefaciens/20200527_cbai_trinity_arthropoda_pooled_RNAseq)


Input FastQ list (text):

- [fastq.list.txt](https://gannet.fish.washington.edu/Atumefaciens/20200527_cbai_trinity_arthropoda_pooled_RNAseq/fastq.list.txt)

FastA (412MB):

- [cbai_transcriptome_v1.7.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200527_cbai_trinity_arthropoda_pooled_RNAseq/trinity_out_dir/cbai_transcriptome_v1.7.fasta)

  - MD5 = `032d1f81c7744736ebeefe7f63ed6d95`

FastA Index (text):

- [cbai_transcriptome_v1.7.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20200527_cbai_trinity_arthropoda_pooled_RNAseq/trinity_out_dir/cbai_transcriptome_v1.7.fasta.fai)

The following sets of files are useful for downstream gene expression and annotation using Trinity.

Trinity FastA Gene Trans Map (text):

- [cbai_transcriptome_v1.7.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20200527_cbai_trinity_arthropoda_pooled_RNAseq/trinity_out_dir/cbai_transcriptome_v1.7.fasta.gene_trans_map)

Trinity FastA Sequence Lengths (text):

- [cbai_transcriptome_v1.7.fasta.seq_lens](https://gannet.fish.washington.edu/Atumefaciens/20200527_cbai_trinity_arthropoda_pooled_RNAseq/trinity_out_dir/cbai_transcriptome_v1.7.fasta.seq_lens)


Assembly stats (text):

- [assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20200527_cbai_trinity_arthropoda_pooled_RNAseq/assembly_stats.txt)

```
################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	14225
Total trinity transcripts:	20526
Percent GC: 53.57

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 3760
	Contig N20: 2713
	Contig N30: 2122
	Contig N40: 1777
	Contig N50: 1504

	Median contig length: 777
	Average contig: 1053.71
	Total assembled bases: 21628372


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 3373
	Contig N20: 2449
	Contig N30: 1958
	Contig N40: 1645
	Contig N50: 1371

	Median contig length: 659
	Average contig: 930.99
	Total assembled bases: 13243346
```
