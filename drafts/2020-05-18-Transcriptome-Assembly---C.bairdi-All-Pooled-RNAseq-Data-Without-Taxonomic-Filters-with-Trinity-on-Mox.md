---
layout: post
title: Transcriptome Assembly - C.bairdi All Pooled RNAseq Data Without Taxonomic Filters with Trinity on Mox
date: '2020-05-18 05:28'
tags:
  - Chionoecetes bairdi
  - Tanner crab
  - mox
  - trinity
  - assembly
  - transcriptome
categories:
  - Miscellaneous
---
[Steven asked that I assemble a transcriptome](https://github.com/RobertsLab/resources/issues/936) with just  our pooled _C.bairdi_ RNAseq data (_not_ taxonomically filtered; see the FastQ list file linked in the Results section below). This constitutes samples we have designated: 2018, 2019, 2020-UW. A _de novo_ assembly was run using Trinity on Mox. Since all pooled RNAseq libraries were stranded, I added this option to Trinity command.


SBATCH script (GitHub):

- [20200518_cbai_trinity_pooled_RNAseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200518_cbai_trinity_pooled_RNAseq.sh)

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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200518_cbai_trinity_pooled_RNAseq


### Trinity de novo assembly of all pooled C.bairdi RNAseq data.
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
R1_array=("${reads_dir}"/3*_S[0-9]*R1*-trim*.gz)

# Create array of fastq R2 files
R2_array=("${reads_dir}"/3*_S[0-9]*R2*-trim*.gz)

# Create list of fastq files used in analysis
## Uses parameter substitution to strip leading path from filename
for fastq in "${reads_dir}"/3*_S[0-9]*-trim*.gz
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
md5sum trinity_out_dir/"${fasta_name}"
```

---

#### RESULTS

Output folder:

- []()
