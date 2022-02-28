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
When I previously [aligned trimmed RNAseq reads to the NCBI _C.virginica_ genome (GCF_002022765.2) on 20210726](https://robertslab.github.io/sams-notebook/2021/07/26/Transcript-Identification-and-Quantification-C.virginia-RNAseq-With-NCBI-Genome-GCF_002022765.2-Using-StringTie-on-Mox.html), I specifically noted that alignment rates were consistently lower for males than females. However, I let that discrepancy distract me from a the larger issue: low alignment rates. Period! This should have thrown some red flags and it eventually did after Steven asked about overall alignment rate for an alignment of this data that I performed on [20220131 in preparation for genome-guided transcriptome assembly](https://robertslab.github.io/sams-notebook/2022/01/31/RNAseq-Alignment-C.virginica-Adult-OA-Gonad-Data-to-GCF_002022765.2-Genome-Using-HISAT2-on-Mox.html). The overall alignment rate (in which I actually used the trimmed reads from [20210714](https://robertslab.github.io/sams-notebook/2021/07/14/Trimming-C.virginica-Gonad-RNAseq-with-FastP-on-Mox.html)) was ~67.6%. Realizing this was a on the low side of what one would expect, it prompted me to look into things more and I came across a few things which led me to make the decision to redo the trimming:

1. As mentioned, I used _untrimmed_ reads for [original set of RNAseq alignments](https://robertslab.github.io/sams-notebook/2021/07/26/Transcript-Identification-and-Quantification-C.virginia-RNAseq-With-NCBI-Genome-GCF_002022765.2-Using-StringTie-on-Mox.html). Although, as [as Steven has pointed out in this GitHub Issue](https://github.com/sr320/ceabigr/issues/50), trimming might not actually have any real impact on alignments as described in this paper: [Read trimming is not required for mapping and quantification of RNA-seq reads at the gene level. Liao and Shi, 2020](https://academic.oup.com/nargab/article/2/3/lqaa068/5901066)!

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

3. Looking at some of the samples from the initial trimming suggested that additional trimming would improve things a bit. Here's an example from the initial `fastp` trimming. View the sections with "After filtering: read1: base contents" and "After filtering: read2: base contents" to see that the first ~20bp ratios are a bit rough.

NOTE: Words are tough to read on dark background - sorry! Also, you can click on _any_ section heading to collapse it - This reduces the need to scroll so much!

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

Unsurprisingly, this was pretty fast since no adapter trimming was needed, at just under 2hrs:

![fastp trimming runtime screencap on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20220224_cvir_gonad_RNAseq_fastp_trimming_runtime.png?raw=true)

Output folder:

- [20220224_cvir_gonad_RNAseq_fastp_trimming/](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/)


In my opinion, things look better. Here's the same sample shown above, now with the additional 20bp trimmed from the 5' ends of R1 and R2 reads:

<iframe src="https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S3F_R1.fastp-trim.20bp-5prime.20220224.report.html" width="100%" height="1000" scrolling="yes"></iframe>

Links to MultiQC report and trimmed FastQ files are below.

  #### MultiQC Report (HTML):

    - NOTE: Visit the output folder linked above to view each individual samples `fastp` HTML report; has additional info not shown in [`MultiQC`](https://multiqc.info/) summary report.

    - [20220224_cvir_gonad_RNAseq_fastp_trimming/multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/multiqc_report.html)

  #### Trimmed FastQ files:

  - [S12M_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S12M_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.7G)

    - MD5: `99b0f574bbcb9812c685e8e3213a67b6`

  - [S12M_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S12M_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.8G)

    - MD5: `3d0170e88b76aecddf6ddddd96a7d941`

  - [S13M_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S13M_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.3G)

    - MD5: `f6fdc9b42c5db0ee2f899379e43e0137`

  - [S13M_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S13M_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.3G)

    - MD5: `2c397b4600845927b1983293e38d58b4`

  - [S16F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S16F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.4G)

    - MD5: `d0a60ae1b48c241aa0b38fcd13774085`

  - [S16F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S16F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.5G)

    - MD5: `d1cf561e5a368f9b20321e74a332fe63`

  - [S19F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S19F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.4G)

    - MD5: `ff0fbe4141d7e6d1d4229490a75de5f1`

  - [S19F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S19F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.4G)

    - MD5: `12443047a3e9b13d541cb1ae69bf073b`

  - [S22F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S22F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.6G)

    - MD5: `e4a159fe2aa903ec6e26312b33813114`

  - [S22F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S22F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.7G)

    - MD5: `4f30ffe06dc64e15c69d42951176b001`

  - [S23M_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S23M_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.9G)

    - MD5: `b4031ff4cd7fd442e44785f2e44e5d18`

  - [S23M_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S23M_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.9G)

    - MD5: `cb7f83d7ec3be004a913166af348e77c`

  - [S29F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S29F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.3G)

    - MD5: `e05036937c75d196a8ef24db09fd36cd`

  - [S29F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S29F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.3G)

    - MD5: `a5c74db92c8fa9b8a841f3a0638ccad8`

  - [S31M_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S31M_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.2G)

    - MD5: `e014a1295045288b5db955aed4793fc1`

  - [S31M_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S31M_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.3G)

    - MD5: `872d62fbe70bca451f570a0337c7f3f0`

  - [S35F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S35F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.2G)

    - MD5: `a2be5cb6abd2da7231f2ca6695ccd01a`

  - [S35F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S35F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.2G)

    - MD5: `233384dbd06d94ad208749f5a1b5d5d0`

  - [S36F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S36F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.3G)

    - MD5: `6c58948cb32335097fd2146e1d0064aa`

  - [S36F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S36F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.3G)

    - MD5: `6a7cb8a67f14d874325ffc938f7ca23e`

  - [S39F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S39F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.4G)

    - MD5: `24cea1a33fc5cd439255f34c49c3ca76`

  - [S39F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S39F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.5G)

    - MD5: `df2d580ce5e0f6d766e7671de3fe27b8`

  - [S3F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S3F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.3G)

    - MD5: `cb0d617b444da9cdecb229933a914b08`

  - [S3F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S3F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.3G)

    - MD5: `55f771d133f2feece5e3892ad4a76802`

  - [S41F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S41F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.3G)

    - MD5: `b04ef71c6e9e394f16db974c9ca67788`

  - [S41F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S41F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.4G)

    - MD5: `eae79874123039d812eed6654b8811e3`

  - [S44F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S44F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.4G)

    - MD5: `fca55614fefb0822d5fd8bab5c008354`

  - [S44F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S44F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.5G)

    - MD5: `c4c4c7511467540c1f698de4cf76673d`

  - [S48M_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S48M_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (2.8G)

    - MD5: `ed2a4eaef4614fd043cd16cbde009359`

  - [S48M_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S48M_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (2.9G)

    - MD5: `8e516e9d75c011a31255a7dfb97faa90`

  - [S50F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S50F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.2G)

    - MD5: `2aa446be1afb5b291778fca0976c9acc`

  - [S50F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S50F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.2G)

    - MD5: `1586577bbe081247bb1cf62f7f01e54b`

  - [S52F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S52F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.4G)

    - MD5: `c8c8896970fc2738f43e446a3462bb46`

  - [S52F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S52F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.4G)

    - MD5: `5b1cee1d2378a6466b689061dbddee93`

  - [S53F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S53F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.3G)

    - MD5: `d63e96937f18a539761c5a9754b46b58`

  - [S53F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S53F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.4G)

    - MD5: `a1fef250ce3edb7246396a11db6bfd71`

  - [S54F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S54F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.3G)

    - MD5: `184036757cee04964d4dd7fd233527fe`

  - [S54F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S54F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.4G)

    - MD5: `f5d97f3ebde99fbe8ad104be5b88e6ad`

  - [S59M_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S59M_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.3G)

    - MD5: `f0f9be7b7273045395a39c31c081aeeb`

  - [S59M_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S59M_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.3G)

    - MD5: `e39abfaff4b3c73e19651f1231a3af86`

  - [S64M_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S64M_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.4G)

    - MD5: `ee4482a24d592da5771f016f2d03e779`

  - [S64M_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S64M_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.5G)

    - MD5: `d277626c8c1588f16af27481914ae12a`

  - [S6M_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S6M_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.9G)

    - MD5: `326fc303fd89b916780ec74c60081cc3`

  - [S6M_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S6M_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (2.0G)

    - MD5: `39240b8c4c33c940f16dafce63aca37d`

  - [S76F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S76F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.5G)

    - MD5: `4556863436b9199a5900681b94411f65`

  - [S76F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S76F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.5G)

    - MD5: `c25281b78c9273a3a1a722e1ece890a8`

  - [S77F_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S77F_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.6G)

    - MD5: `958327c7042fc661780e34208341814f`

  - [S77F_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S77F_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.6G)

    - MD5: `c901d54d5ad12d53f19e5e46fc7ce5e0`

  - [S7M_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S7M_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.5G)

    - MD5: `b49e7f2874d339835c84e7b65e24ffd5`

  - [S7M_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S7M_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.5G)

    - MD5: `40fd3ac474e752c3c20e2b20fe1ca520`

  - [S9M_R1.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S9M_R1.fastp-trim.20bp-5prime.20220224.fq.gz) (1.8G)

    - MD5: `e8e67c186888ea68a2e6a7c124eb9bc2`

  - [S9M_R2.fastp-trim.20bp-5prime.20220224.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220224_cvir_gonad_RNAseq_fastp_trimming/S9M_R2.fastp-trim.20bp-5prime.20220224.fq.gz) (1.9G)

    - MD5: `b59e44b19669db230b7e08bb809104c5`