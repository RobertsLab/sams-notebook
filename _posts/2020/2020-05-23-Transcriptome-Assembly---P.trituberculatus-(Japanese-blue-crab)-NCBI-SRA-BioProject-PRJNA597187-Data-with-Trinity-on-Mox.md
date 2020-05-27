---
layout: post
title: Transcriptome Assembly - P.trituberculatus (Japanese blue crab) NCBI SRA BioProject PRJNA597187 Data with Trinity on Mox
date: '2020-05-23 06:09'
tags:
  - Japanese blue crab
  - Portunus trituberculatus
  - Trinity
  - mox
  - transcriptome assembly
  - PRJNA597187
categories:
  - Miscellaneous
---
After generating a number of [_C.bairdi_ (Tanner crab) transcriptomes](https://github.com/RobertsLab/resources/wiki/Genomic-Resources#transcriptomes), we decided we should compare them to evaluate which to help decide which one should become our "canonical" version. As part of that, [the Trinity wiki offers a list of tools](https://github.com/trinityrnaseq/trinityrnaseq/wiki/Transcriptome-Assembly-Quality-Assessment) that one can use to check the quality of transcriptome assemblies. Some of those require a transcriptome of a related species.

A cursory search didn't yield anything that jumped out at me, so [I downloaded (and checked strandedness) of NCBI SRA RNAseq data for _P.trituberculatus_ (Japanese blue crab)](https://robertslab.github.io/sams-notebook/2020/05/21/SRA-Library-Assessment-Determine-RNAseq-Library-Strandedness-from-P.trituberculatus-SRA-BioProject-PRJNA597187.html) and decided to assemble a transcriptome myself.

Ran Trinity on Mox.

SBATCH script (GitHub):

- [20200523_ptri_trinity_transcriptome.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200523_ptri_trinity_transcriptome.sh)

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
#SBATCH --time=12-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200523_ptri_trinity_transcriptome


### Trinity de novo assembly of all pooled P.trituberculatus RNAseq data.
### Assembly to be used for assessing our C.bairdi transcriptome assemblies.
### Data was taken from NCBI SRA BioProject PRJNA597187.
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
reads_dir=/gscratch/srlab/sam/data/P_trituberculatus/RNAseq
transcriptome_dir=/gscratch/srlab/sam/data/P_trituberculatus/transcriptomes
threads=28
assembly_stats=assembly_stats.txt
timestamp=$(date +%Y%m%d)
fasta_name="${timestamp}.P_trituberculatus.Trinity.fasta"

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
R1_array=("${reads_dir}"/*.fastq)

# Create array of fastq R2 files
R2_array=("${reads_dir}"/*.fastq)

# Create list of fastq files used in analysis
## Uses parameter substitution to strip leading path from filename
for fastq in "${reads_dir}"/*.fastq
do
  echo "${fastq##*/}" >> fastq.list.txt
done

# Create comma-separated lists of FastQ reads
R1_list=$(echo "${R1_array[@]}" | tr " " ",")
R2_list=$(echo "${R2_array[@]}" | tr " " ",")


# Run Trinity
# Running as stranded, based off of analysis on 20200521:
# https://robertslab.github.io/sams-notebook/2020/05/21/SRA-Library-Assessment-Determine-RNAseq-Library-Strandedness-from-P.trituberculatus-SRA-BioProject-PRJNA597187.html
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
cd trinity_out_dir
md5sum "${fasta_name}" > "${fasta_name}".checksum.md5
```


---

#### RESULTS

Took ~2 days to run:

![ptri trinity assembly runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200523_ptri_trinity_transcriptome_runtime.png?raw=true)

This assembly did hit a small hiccup during the Butterfly portion where it hung indefinitely. I [posted an issue on the Trinity GitHub Issues](https://github.com/trinityrnaseq/trinityrnaseq/issues/849) and received instructions on how to resolve it. Apparently, it was due to a very high number of low complexity sequences. Check that issue for info on how it was resolved.

Also, while this was running, I ended up tracking down two additional crab transcriptomes on NCBI:

- [_Carcinus maenas_](https://www.ncbi.nlm.nih.gov/Traces/wgs/?val=GBXE01) (European green crab; Thanks to Grace)

- [_Portunus trituberculatus_](https://www.ncbi.nlm.nih.gov/Traces/wgs/?val=GFFJ01)

So, I don't really need the resulting transcriptome assembly... Oh well, here it is anyway!

Output folder:

- [20200523_ptri_trinity_transcriptome](https://gannet.fish.washington.edu/Atumefaciens/20200523_ptri_trinity_transcriptome)

FastA:

- [20200523_ptri_trinity_transcriptome/trinity_out_dir/20200526.P_trituberculatus.Trinity.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200523_ptri_trinity_transcriptome/trinity_out_dir/20200526.P_trituberculatus.Trinity.fasta) (386MB)

FastA Index:

- [20200523_ptri_trinity_transcriptome/trinity_out_dir/20200526.P_trituberculatus.Trinity.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20200523_ptri_trinity_transcriptome/trinity_out_dir/20200526.P_trituberculatus.Trinity.fasta.fai)

Assembly stats (text):

- [20200523_ptri_trinity_transcriptome/assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20200523_ptri_trinity_transcriptome/assembly_stats.txt)

```
################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	408543
Total trinity transcripts:	580098
Percent GC: 44.63

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 3865
	Contig N20: 2697
	Contig N30: 1980
	Contig N40: 1442
	Contig N50: 1012

	Median contig length: 331
	Average contig: 628.37
	Total assembled bases: 364514830


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 3226
	Contig N20: 2047
	Contig N30: 1310
	Contig N40: 840
	Contig N50: 564

	Median contig length: 284
	Average contig: 483.10
	Total assembled bases: 197366539
  ```
