---
layout: post
title: Transcriptome Assembly - Genome-guided C.virginica Adult Gonad OA RNAseq Using Trinity on Mox
date: '2022-02-07 10:42'
tags: 
  - trinity
  - rnaseq
  - assembly
  - transcriptome
  - Crassostrea virginica
  - Eastern oyster
  - mox
categories: 
  - Miscellaneous
---
As part of [this project](https://github.com/epigeneticstoocean/2018_L18-adult-methylation), Steven's asked that [I identify long, non-coding RNAs (lncRNAs)](https://github.com/RobertsLab/resources/issues/1375) (GitHub Issue) in the [_Crassostrea gigas_ (Pacific oyster)](http://en.wikipedia.org/wiki/Pacific_oyster) adult OA gonad RNAseq data we have. The initial step for this is to assemble transcriptome. I generated the necessary BAM alignment on [20220131](https://robertslab.github.io/sams-notebook/2022/01/31/RNAseq-Alignment-C.virginica-Adult-OA-Gonad-Data-to-GCF_002022765.2-Genome-Using-HISAT2-on-Mox.html). Next was to actually get the transcriptome assembled. I followed the [`Trinity`](https://github.com/trinityrnaseq/trinityrnaseq/wiki) genome-guided procedure.

SBATCH script (GitHub):

- [20220207_cvir_trinity-gg_adult-oa-gonad_assembly-1.0.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20220207_cvir_trinity-gg_adult-oa-gonad_assembly-1.0.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20220212_cvir_trinity-gg_adult-oa-gonad_assembly-1.0
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=21-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20220212_cvir_trinity-gg_adult-oa-gonad_assembly-1.0

### Genome-guided (NCBI RefSeq GCF_002022765.2) de novo transcriptome assembly of C.virginica adult OA gonda RNAseq.
### See input_fastqs.md5 file for list of input files used for assembly.


###################################################################################
# These variables need to be set by user

## Assign Variables

# These variables need to be set by user

# Path to this script
script_path=/gscratch/scrubbed/samwhite/outputs/20220207_cvir_trinity-gg_adult-oa-gonad_assembly-1.0/20220207_cvir_trinity-gg_adult-oa-gonad_assembly-1.0.sh

# RNAseq FastQs directory
reads_dir=/gscratch/srlab/sam/data/C_virginica/RNAseq

# Transcriptomes directory
transcriptomes_dir=/gscratch/srlab/sam/data/C_virginica/transcriptomes

# CPU threads
threads=40

# Capture specified RAM from this script
# Carrot needed to limit grep to line starting with #SBATCH
# Avoids grep-ing the command below.
max_mem=100G
# BAM file for genome guided assembly
sorted_bam=/gscratch/scrubbed/samwhite/outputs/20220131_cvir_hisat2-GCF_002022765.2_adult-oa-gonad/20210131-cvir-hisat2.sorted.bam

# Max intron size
max_intron=10000

# Name output files
fasta_name="cvir_GG-GCF_002022765.2_transcriptome_v1.0.fasta"
assembly_stats="${fast_name}_assembly_stats.txt"

# Paths to programs
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"
trinity_dir="/gscratch/srlab/programs/trinityrnaseq-v2.9.0"

# Programs associative array
declare -A programs_array
programs_array=(
[samtools_faidx]="${samtools} faidx" \
[samtools_index]="${samtools} index" \
[samtools_sort]="${samtools} sort" \
[samtools_view]="${samtools} view" \
)

###################################################################################

# Exit script if a command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017



## Inititalize arrays
R1_array=()
R2_array=()

# Variables for R1/R2 lists
R1_list=""
R2_list=""

# Create array of fastq R1 files
R1_array=("${reads_dir}"/*R1.fastp-trim*.fq.gz)

# Create array of fastq R2 files
R2_array=("${reads_dir}"/*R2.fastp-trim*.fq.gz)

# Create list of fastq files used in analysis
## Uses parameter substitution to strip leading path from filename
for fastq in "${!R1_array[@]}"
do
  {
    md5sum "${R1_array[${fastq}]}"
    md5sum "${R2_array[${fastq}]}"
  } >> input_fastqs.md5
done

# Create comma-separated lists of FastQ reads
R1_list=$(echo "${R1_array[@]}" | tr " " ",")
R2_list=$(echo "${R2_array[@]}" | tr " " ",")


# Run Trinity
## Running as "stranded" (--SS_lib_type)
${trinity_dir}/Trinity \
--genome_guided_bam ${sorted_bam} \
--genome_guided_max_intron ${max_intron} \
--seqType fq \
--SS_lib_type RF \
--max_memory ${max_mem} \
--CPU ${threads} \
--left "${R1_list}" \
--right "${R2_list}"

# Rename generic assembly FastA
find . -name "Trinity*.fasta" -exec mv {} trinity_out_dir/"${fasta_name}" \;

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
${programs_array[samtools_faidx]} \
trinity_out_dir/"${fasta_name}"

# Copy files to transcriptome directory
rsync -av \
trinity_out_dir/"${fasta_name}"* \
${transcriptome_dir}

# Generate FastA MD5 checksum
md5sum trinity_out_dir/"${fasta_name}" > fasta_checksum.md5

#######################################################################################################

# Capture program options
if [[ "${#programs_array[@]}" -gt 0 ]]; then
  echo "Logging program options..."
  for program in "${!programs_array[@]}"
  do
    {
    echo "Program options for ${program}: "
    echo ""
    # Handle samtools help menus
    if [[ "${program}" == "samtools_index" ]] \
    || [[ "${program}" == "samtools_sort" ]] \
    || [[ "${program}" == "samtools_view" ]]
    then
      ${programs_array[$program]}

    # Handle DIAMOND BLAST menu
    elif [[ "${program}" == "diamond" ]]; then
      ${programs_array[$program]} help

    # Handle NCBI BLASTx menu
    elif [[ "${program}" == "blastx" ]]; then
      ${programs_array[$program]} -help
    fi
    ${programs_array[$program]} -h
    echo ""
    echo ""
    echo "----------------------------------------------"
    echo ""
    echo ""
  } &>> program_options.log || true

    # If MultiQC is in programs_array, copy the config file to this directory.
    if [[ "${program}" == "multiqc" ]]; then
      cp --preserve ~/.multiqc_config.yaml multiqc_config.yaml
    fi
  done
fi


# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log

```


---

#### RESULTS

Output folder:

- []()


```
################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	887315
Total trinity transcripts:	1849486
Percent GC: 36.26

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 7967
	Contig N20: 5284
	Contig N30: 3814
	Contig N40: 2801
	Contig N50: 2062

	Median contig length: 562
	Average contig: 1117.46
	Total assembled bases: 2066718534


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 6904
	Contig N20: 4398
	Contig N30: 3003
	Contig N40: 2120
	Contig N50: 1501

	Median contig length: 434
	Average contig: 860.79
	Total assembled bases: 763788564
  ```