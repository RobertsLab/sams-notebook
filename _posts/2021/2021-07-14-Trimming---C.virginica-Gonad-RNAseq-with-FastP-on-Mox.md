---
layout: post
title: Trimming - C.virginica Gonad RNAseq with FastP on Mox
date: '2021-07-14 10:57'
tags: 
  - fastp
  - mox
  - Crassostrea virginica
  - Eastern oyster
categories: 
  - Miscellaneous
---
Needed to trim the [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) gonad RNAseq data we [received on 20210528](https://robertslab.github.io/sams-notebook/2021/05/28/Data-Received-Yaamini's-C.virginica-WGBS-and-RNAseq-Data-from-ZymoResearch.html). 

All the metadata associated with these samples are available here:

https://github.com/RobertsLab/project-oyster-comparative-omics/blob/master/metadata/Virginica-Final-DNA-RNA-Yield.csv

Decided to run [`fastp`](https://github.com/OpenGene/fastp), followed with [`MultiQC`](https://multiqc.info/), on Mox.

SBATCH script (GitHub):

- [20210714_cvir_gonad_RNAseq_fastp_trimming.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210714_cvir_gonad_RNAseq_fastp_trimming.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210714_cvir_gonad_RNAseq_fastp_trimming
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210714_cvir_gonad_RNAseq_fastp_trimming


### Yaamini's C.virginica gonad RNAseq trimming using fastp, and MultiQC.

### Expects input FastQ files to be in format: *_R1.fastq.gz



###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=40

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5
raw_reads_dir=/gscratch/scrubbed/samwhite/data/C_virginica/RNAseq/
fastq_checksums=raw_fastq_checksums.md5

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
"${raw_reads_dir}"*.gz .

# Create arrays of fastq R1 files and sample names
for fastq in *_R1.fastq.gz
do
  fastq_array_R1+=("${fastq}")
  R1_names_array+=("$(echo "${fastq}" | awk 'BEGIN {FS = "[._]";OFS = "_"} {print $1, $2}')")
done

# Create array of fastq R2 files
for fastq in *_R2.fastq.gz
do
  fastq_array_R2+=("${fastq}")
  R2_names_array+=("$(echo "${fastq}" |awk 'BEGIN {FS = "[._]";OFS = "_"} {print $1, $2}')")
done

# Create list of fastq files used in analysis
# Create MD5 checksum for reference
for fastq in *.gz
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
  --detect_adapter_for_pe \
  --thread ${threads} \
  --html "${R1_sample_name}".fastp-trim."${timestamp}".report.html \
  --json "${R1_sample_name}".fastp-trim."${timestamp}".report.json \
  --out1 "${R1_sample_name}".fastp-trim."${timestamp}".fq.gz \
  --out2 "${R2_sample_name}".fastp-trim."${timestamp}".fq.gz

  # Generate md5 checksums for newly trimmed files
  {
      md5sum "${R1_sample_name}".fastp-trim."${timestamp}".fq.gz
      md5sum "${R2_sample_name}".fastp-trim."${timestamp}".fq.gz
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

Runtime was ~3hrs 40mins:

![Fastp runtime for C.virginica gonad RNAseq](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210629_cvir_fastqc_yaamini_rnaseq-wgbs_runtime.png?raw=true)

Output folder:

- [20210714_cvir_gonad_RNAseq_fastp_trimming](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming)

#### MultiQC Report (HTML):

- [20210714_cvir_gonad_RNAseq_fastp_trimming/multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/multiqc_report.html)

#### Trimmed FastQ files:

- [S12M_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S12M_R1.fastp-trim.20210714.fq.gz) (2.0G)

  - MD5: `e01d93658ff13c48fc15f715596d03fd`

- [S12M_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S12M_R2.fastp-trim.20210714.fq.gz) (2.0G)

  - MD5: `952bc8a281c8d5007dd5a0ab35ba8d77`

- [S13M_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S13M_R1.fastp-trim.20210714.fq.gz) (1.5G)

  - MD5: `25fca39d51c66454c36a84b313d9f86d`

- [S13M_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S13M_R2.fastp-trim.20210714.fq.gz) (1.5G)

  - MD5: `df85a0ffec9ef407f412e86535be1a86`

- [S16F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S16F_R1.fastp-trim.20210714.fq.gz) (1.6G)

  - MD5: `ad66d696a21009518e4f3ddbc7772ee9`

- [S16F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S16F_R2.fastp-trim.20210714.fq.gz) (1.6G)

  - MD5: `bfa22d74e6d6951742c59a908256742f`

- [S19F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S19F_R1.fastp-trim.20210714.fq.gz) (1.6G)

  - MD5: `48c91c307e8798f6f593b84a04c5b2d7`

- [S19F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S19F_R2.fastp-trim.20210714.fq.gz) (1.6G)

  - MD5: `b513e983beb4547f5c2128c8cc349f05`

- [S22F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S22F_R1.fastp-trim.20210714.fq.gz) (1.9G)

  - MD5: `fffe4264a29e881ab362e800145d29c7`

- [S22F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S22F_R2.fastp-trim.20210714.fq.gz) (1.9G)

  - MD5: `b6bef546ac820ffcae782d510908df84`

- [S23M_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S23M_R1.fastp-trim.20210714.fq.gz) (2.1G)

  - MD5: `065043919ab5b8fde29165f0e6e93743`

- [S23M_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S23M_R2.fastp-trim.20210714.fq.gz) (2.2G)

  - MD5: `41472a9d1f0618fbd430ba59f58a69bb`

- [S29F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S29F_R1.fastp-trim.20210714.fq.gz) (1.5G)

  - MD5: `399f3d5765c932229ae2aa1a1020fc86`

- [S29F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S29F_R2.fastp-trim.20210714.fq.gz) (1.5G)

  - MD5: `a291640a926647e8da09864cf20f182a`

- [S31M_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S31M_R1.fastp-trim.20210714.fq.gz) (1.4G)

  - MD5: `b48bdb9a2b376709b3b7ae9a6da262c8`

- [S31M_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S31M_R2.fastp-trim.20210714.fq.gz) (1.4G)

  - MD5: `5508840d5a1fe281f132aaf6488a2e6f`

- [S35F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S35F_R1.fastp-trim.20210714.fq.gz) (1.3G)

  - MD5: `7cb49fdf2375286d17ba24b98fa4cbbf`

- [S35F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S35F_R2.fastp-trim.20210714.fq.gz) (1.3G)

  - MD5: `f3ae3cec1f38c50693c3e6b6470e200b`

- [S36F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S36F_R1.fastp-trim.20210714.fq.gz) (1.4G)

  - MD5: `4ac69cc1a741706d5396a05760bebd22`

- [S36F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S36F_R2.fastp-trim.20210714.fq.gz) (1.5G)

  - MD5: `8fbec6b67d3e2037f764410ba5735c91`

- [S39F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S39F_R1.fastp-trim.20210714.fq.gz) (1.6G)

  - MD5: `69aa5d38d2e2f13db3ce6dee3527ab18`

- [S39F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S39F_R2.fastp-trim.20210714.fq.gz) (1.7G)

  - MD5: `f50ef43e663308631f8667c66718b67b`

- [S3F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S3F_R1.fastp-trim.20210714.fq.gz) (1.5G)

  - MD5: `58c6859ab3da0ee3c4a37b19b58de178`

- [S3F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S3F_R2.fastp-trim.20210714.fq.gz) (1.5G)

  - MD5: `6542461c5b7aef00417e5958ba353c22`

- [S41F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S41F_R1.fastp-trim.20210714.fq.gz) (1.5G)

  - MD5: `2e52a9528d27d91c8973c02da092b854`

- [S41F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S41F_R2.fastp-trim.20210714.fq.gz) (1.5G)

  - MD5: `cc2b47b4b4f5cf71ed9770fda3d33e86`

- [S44F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S44F_R1.fastp-trim.20210714.fq.gz) (1.6G)

  - MD5: `2e3c38f97a18571e014dac7345ccf5fd`

- [S44F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S44F_R2.fastp-trim.20210714.fq.gz) (1.7G)

  - MD5: `8749fbea9811e699c6d50eab60857cdb`

- [S48M_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S48M_R1.fastp-trim.20210714.fq.gz) (3.3G)

  - MD5: `6b0b814c4cbaf6dceae654d0bccc0b42`

- [S48M_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S48M_R2.fastp-trim.20210714.fq.gz) (3.4G)

  - MD5: `461d42c08789c79d70c655121bc7b7bc`

- [S50F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S50F_R1.fastp-trim.20210714.fq.gz) (1.4G)

  - MD5: `bffd3db6e5906449bc9423fbeced4ffb`

- [S50F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S50F_R2.fastp-trim.20210714.fq.gz) (1.4G)

  - MD5: `9ddb96837da5dbb2323b8b2f16a3d71a`

- [S52F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S52F_R1.fastp-trim.20210714.fq.gz) (1.6G)

  - MD5: `08944d7e5c914c87404b78dcc670a1e1`

- [S52F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S52F_R2.fastp-trim.20210714.fq.gz) (1.6G)

  - MD5: `b06677080a88d3ae272d8ca131b8fd00`

- [S53F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S53F_R1.fastp-trim.20210714.fq.gz) (1.5G)

  - MD5: `8eaa9322e3011006d2eefec291ad4a75`

- [S53F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S53F_R2.fastp-trim.20210714.fq.gz) (1.5G)

  - MD5: `709f9d6a53997346a74e140d3301b157`

- [S54F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S54F_R1.fastp-trim.20210714.fq.gz) (1.5G)

  - MD5: `71cd3b3c44a44b290faa889d74780b29`

- [S54F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S54F_R2.fastp-trim.20210714.fq.gz) (1.6G)

  - MD5: `094bd8faa104c6e91af673c0c10a19bd`

- [S59M_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S59M_R1.fastp-trim.20210714.fq.gz) (1.4G)

  - MD5: `5c7ceac3698d7984d58d9ebca0444ee6`

- [S59M_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S59M_R2.fastp-trim.20210714.fq.gz) (1.5G)

  - MD5: `a060ffc268ed745dc797cbdc64b21991`

- [S64M_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S64M_R1.fastp-trim.20210714.fq.gz) (1.6G)

  - MD5: `6b620871f618e1bcb9fcbd3eb57e6d6c`

- [S64M_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S64M_R2.fastp-trim.20210714.fq.gz) (1.6G)

  - MD5: `f79f330f4fdb220c7e9a6c6c72c90a0c`

- [S6M_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S6M_R1.fastp-trim.20210714.fq.gz) (2.2G)

  - MD5: `bbe4d4039a0b6148455bf26fc958f5ff`

- [S6M_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S6M_R2.fastp-trim.20210714.fq.gz) (2.3G)

  - MD5: `6e40c817288a06250274ed59bea82b15`

- [S76F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S76F_R1.fastp-trim.20210714.fq.gz) (1.7G)

  - MD5: `e2feeb3e5c48ee60984769daa4fc5b36`

- [S76F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S76F_R2.fastp-trim.20210714.fq.gz) (1.7G)

  - MD5: `c7144a17a5bba823d262da6f82c900e3`

- [S77F_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S77F_R1.fastp-trim.20210714.fq.gz) (1.8G)

  - MD5: `93352cfa5fb69352900935ea62d6f361`

- [S77F_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S77F_R2.fastp-trim.20210714.fq.gz) (1.9G)

  - MD5: `249c892f86e423b9927843189da31a16`

- [S7M_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S7M_R1.fastp-trim.20210714.fq.gz) (1.7G)

  - MD5: `65ea8bf2ee8b494de4982fc79a3c75c1`

- [S7M_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S7M_R2.fastp-trim.20210714.fq.gz) (1.8G)

  - MD5: `ed29e08a6b2a16c1919c1f80330c2cfb`

- [S9M_R1.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S9M_R1.fastp-trim.20210714.fq.gz) (2.0G)

  - MD5: `e2f5135159a2b1058c86683899200f95`

- [S9M_R2.fastp-trim.20210714.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/S9M_R2.fastp-trim.20210714.fq.gz) (2.2G)

  - MD5: `47684a0f9168e22317a8976dce1251fd`
