---
layout: post
title: FastQ Trimming and QC - C.virginica Larval BS-seq Data from Lotterhos Lab and Part of CEABIGR Project Using fastp on Mox
date: '2022-08-29 07:04'
tags: 
  - BSseq
  - Lotterhos
  - CEABIGR
  - Crassostrea virginica
  - Eastern oyster
  - fastp
  - mox
categories: 
  - Miscellaneous
---


[this GitHub Issue](https://github.com/RobertsLab/resources/issues/1517).



SBATCH script (GitHub):

- [20220826-cvir-larvae_zygote-BSseq-fastp_trimming.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20220826-cvir-larvae_zygote-BSseq-fastp_trimming.sh)

```bash
#!/bin/bash
## Job Name
#SBATCH --job-name=20220826-cvir-larvae_zygote-RNAseq-fastp_trimming
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20220826-cvir-larvae_zygote-BSseq-fastp_trimming


### Lotterhos C.virginica larvae and gonad BSseq trimming using fastp, and MultiQC.

### Expects input FastQ files to be in format: EF03-EM04-Larvae_R1_001.fastq.gz



###################################################################################
# These variables need to be set by user

# Set FastQ filename patterns
fastq_pattern='*.fastq.gz'
R1_fastq_pattern='*R1*.fastq.gz'
R2_fastq_pattern='*R2*.fastq.gz'

# Set number of CPUs to use
threads=40

# Input/output files
## Raw reads directory
raw_reads_dir=/gscratch/scrubbed/samwhite/data/C_virginica/BSseq/

## checksum files
trimmed_checksums=trimmed-fastq-checksums.md5
raw_fastq_checksums=raw-fastq-checksums.md5
input_fastq_checksums=input-fastq-checksums.md5

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

# Concatenate FastQ files from 1st and 2nd runs
# Do NOT quote fastq_pattern variable
# Will rsync all first run FastQs to working directory first,
# as there are missing second run FastQs; making concatenation process more complicated
# than I want to deal with.
for first_run_fastq in "${raw_reads_dir}"2018OALarvae_DNAm_discovery/${fastq_pattern}
do
  echo "Generating checksums for raw input FastQs..."

  # Strip full path to just get filename.
  first_run_fastq_name="${first_run_fastq##*/}"

  # Determine MD5 checksum
  md5sum "${first_run_fastq}" | tee --append "${raw_fastq_checksums}"
  echo ""

  # Rsync FastQ
  echo "Rsyncing ${first_run_fastq} to working directory."
  rsync -aP "${first_run_fastq}" .
  echo "Finished rsyncing ${first_run_fastq}."
  echo ""

  # Process second run and concatenate with corresponding FastQ from first run
  # Do NOT quote fastq_pattern variable
  for second_run_fastq in "${raw_reads_dir}"2018OALarvae_DNAm_discovery/second_lane/${fastq_pattern}
  do

    # Strip full path to just get filename.
    second_run_fastq_name="${second_run_fastq##*/}"

    # Concatenate FastQs with same filenames
    if [[ "${first_run_fastq_name}" == "${second_run_fastq_name}" ]]; then
      echo "Concatenating ${first_run_fastq_name} with ${second_run_fastq} to ${first_run_fastq_name}"
      echo ""
      cat "${second_run_fastq}" >> "${first_run_fastq_name}"
    fi
  done
  echo "Generating checksums for concatenated FastQs..."
  md5sum "${first_run_fastq_name}" | tee --append "${input_fastq_checksums}"
  echo ""
done

# Generate MD5 checksums for second run of FastQs
# Do NOT quote fastq_pattern variable
for second_run_fastq in "${raw_reads_dir}"2018OALarvae_DNAm_discovery/${fastq_pattern}
do
  echo "Generating checksums for second run raw input FastQs..."
    # Determine MD5 checksum
    md5sum "${second_run_fastq}" | tee --append "${raw_fastq_checksums}"
    echo ""
done

echo ""
echo "FastQ concatenation complete."
echo ""

# Create arrays of fastq R1 files and sample names
# Do NOT quote R1_fastq_pattern variable

for fastq in ${R1_fastq_pattern}
do
  fastq_array_R1+=("${fastq}")

  # Use parameter substitution to remove all text up to and including last "." from
  # right side of string.
  R1_names_array+=("${fastq%%.*}")
done

# Create array of fastq R2 files
# Do NOT quote R2_fastq_pattern variable
for fastq in ${R2_fastq_pattern}
do
  fastq_array_R2+=("${fastq}")

  # Use parameter substitution to remove all text up to and including last "." from
  # right side of string.
  R2_names_array+=(${fastq%%.*})
done



# Run fastp on files
# Adds JSON report output for downstream usage by MultiQC

echo "Beginning fastp trimming."
echo ""

for index in "${!fastq_array_R1[@]}"
do
  R1_sample_name="${R1_names_array[index]}"
  R2_sample_name="${R2_names_array[index]}"
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

echo "fastp trimming complete."
echo ""

# Run MultiQC
echo "Beginning MultiQC..."
echo ""
${multiqc} .
echo ""
echo "MultiQC complete."
echo ""

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

Runtime was surprisingly long, ~13hrs:

![Screencap of Mox runtime for fastp trimming of C.virginica larval/zygote FastQs from inbox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20220826-cvir-larvae_zygote-BSseq-fastp_trimming-runtime.png?raw=true)

Output folder:

- [20220826-cvir-larvae_zygote-BSseq-fastp_trimming](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/)

#### MultiQC Report (HTML - opens in web browser)

- [20220826-cvir-larvae_zygote-BSseq-fastp_trimming/multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/multiqc_report.html)

#### MD5 Checksum files (text)

- [input-fastq-checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/input-fastq-checksums.md5) (128K)

- [raw-fastq-checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/raw-fastq-checksums.md5) (128K)

- [trimmed-fastq-checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/trimmed-fastq-checksums.md5) (128K)



---

### Trimmed FastQs

- [CF01-CM01-Zygote_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF01-CM01-Zygote_R1_001.fastp-trim.20220827.fq.gz) (1.7G)

  - MD5: `12f8df2981cbd6a2721b9ab74a317823`

- [CF01-CM01-Zygote_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF01-CM01-Zygote_R2_001.fastp-trim.20220827.fq.gz) (1.8G)

  - MD5: `e380280e9081a2dd9d205ddbae411eb2`

- [CF01-CM02-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF01-CM02-Larvae_R1_001.fastp-trim.20220827.fq.gz) (6.8G)

  - MD5: `5683f4e247f65e2b89ad751d3015941e`

- [CF01-CM02-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF01-CM02-Larvae_R2_001.fastp-trim.20220827.fq.gz) (7.1G)

  - MD5: `b2ffa5a04395936522057632c16bbf5f`

- [CF02-CM02-Zygote_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF02-CM02-Zygote_R1_001.fastp-trim.20220827.fq.gz) (11G)

  - MD5: `5d49bdeccf3137855a218bb12f8718bc`

- [CF02-CM02-Zygote_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF02-CM02-Zygote_R2_001.fastp-trim.20220827.fq.gz) (11G)

  - MD5: `12a19d7ab32821bfc3c56b3bb4960963`

- [CF03-CM03-Zygote_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF03-CM03-Zygote_R1_001.fastp-trim.20220827.fq.gz) (6.6G)

  - MD5: `eb0e3fa10019ff57efe03a1337cda541`

- [CF03-CM03-Zygote_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF03-CM03-Zygote_R2_001.fastp-trim.20220827.fq.gz) (6.7G)

  - MD5: `c54595a4dfbf19d3957395bae9b78dca`

- [CF03-CM04-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF03-CM04-Larvae_R1_001.fastp-trim.20220827.fq.gz) (6.4G)

  - MD5: `ca8abb9fda4d9d658bac1f9f703fca99`

- [CF03-CM04-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF03-CM04-Larvae_R2_001.fastp-trim.20220827.fq.gz) (6.7G)

  - MD5: `6a3d24e35cd393ee7b90e9642c0e6211`

- [CF03-CM05-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF03-CM05-Larvae_R1_001.fastp-trim.20220827.fq.gz) (6.3G)

  - MD5: `d580dbf84db9d9ce1c46c30007ec0558`

- [CF03-CM05-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF03-CM05-Larvae_R2_001.fastp-trim.20220827.fq.gz) (6.5G)

  - MD5: `dafeacd05ceae42b9ec10894344fd8d4`

- [CF04-CM04-Zygote_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF04-CM04-Zygote_R1_001.fastp-trim.20220827.fq.gz) (6.8G)

  - MD5: `90aadd64eeee0f4acd035b1551a47c72`

- [CF04-CM04-Zygote_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF04-CM04-Zygote_R2_001.fastp-trim.20220827.fq.gz) (7.0G)

  - MD5: `04ece2ff54e39f7ba008454a120db956`

- [CF05-CM02-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF05-CM02-Larvae_R1_001.fastp-trim.20220827.fq.gz) (8.7G)

  - MD5: `c77a953bad8db1a01ff122b60447f60f`

- [CF05-CM02-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF05-CM02-Larvae_R2_001.fastp-trim.20220827.fq.gz) (9.1G)

  - MD5: `4528d42e50cf70651214d1355ccbbd03`

- [CF05-CM05-Zygote_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF05-CM05-Zygote_R1_001.fastp-trim.20220827.fq.gz) (7.5G)

  - MD5: `73effea12236ec02f1582073fca9487d`

- [CF05-CM05-Zygote_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF05-CM05-Zygote_R2_001.fastp-trim.20220827.fq.gz) (7.7G)

  - MD5: `1b195a1fd57bdd13cbe6b888283e6264`

- [CF06-CM01-Zygote_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF06-CM01-Zygote_R1_001.fastp-trim.20220827.fq.gz) (7.4G)

  - MD5: `a0e154b0e75d7c8913ea8ad4e5c3273d`

- [CF06-CM01-Zygote_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF06-CM01-Zygote_R2_001.fastp-trim.20220827.fq.gz) (7.6G)

  - MD5: `3590c352a6e49a20c69be83843b9cd22`

- [CF06-CM02-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF06-CM02-Larvae_R1_001.fastp-trim.20220827.fq.gz) (6.0G)

  - MD5: `9b5ee60b0cf6524d914a81e91ba8f17e`

- [CF06-CM02-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF06-CM02-Larvae_R2_001.fastp-trim.20220827.fq.gz) (6.3G)

  - MD5: `72c58d48baff2f6dcc9f7268bf5d0ee1`

- [CF07-CM02-Zygote_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF07-CM02-Zygote_R1_001.fastp-trim.20220827.fq.gz) (11G)

  - MD5: `ea473ce9c2f9f80f0eeccc34c8ca31eb`

- [CF07-CM02-Zygote_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF07-CM02-Zygote_R2_001.fastp-trim.20220827.fq.gz) (12G)

  - MD5: `007053a4002b5f0efe06722d55394747`

- [CF08-CM03-Zygote_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF08-CM03-Zygote_R1_001.fastp-trim.20220827.fq.gz) (7.5G)

  - MD5: `01a1cd682959d947c5db82550bb58f07`

- [CF08-CM03-Zygote_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF08-CM03-Zygote_R2_001.fastp-trim.20220827.fq.gz) (7.7G)

  - MD5: `9dc2701ae4c65e61fe182060f392edb1`

- [CF08-CM04-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF08-CM04-Larvae_R1_001.fastp-trim.20220827.fq.gz) (3.1G)

  - MD5: `d95f81647f43127e4e2868d2108cda1a`

- [CF08-CM04-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF08-CM04-Larvae_R2_001.fastp-trim.20220827.fq.gz) (3.2G)

  - MD5: `14de052215e0b1c244dcfcd1ef83ba3b`

- [CF08-CM05-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF08-CM05-Larvae_R1_001.fastp-trim.20220827.fq.gz) (4.8G)

  - MD5: `3151e296f863a8c72647112014ed4323`

- [CF08-CM05-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/CF08-CM05-Larvae_R2_001.fastp-trim.20220827.fq.gz) (4.9G)

  - MD5: `e24e23cd1f2544d9242099bfed9feb63`

- [EF01-EM01-Zygote_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF01-EM01-Zygote_R1_001.fastp-trim.20220827.fq.gz) (6.4G)

  - MD5: `8d13f56dbc64996b68d46eb3d6718bc0`

- [EF01-EM01-Zygote_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF01-EM01-Zygote_R2_001.fastp-trim.20220827.fq.gz) (6.7G)

  - MD5: `d2e807722434cb3e1f809b62bfe94e47`

- [EF02-EM02-Zygote_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF02-EM02-Zygote_R1_001.fastp-trim.20220827.fq.gz) (7.0G)

  - MD5: `ba3c32f669c8cf7f8cebeaa326e2c124`

- [EF02-EM02-Zygote_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF02-EM02-Zygote_R2_001.fastp-trim.20220827.fq.gz) (7.2G)

  - MD5: `04363a049d229e293f55a353d86a9b7e`

- [EF03-EM03-Zygote_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF03-EM03-Zygote_R1_001.fastp-trim.20220827.fq.gz) (6.6G)

  - MD5: `f87c5bd5dc936e31b24be6a4641533f4`

- [EF03-EM03-Zygote_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF03-EM03-Zygote_R2_001.fastp-trim.20220827.fq.gz) (6.8G)

  - MD5: `d22e3b366f7925dcd7f6423959a692c2`

- [EF03-EM04-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF03-EM04-Larvae_R1_001.fastp-trim.20220827.fq.gz) (7.1G)

  - MD5: `b86786ef26d0c457bc7cd9132171c6e5`

- [EF03-EM04-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF03-EM04-Larvae_R2_001.fastp-trim.20220827.fq.gz) (7.3G)

  - MD5: `9955ad6581deeec0ef7a2a4fd3dc3add`

- [EF03-EM05-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF03-EM05-Larvae_R1_001.fastp-trim.20220827.fq.gz) (7.4G)

  - MD5: `b97793f3c112f99e684007afea1d3793`

- [EF03-EM05-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF03-EM05-Larvae_R2_001.fastp-trim.20220827.fq.gz) (8.0G)

  - MD5: `e1f15320454cec901ff55c859faea251`

- [EF04-EM04-Zygote_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF04-EM04-Zygote_R1_001.fastp-trim.20220827.fq.gz) (7.5G)

  - MD5: `db6a2f540da624f1d5f6e6f115e9be37`

- [EF04-EM04-Zygote_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF04-EM04-Zygote_R2_001.fastp-trim.20220827.fq.gz) (7.8G)

  - MD5: `3392de88b79f5d7ed869a361b210b6c1`

- [EF04-EM05-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF04-EM05-Larvae_R1_001.fastp-trim.20220827.fq.gz) (7.8G)

  - MD5: `82e93ae37039e2d364fae8456e8402bc`

- [EF04-EM05-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF04-EM05-Larvae_R2_001.fastp-trim.20220827.fq.gz) (8.2G)

  - MD5: `2a97684b1ce7766e0bc6defc6c658f00`

- [EF05-EM01-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF05-EM01-Larvae_R1_001.fastp-trim.20220827.fq.gz) (5.9G)

  - MD5: `553cae24e62a3d9d13a40932f4abf7cd`

- [EF05-EM01-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF05-EM01-Larvae_R2_001.fastp-trim.20220827.fq.gz) (6.1G)

  - MD5: `8bc90d15d6ea3dbf7fc3a0230946d393`

- [EF05-EM05-Zygote_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF05-EM05-Zygote_R1_001.fastp-trim.20220827.fq.gz) (6.4G)

  - MD5: `0e485302097e7418cbb3e0da51c816d8`

- [EF05-EM05-Zygote_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF05-EM05-Zygote_R2_001.fastp-trim.20220827.fq.gz) (6.6G)

  - MD5: `cda27057c4035d802eea34df4a205951`

- [EF05-EM06-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF05-EM06-Larvae_R1_001.fastp-trim.20220827.fq.gz) (12G)

  - MD5: `d3b29de534520e21e919e081893b24ef`

- [EF05-EM06-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF05-EM06-Larvae_R2_001.fastp-trim.20220827.fq.gz) (13G)

  - MD5: `6b49a13d08da78ac926f756c4535fbb0`

- [EF06-EM01-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF06-EM01-Larvae_R1_001.fastp-trim.20220827.fq.gz) (7.9G)

  - MD5: `2d15a505990a48b867d680b69888ea6e`

- [EF06-EM01-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF06-EM01-Larvae_R2_001.fastp-trim.20220827.fq.gz) (8.3G)

  - MD5: `9742ad2f80aa34dbd823d893832fc260`

- [EF06-EM02-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF06-EM02-Larvae_R1_001.fastp-trim.20220827.fq.gz) (6.1G)

  - MD5: `19a757707e3fed916a8543cafbba7da4`

- [EF06-EM02-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF06-EM02-Larvae_R2_001.fastp-trim.20220827.fq.gz) (6.4G)

  - MD5: `116ee8a54cfb88dd6f03ceee5d7678ed`

- [EF06-EM06-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF06-EM06-Larvae_R1_001.fastp-trim.20220827.fq.gz) (8.2G)

  - MD5: `cdd926c032dff99c4e1805085c6ba2dc`

- [EF06-EM06-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF06-EM06-Larvae_R2_001.fastp-trim.20220827.fq.gz) (8.4G)

  - MD5: `e489f1dd1e96af1de0195574753488be`

- [EF07-EM01-Zygote_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF07-EM01-Zygote_R1_001.fastp-trim.20220827.fq.gz) (13G)

  - MD5: `ce149c91743b5fec393fae482af3b299`

- [EF07-EM01-Zygote_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF07-EM01-Zygote_R2_001.fastp-trim.20220827.fq.gz) (14G)

  - MD5: `4aa1860340ed7da0c8ffa79193c58403`

- [EF07-EM03-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF07-EM03-Larvae_R1_001.fastp-trim.20220827.fq.gz) (7.0G)

  - MD5: `17f9a6aaf6b9ad9bb8496668eb90d8f0`

- [EF07-EM03-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF07-EM03-Larvae_R2_001.fastp-trim.20220827.fq.gz) (7.3G)

  - MD5: `f5c408282b5bd76ac723367e42c152a2`

- [EF08-EM03-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF08-EM03-Larvae_R1_001.fastp-trim.20220827.fq.gz) (8.2G)

  - MD5: `b351e650cae8b4b7157abcfdc5af1b1b`

- [EF08-EM03-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF08-EM03-Larvae_R2_001.fastp-trim.20220827.fq.gz) (8.5G)

  - MD5: `4ad43654c347859cebc1b4dab3abe2fa`

- [EF08-EM04-Larvae_R1_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF08-EM04-Larvae_R1_001.fastp-trim.20220827.fq.gz) (5.8G)

  - MD5: `1f0711648941a4427f0ad643a8eccbfa`

- [EF08-EM04-Larvae_R2_001.fastp-trim.20220827.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20220826-cvir-larvae_zygote-BSseq-fastp_trimming/EF08-EM04-Larvae_R2_001.fastp-trim.20220827.fq.gz) (6.0G)

  - MD5: `f5bc8a42549642cda5a9294567933321`
