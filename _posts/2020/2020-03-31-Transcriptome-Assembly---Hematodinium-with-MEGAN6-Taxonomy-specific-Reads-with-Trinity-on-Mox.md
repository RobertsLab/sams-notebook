---
layout: post
title: Transcriptome Assembly - Hematodinium with MEGAN6 Taxonomy-specific Reads with Trinity on Mox
date: '2020-03-30 15:30'
tags:
  - Trinity
  - Hematodinium
  - transcriptome
  - assembly
  - mox
  - MEGAN6
categories:
  - Miscellaneous
---
Ran a _de novo_ assembly using the extracted reads classified under _Alveolata_ from:

- [20200122](https://robertslab.github.io/sams-notebook/2020/01/22/Data-Wrangling-Arthropoda-and-Alveolata-Taxonomic-RNAseq-FastQ-Extractions.html)

- [20200330](https://robertslab.github.io/sams-notebook/2020/03/30/RNAseq-Reads-Extractions-C.bairdi-Taxonomic-Reads-Extractions-with-MEGAN6-on-swoose.html)

The assembly was performed with Trinity on Mox. It's important to note that this assembly was _not_ performed using the "stranded" option in Trinity. The [previous Trinity assembly from 20200122](https://robertslab.github.io/sams-notebook/2020/01/22/Transcriptome-Assembly-Hematodinium-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html) _was_ performed using the "stranded" setting. The reason for this difference is that the [most recent RNAseq libraries from 20200318](https://robertslab.github.io/sams-notebook/2020/03/18/Data-Received-C.bairdi-RNAseq-Data-from-Genewiz.html) were _not stranded libraries_. As such, I think it might be best to use the "lowest common denominator" approach.

SBATCH script (GitHub):

- [20200330_hemat_trinity_megan_RNAseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200330_hemat_trinity_megan_RNAseq.sh)


```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=trinity_hemat
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200330_hemat_trinity_megan_RNAseq

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
reads_dir=/gscratch/srlab/sam/data/Hematodinium/RNAseq
threads=27
assembly_stats=assembly_stats.txt
timestamp=$(date +%Y%m%d)
fasta_name="${timestamp}.hemat.megan.Trinity.fasta"

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
R1_array=(${reads_dir}/*_R1.fq)

# Create array of fastq R2 files
R2_array=(${reads_dir}/*_R2.fq)

# Create list of fastq files used in analysis
## Uses parameter substitution to strip leading path from filename
for fastq in ${reads_dir}/*.fq
do
  echo "${fastq##*/}" >> fastq.list.txt
done

# Create comma-separated lists of FastQ reads
R1_list=$(echo "${R1_array[@]}" | tr " " ",")
R2_list=$(echo "${R2_array[@]}" | tr " " ",")


# Run Trinity using "stranded" setting (--SS_lib_type)
${trinity_dir}/Trinity \
--seqType fq \
--max_memory 120G \
--CPU ${threads} \
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

This was remarkably fast! I think was likely due to not using the "stranded" setting in Trinity.

![](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200330_hemat_trinity_megan_RNAseq_runtime.png?raw=true)

Output folder:

- [20200330_hemat_trinity_megan_RNAseq/](https://gannet.fish.washington.edu/Atumefaciens/20200330_hemat_trinity_megan_RNAseq/)


Assembly (FastA; 4.5MB):

- [20200330_hemat_trinity_megan_RNAseq/trinity_out_dir/20200408.hemat.megan.Trinity.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200330_hemat_trinity_megan_RNAseq/trinity_out_dir/20200408.hemat.megan.Trinity.fasta)

FastA Index (FAI):

- [20200330_hemat_trinity_megan_RNAseq/trinity_out_dir/20200408.hemat.megan.Trinity.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20200330_hemat_trinity_megan_RNAseq/trinity_out_dir/20200408.hemat.megan.Trinity.fasta.fai)

Trinity Gene Trans Map (txt):

- [20200330_hemat_trinity_megan_RNAseq/trinity_out_dir/20200408.hemat.megan.Trinity.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20200330_hemat_trinity_megan_RNAseq/trinity_out_dir/20200408.hemat.megan.Trinity.fasta.gene_trans_map)

Assembly Stats (txt):

- [20200330_hemat_trinity_megan_RNAseq/assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20200330_hemat_trinity_megan_RNAseq/assembly_stats.txt)

```
################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	5632
Total trinity transcripts:	6348
Percent GC: 50.37

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 1805
	Contig N20: 1406
	Contig N30: 1152
	Contig N40: 961
	Contig N50: 817

	Median contig length: 530
	Average contig: 656.83
	Total assembled bases: 4169557


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 1770
	Contig N20: 1386
	Contig N30: 1131
	Contig N40: 941
	Contig N50: 797

	Median contig length: 511
	Average contig: 636.72
	Total assembled bases: 3586009
```

Interestingly, this assembly may actually be worse than the [previous Trinity assembly from 20200122](https://robertslab.github.io/sams-notebook/2020/01/22/Transcriptome-Assembly-Hematodinium-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html). Although it has marginally greater numbers of trinity genes and trinity transcripts, virtually all other metrics have decreased (albeit, not by much). Will assess transcriptome completeness with BUSCO and see if there's any noticeable improvement on that front.
