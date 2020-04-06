---
layout: post
title: Transcriptome Assembly - C.bairdi with MEGAN6 Taxonomy-specific Reads with Trinity on Mox
date: '2020-01-22 08:29'
tags:
  - mox
  - Tanner crab
  - Trinity
  - RNAseq
  - transcriptome
  - MEGAN6
  - assembly
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
Ran a _de novo_ assembly using [the extracted reads classified under _Arthropoda_ from 20200122](https://robertslab.github.io/sams-notebook/2020/01/22/Data-Wrangling-Arthropoda-and-Alveolata-Taxonomic-RNAseq-FastQ-Extractions.html) The assembly was performed with Trinity on Mox.


SBATCH Script (GitHub):

- [20200122_cbai_trinity_megan_RNAseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200122_cbai_trinity_megan_RNAseq.sh)

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
#SBATCH --time=10-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200122_cbai_trinity_megan_RNAseq

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

This was pretty quick, ~1.5hrs:

![Trinity runtime for C.bairdi assembly](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200122_cbai_trinity_megan_RNAseq_runtime.png?raw=true)

Output folder:

- [20200122_cbai_trinity_megan_RNAseq/](https://gannet.fish.washington.edu/Atumefaciens/20200122_cbai_trinity_megan_RNAseq/)

Assembly (FastA; 20MB):

- [20200122_cbai_trinity_megan_RNAseq/trinity_out_dir/20200122.C_bairdi.megan.Trinity.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200122_cbai_trinity_megan_RNAseq/trinity_out_dir/20200122.C_bairdi.megan.Trinity.fasta)

FastA Index (FAI):

- [20200122_cbai_trinity_megan_RNAseq/trinity_out_dir/20200122.C_bairdi.megan.Trinity.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20200122_cbai_trinity_megan_RNAseq/trinity_out_dir/20200122.C_bairdi.megan.Trinity.fasta.fai)

Trinity Gene Trans Map (txt):

- [20200122_cbai_trinity_megan_RNAseq/trinity_out_dir/20200122.C_bairdi.megan.Trinity.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20200122_cbai_trinity_megan_RNAseq/trinity_out_dir/20200122.C_bairdi.megan.Trinity.fasta.gene_trans_map)

Assembly stats (txt):

- [20200122_cbai_trinity_megan_RNAseq/assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20200122_cbai_trinity_megan_RNAseq/assembly_stats.txt)

---

```

################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	13803
Total trinity transcripts:	19670
Percent GC: 53.46

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 3528
	Contig N20: 2555
	Contig N30: 2029
	Contig N40: 1708
	Contig N50: 1431

	Median contig length: 745
	Average contig: 1007.16
	Total assembled bases: 19810930


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 3186
	Contig N20: 2340
	Contig N30: 1889
	Contig N40: 1584
	Contig N50: 1312

	Median contig length: 635
	Average contig: 899.22
	Total assembled bases: 12411973
	```
