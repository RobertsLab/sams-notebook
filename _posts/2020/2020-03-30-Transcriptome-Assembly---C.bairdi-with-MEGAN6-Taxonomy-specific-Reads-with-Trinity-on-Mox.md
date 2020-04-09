---
layout: post
title: Transcriptome Assembly - C.bairdi with MEGAN6 Taxonomy-specific Reads with Trinity on Mox
date: '2020-03-30 14:58'
tags:
  - Tanner crab
  - mox
  - Trinity
  - RNAseq
categories:
  - Miscellaneous
---
Ran a _de novo_ assembly using the extracted reads classified under _Arthropoda_ from:

- [20200122](https://robertslab.github.io/sams-notebook/2020/01/22/Data-Wrangling-Arthropoda-and-Alveolata-Taxonomic-RNAseq-FastQ-Extractions.html)

- [20200330](https://robertslab.github.io/sams-notebook/2020/03/30/RNAseq-Reads-Extractions-C.bairdi-Taxonomic-Reads-Extractions-with-MEGAN6-on-swoose.html)

The assembly was performed with Trinity on Mox. It's important to note that this assembly was _not_ performed using the "stranded" option in Trinity. The [previous Trinity assembly from 20200122](https://robertslab.github.io/sams-notebook/2020/01/22/Transcriptome-Assembly-C.bairdi-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html) _was_ performed using the "stranded" setting. The reason for this difference is that the [most recent RNAseq libraries from 20200318](https://robertslab.github.io/sams-notebook/2020/03/18/Data-Received-C.bairdi-RNAseq-Data-from-Genewiz.html) were _not stranded libraries_. As such, I think it might be best to use the "lowest common denominator" approach.

SBATCH script (GitHub):

- [20200330_cbai_trinity_megan_RNAseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200330_cbai_trinity_megan_RNAseq.sh)

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
#SBATCH --time=6-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200330_cbai_trinity_megan_RNAseq

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
threads=27
assembly_stats=assembly_stats.txt
timestamp=$(date +%Y%m%d)
fasta_name="${timestamp}.C_bairdi.megan.Trinity.fasta"

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
R1_array=("${reads_dir}"/*_R1.fq)

# Create array of fastq R2 files
R2_array=("${reads_dir}"/*_R2.fq)

# Create list of fastq files used in analysis
## Uses parameter substitution to strip leading path from filename
for fastq in "${reads_dir}"/*.fq
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
--max_memory 120G \
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

Took ~4hrs to run:

![Trinity Mox runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200330_cbai_trinity_megan_RNAseq_runtime.png?raw=true)

Output folder:

- [20200330_cbai_trinity_megan_RNAseq/](https://gannet.fish.washington.edu/Atumefaciens/20200330_cbai_trinity_megan_RNAseq/)

Assembly (FastA; 36MB):

- [20200330_cbai_trinity_megan_RNAseq/trinity_out_dir/20200408.C_bairdi.megan.Trinity.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200330_cbai_trinity_megan_RNAseq/trinity_out_dir/20200408.C_bairdi.megan.Trinity.fasta)

FastA Index (FAI):

- [20200330_cbai_trinity_megan_RNAseq/trinity_out_dir/20200408.C_bairdi.megan.Trinity.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20200330_cbai_trinity_megan_RNAseq/trinity_out_dir/20200408.C_bairdi.megan.Trinity.fasta.fai)

Trinity Gene Trans Map (txt):

- [20200330_cbai_trinity_megan_RNAseq/trinity_out_dir/Trinity.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20200330_cbai_trinity_megan_RNAseq/trinity_out_dir/Trinity.fasta.gene_trans_map)

Assembly Stats (txt):

- [20200330_cbai_trinity_megan_RNAseq/assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20200330_cbai_trinity_megan_RNAseq/assembly_stats.txt)


```
################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	24727
Total trinity transcripts:	40435
Percent GC: 53.17

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 3497
	Contig N20: 2502
	Contig N30: 1977
	Contig N40: 1611
	Contig N50: 1322

	Median contig length: 488
	Average contig: 824.28
	Total assembled bases: 33329770


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 3196
	Contig N20: 2364
	Contig N30: 1885
	Contig N40: 1534
	Contig N50: 1239

	Median contig length: 403
	Average contig: 741.81
	Total assembled bases: 18342751

```

When compared to [the previous assembly](https://robertslab.github.io/sams-notebook/2020/01/22/Transcriptome-Assembly-C.bairdi-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html), this certainly has more genes (24,727 vs 12,803), more transcripts (40,435 vs 19,670), and more assembled bases. However, the median length, average length and N50 values are all lower.
