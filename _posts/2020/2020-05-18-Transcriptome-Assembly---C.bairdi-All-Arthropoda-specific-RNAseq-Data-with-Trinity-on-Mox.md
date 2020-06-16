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
[I realized I hadn't performed taxonomic read separation from one set of RNAseq data we had](https://robertslab.github.io/sams-notebook/2020/05/18/Data-Wrangling-Arthropoda-and-Alveolata-D26-Pool-RNAseq-FastQ-Extractions.html). And, since I was on a transcriptome assembly kick, I figured I'd generate another _C.bairdi_ transcriptome that included only Arthropoda-specific sequence data from all of our RNAseq.  

shorthand: 2018, 2019, GW-2020, UW-2020

It's quick and doesn't require much effort, so why not?

SBATCH script (GitHub):

- [20200518_cbai_trinity_all_Arthropoda_RNAseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200518_cbai_trinity_all_Arthropoda_RNAseq.sh)

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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200518_cbai_trinity_all_Arthropoda_RNAseq

### De novo transcriptome assembly of all Arthropoda-specific reads
### Includes "descriptor_1" short-hand of: 2020-GW, 2020-UW, 2019, 2018.
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
fasta_name="cbai_transcriptome_v1.6.fasta"

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
R1_array=("${reads_dir}"/*megan_R1*.fq)

# Create array of fastq R2 files
R2_array=("${reads_dir}"/*megan_R2*.fq)

# Create list of fastq files used in analysis
## Uses parameter substitution to strip leading path from filename
for fastq in "${!R1_array[@]}"
do
  {
    echo "${R1_array[${fastq}]##*/}"
    echo "${R2_array[${fastq}]##*/}"
  } >> fastq.list.txt
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

# Generate FastA MD5 checksum
# See last line of SLURM output file
cd trinity_out_dir
md5sum trinity_out_dir/"${fasta_name}"
```

---

#### RESULTS

Pretty quick; only ~3.5hrs (NOTE: Job indicates it failed. This is due to wrong path for `md5sum` command on last line of script. Trinity _de novo_ assembly completed without issue.):

![Trinity all Arthropoda-specific RNAseq runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200518_cbai_trinity_all_Arthropoda_RNAseq_runtime.png?raw=true)


Output folder:

- [20200518_cbai_trinity_all_Arthropoda_RNAseq/](https://gannet.fish.washington.edu/Atumefaciens/20200518_cbai_trinity_all_Arthropoda_RNAseq/)

Input FastQ list (text):

- [fastq.list.txt](https://gannet.fish.washington.edu/Atumefaciens/20200518_cbai_trinity_all_Arthropoda_RNAseq/fastq.list.txt)

FastA (36MB):

- [cbai_transcriptome_v1.6.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200518_cbai_trinity_all_Arthropoda_RNAseq/trinity_out_dir/cbai_transcriptome_v1.6.fasta)

  - MD5 = `46d77ce86cdbbcac26bf1a6cb820651e`

FastA Index (text):

- [cbai_transcriptome_v1.6.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20200518_cbai_trinity_all_Arthropoda_RNAseq/trinity_out_dir/cbai_transcriptome_v1.6.fasta.fai)

The following sets of files are useful for downstream gene expression and annotation using Trinity.

Trinity FastA Gene Trans Map (text):

- [cbai_transcriptome_v1.6.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20200518_cbai_trinity_all_Arthropoda_RNAseq/trinity_out_dir/cbai_transcriptome_v1.6.fasta.gene_trans_map)

Trinity FastA Sequence Lengths (text):

- [cbai_transcriptome_v1.6.fasta.seq_lens](https://gannet.fish.washington.edu/Atumefaciens/20200518_cbai_trinity_all_Arthropoda_RNAseq/trinity_out_dir/cbai_transcriptome_v1.6.fasta.seq_lens)


Assembly stats (text):

- [20200518_cbai_trinity_all_Arthropoda_RNAseq/assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20200518_cbai_trinity_all_Arthropoda_RNAseq/assembly_stats.txt)

```
################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	23199
Total trinity transcripts:	40130
Percent GC: 53.22

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 3643
	Contig N20: 2619
	Contig N30: 2077
	Contig N40: 1716
	Contig N50: 1419

	Median contig length: 557
	Average contig: 895.83
	Total assembled bases: 35949841


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 3401
	Contig N20: 2491
	Contig N30: 1978
	Contig N40: 1634
	Contig N50: 1333

	Median contig length: 438
	Average contig: 795.21
	Total assembled bases: 18448144
  ```
