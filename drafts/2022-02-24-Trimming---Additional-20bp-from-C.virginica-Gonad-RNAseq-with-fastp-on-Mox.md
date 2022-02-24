---
layout: post
title: Trimming - Additional 20bp from C.virginica Gonad RNAseq with fastp on Mox
date: '2022-02-24 07:26'
tags: 
  - fastp
  - mox
  - Crassostrea virginica
  - RNAseq
  - trimming
  - Eastern oyster
categories: 
  - Miscellaneous
---
When I previously [aligned trimmed RNAseq reads to the NCBI _C.virginica_ genome (GCF_002022765.2) on 20210720](https://robertslab.github.io/sams-notebook/2021/07/20/RNAseq-Alignments-C.virginica-Gonad-Data-to-GCF_002022765.2-Genome-Using-StringTie-on-Mox.html), I specifically noted that alignment rates were consistently lower for males than females. However, I let that discrepancy distract me from a the larger issue: low alignment rates. Period! This should have thrown some red flags and it eventually did after Steven asked about overall alignment rate for an alignment of this data that I performed on [20220131 in preparation for genome-guided transcriptome assembly](https://robertslab.github.io/sams-notebook/2022/01/31/RNAseq-Alignment-C.virginica-Adult-OA-Gonad-Data-to-GCF_002022765.2-Genome-Using-HISAT2-on-Mox.html). The overall alignment rate (in which I actually used the trimmed reads from [20210714](https://robertslab.github.io/sams-notebook/2021/07/14/Trimming-C.virginica-Gonad-RNAseq-with-FastP-on-Mox.html)) was ~67.6%. Realizing this was a on the low side of what one would expect, it prompted me to look into things more and I came across a few things which led me to make the decision to redo the trimming:

1. As mentioned, I used _untrimmed_ reads for [original set of RNAseq alignments](https://robertslab.github.io/sams-notebook/2021/07/20/RNAseq-Alignments-C.virginica-Gonad-Data-to-GCF_002022765.2-Genome-Using-StringTie-on-Mox.html). Although, as [as Steven has pointed out in this GitHub Issue](https://github.com/sr320/ceabigr/issues/50), trimming might not actually have any real impact on alignments as described in this paper: [Read trimming is not required for mapping and quantification of RNA-seq reads at the gene level. Liao and Shi, 2020](https://academic.oup.com/nargab/article/2/3/lqaa068/5901066)!

2. I contacted ZymoResearch to see if they had Bioanalyzer electropherograms post-rRNA removal (thinking that a large amount of contaminating rRNA would easily explain the low mapping rates). They did _not_ perform this analysis, but they did point me to a section of the RiboFree Kit they used when preparing the libraries explaining that the R2 reads should have an additional 10bp removed _after_ adapter removal. Here's the section from the manual:

```
Trimming Reads

The Zymo-Seq RiboFree® Total RNA Library Kit employs a low-
complexity bridge to ligate the Illumina® P7 adapter sequence to the

library inserts (See the library structure below). This sequence can
extend up to 10 nucleotides. QC analysis software (e.g., FastQC1
) may
raise flags such as “Per base sequence content” at the beginning of
Read 2 due to this low complexity bridge sequence.

If desired, these 10 nucleotides can be removed in addition to adapter
trimming. An example using Trim Galore!2

for such trimming is as below:

trim_galore --paired --clip_R2 10 \
-a NNNNNNNNNNAGATCGGAAGAGCACACGTCTGAACTCCAGTCAC \
-a2 AGATCGGAAGAGCGTCGTGTAGGGAAAGA \
sample.R1.fastq.gz
sample.R2.fastq.gz
```

Considering that we wanted to use these for a transcriptome assembly (which I already performed on [20220207](https://robertslab.github.io/sams-notebook/2022/02/07/Transcriptome-Assembly-Genome-guided-C.virginica-Adult-Gonad-OA-RNAseq-Using-Trinity-on-Mox.html)), this residual "low complexity bridge" could lead to some spurious results.

3. Looking at some of the samples from the initial trimming suggested that additional trimming would improve things a bit. Here's an example from the initial `fastp` trimming. View the sections with "After filtering: read1: base contents" and "After filtering: read2: base contents" to see that the first ~20bp ratios are a bit rough:

<iframe src="https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S3F_R1.fastp-trim.20210714.report.html" width="100%" height="1000" scrolling="yes"></iframe>

So, with that I decided to run an additional round of trimming to remove 20bp from the 5' ends of R1 and R2 reads. 

Job was run on Mox.

SBATCH script (GitHub):

- [20220224_cvir_gonad_RNAseq_fastp_trimming.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20220224_cvir_gonad_RNAseq_fastp_trimming.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20220224_cvir_gonad_RNAseq_fastp_trimming
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-00:00:00
## Memory per node
#SBATCH --mem=200G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20220224_cvir_gonad_RNAseq_fastp_trimming


### 2nd round of trimming Yaamini's C.virginica gonad RNAseq trimming using fastp, and MultiQC.
### Removes additional 20bp from 5' ends of R1 and R2 reads.

### 1st round of trimming performed on 20210714 by Sam.

### This additional round was prompted by low mapping rates to genome and feedback from ZymoResearch
### indicating that additional bases should be removed from 5' end of R2, after adapter removal.
### Reviewing intial trimming reports, it appears that an additional 20bp should be removed from
### 5' ends of both R1 and R2 reads.

### Expects input FastQ files to be in format: *_R[12].fastp-trim.20210714.fq.gz



###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=40

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5
reads_dir=/gscratch/srlab/sam/data/C_virginica/RNAseq/
fastq_checksums=input_fastq_checksums.md5

# Paths to programs
fastp=/gscratch/srlab/programs/fastp-0.20.0/fastp
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc

## Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()
R1_names_array=()
R2_names_array=()


# Programs associative array
declare -A programs_array
programs_array=(
[fastp]="${fastp}" \
[multiqc]="${multiqc}"
)


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Capture date
timestamp=$(date +%Y%m%d)

# Sync raw FastQ files to working directory
rsync --archive --verbose \
"${reads_dir}"*fastp-trim.20210714.fq.gz .

# Create arrays of fastq R1 files and sample names
for fastq in *_R1.fastp-trim.20210714.fq.gz
do
  fastq_array_R1+=("${fastq}")
  R1_names_array+=("$(echo "${fastq}" | awk 'BEGIN {FS = "[._]";OFS = "_"} {print $1, $2}')")
done

# Create array of fastq R2 files
for fastq in *_R2.fastp-trim.20210714.fq.gz
do
  fastq_array_R2+=("${fastq}")
  R2_names_array+=("$(echo "${fastq}" | awk 'BEGIN {FS = "[._]";OFS = "_"} {print $1, $2}')")
done

# Create list of fastq files used in analysis
# Create MD5 checksum for reference
for fastq in *fastp-trim.20210714.fq.gz
do
  echo "${fastq}" >> input.fastq.list.txt
  md5sum ${fastq} >> ${fastq_checksums}
done

# Run fastp on files
# Adds JSON report output for downstream usage by MultiQC
for index in "${!fastq_array_R1[@]}"
do
  R1_sample_name=$(echo "${R1_names_array[index]}")
  R2_sample_name=$(echo "${R2_names_array[index]}")
  ${fastp} \
  --in1 ${fastq_array_R1[index]} \
  --in2 ${fastq_array_R2[index]} \
  --disable_adapter_trimming \
  --trim_front1 20 \
  --trim_front2 20 \
  --thread ${threads} \
  --html "${R1_sample_name}".fastp-trim.20bp-5prime."${timestamp}".report.html \
  --json "${R1_sample_name}".fastp-trim.20bp-5prime."${timestamp}".report.json \
  --out1 "${R1_sample_name}".fastp-trim.20bp-5prime."${timestamp}".fq.gz \
  --out2 "${R2_sample_name}".fastp-trim.20bp-5prime."${timestamp}".fq.gz

  # Generate md5 checksums for newly trimmed files
  {
      md5sum "${R1_sample_name}".fastp-trim.20bp-5prime."${timestamp}".fq.gz
      md5sum "${R2_sample_name}".fastp-trim.20bp-5prime."${timestamp}".fq.gz
  } >> "${trimmed_checksums}"

  # Remove original FastQ files
  echo ""
  echo " Removing ${fastq_array_R1[index]} and ${fastq_array_R2[index]}."
  rm "${fastq_array_R1[index]}" "${fastq_array_R2[index]}"
done

# Run MultiQC
${multiqc} .

####################################################################

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

