---
layout: post
title: FastQ Trimming - Geoduck RNAseq Data Using fastp on Mox
date: '2022-09-08 14:09'
tags: 
  - Panopea generosa
  - geoduck
  - mox
  - fastp
  - trimming
  - RNAseq
categories: 
  - Miscellaneous
---



SBATCH script:

- [20220909-pgen-fastqc-fastp-mutliqc-rnaseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20220909-pgen-fastqc-fastp-mutliqc-rnaseq.sh) (GitHub)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20220909-pgen-fastqc-fastp-mutliqc-rnaseq
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=4-00:00:00
## Memory per node
#SBATCH --mem=200G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20220909-pgen-fastqc-fastp-mutliqc-rnaseq

### FastQC and fastp trimming of P.generosa RNAseq data.

### fastp input filenames to be in format: *.fastq.gz



###################################################################################
# These variables need to be set by user

# Set FastQ filename patterns
fastq_pattern='*.fastq.gz'
R1_fastq_pattern='*R1*.fastq.gz'
R2_fastq_pattern='*R2*.fastq.gz'

# Set number of CPUs to use
threads=40

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5
reads_dir=/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/
fastq_checksums=input_fastq_checksums.md5

# FastQC output directory
output_dir=$(pwd)

# Paths to programs
fastp=/gscratch/srlab/programs/fastp-0.20.0/fastp
fastqc=/gscratch/srlab/programs/fastqc_v0.11.9/fastqc
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc

## Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()
R1_names_array=()
R2_names_array=()
raw_fastqs_array=()


# Programs associative array
declare -A programs_array
programs_array=(
[fastqc]="${fastqc}"
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
echo ""
echo "Transferring files via rsync..."
rsync --archive --verbose \
"${reads_dir}"${fastq_pattern} .
echo ""
echo "File transfer complete."
echo ""

### Run FastQC ###

### NOTE: Do NOT quote raw_fastqc_list
# Create array of trimmed FastQs
raw_fastqs_array=(${fastq_pattern})

# Pass array contents to new variable as space-delimited list
raw_fastqc_list=$(echo "${raw_fastqs_array[*]}")

echo "Beginning FastQC on raw reads..."
echo ""

# Run FastQC
${programs_array[fastqc]} \
--threads ${threads} \
--outdir ${output_dir} \
${raw_fastqc_list}

echo "FastQC on raw reads complete!"
echo ""

### END FASTQC ###

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
  R2_names_array+=("${fastq%%.*}")
done


# Create MD5 checksums for raw FastQs
for fastq in ${fastq_pattern}
do
  echo "Generating checksum for ${fastq}"
  md5sum "${fastq}" | tee --append ${fastq_checksums}
  echo ""
done


### RUN FASTP ###

# Run fastp on files
# Adds JSON report output for downstream usage by MultiQ
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

echo ""
echo "fastp trimming complete."
echo ""

### END FASTP ###


### RUN FASTQC ###

### NOTE: Do NOT quote ${trimmed_fastqc_list}

# Create array of trimmed FastQs
trimmed_fastq_array=(*fastp-trim*.fq.gz)

# Pass array contents to new variable as space-delimited list
trimmed_fastqc_list=$(echo "${trimmed_fastq_array[*]}")

# Run FastQC
echo "Beginning FastQC on trimmed reads..."
echo ""
${programs_array[fastqc]} \
--threads ${threads} \
--outdir ${output_dir} \
${trimmed_fastqc_list}

echo ""
echo "FastQC on trimmed reads complete!"
echo ""

### END FASTQC ###

### RUN MULTIQC ###
echo "Beginning MultiQC..."
echo ""
${multiqc} .
echo ""
echo "MultiQC complete."
echo ""

### END MULTIQC ###

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

Runtime was a bit over 3hrs.

NOTE: Job indicates it failed. Although technically true, the failure was specifically related to MultiQC trying to process a FastQC file that was run on an empty post-trimming FastQ file and accorred at the very end of the script. So, everything that "needed" to run actually did run; just don't have a MultiQC summary for the FastQC analyses.

There was a single set of paired FastQs which had no sequence data after trimming:

`Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L001_R[12]_001.fastp-trim.20220908.fq.gz`


![Screencap of Mox job emails showing runtime of 3hrs 19mins and 5secs. Also shows job failed, but failure was simply due to an empty post-trimming FastQ file causing FastQC and, in turn MultiQC, to freak out.](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20220909-pgen-fastqc-fastp-mutliqc-rnaseq-runtime.png?raw=true)

Output folder:

- [20220909-pgen-fastqc-fastp-mutliqc-rnaseq/](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/)

All trimmed FastQs can be retrieved with this pattern:

`*fastp-trim.20220908.fq.gz`


  - [`MultiQC`](https://multiqc.info/) Report (HTML - opens interactive plots in browser):

    - [20220909-pgen-fastqc-fastp-mutliqc-rnaseq/multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/multiqc_report.html)

  - Input FastQ MD5 checksums (text):

    - [20220909-pgen-fastqc-fastp-mutliqc-rnaseq/input_fastq_checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/input_fastq_checksums.md5)

  - Trimmed FastQ MD5 checksums (text):

    - [20220909-pgen-fastqc-fastp-mutliqc-rnaseq/trimmed_fastq_checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/trimmed_fastq_checksums.md5)

  - FastQC Reports (HTML)

    - [Geo_Pool_F_GGCTAC_L006_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geo_Pool_F_GGCTAC_L006_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geo_Pool_F_GGCTAC_L006_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geo_Pool_F_GGCTAC_L006_R1_001_fastqc.html)

    - [Geo_Pool_F_GGCTAC_L006_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geo_Pool_F_GGCTAC_L006_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geo_Pool_F_GGCTAC_L006_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geo_Pool_F_GGCTAC_L006_R2_001_fastqc.html)

    - [Geo_Pool_M_CTTGTA_L006_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geo_Pool_M_CTTGTA_L006_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geo_Pool_M_CTTGTA_L006_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geo_Pool_M_CTTGTA_L006_R1_001_fastqc.html)

    - [Geo_Pool_M_CTTGTA_L006_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geo_Pool_M_CTTGTA_L006_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geo_Pool_M_CTTGTA_L006_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geo_Pool_M_CTTGTA_L006_R2_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-1_S3_L001_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-1_S3_L001_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-1_S3_L001_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-1_S3_L001_R1_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-1_S3_L001_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-1_S3_L001_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-1_S3_L001_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-1_S3_L001_R2_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-2_S11_L002_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-2_S11_L002_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-2_S11_L002_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-2_S11_L002_R1_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-2_S11_L002_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-2_S11_L002_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-2_S11_L002_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-2_S11_L002_R2_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-3_S19_L003_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-3_S19_L003_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-3_S19_L003_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-3_S19_L003_R1_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-3_S19_L003_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-3_S19_L003_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-3_S19_L003_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-3_S19_L003_R2_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-4_S27_L004_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-4_S27_L004_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-4_S27_L004_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-4_S27_L004_R1_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-4_S27_L004_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-4_S27_L004_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-4_S27_L004_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-4_S27_L004_R2_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-5_S35_L005_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-5_S35_L005_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-5_S35_L005_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-5_S35_L005_R1_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-5_S35_L005_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-5_S35_L005_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-5_S35_L005_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-5_S35_L005_R2_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-6_S43_L006_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-6_S43_L006_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-6_S43_L006_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-6_S43_L006_R1_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-6_S43_L006_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-6_S43_L006_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-6_S43_L006_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-6_S43_L006_R2_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-7_S51_L007_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-7_S51_L007_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-7_S51_L007_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-7_S51_L007_R1_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-7_S51_L007_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-7_S51_L007_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-7_S51_L007_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-7_S51_L007_R2_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-8_S59_L008_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-8_S59_L008_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-8_S59_L008_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-8_S59_L008_R1_001_fastqc.html)

    - [Geoduck-ctenidia-RNA-8_S59_L008_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-8_S59_L008_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-ctenidia-RNA-8_S59_L008_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-ctenidia-RNA-8_S59_L008_R2_001_fastqc.html)

    - [Geoduck-gonad-RNA-1_S1_L001_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-1_S1_L001_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-1_S1_L001_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-1_S1_L001_R1_001_fastqc.html)

    - [Geoduck-gonad-RNA-1_S1_L001_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-1_S1_L001_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-1_S1_L001_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-1_S1_L001_R2_001_fastqc.html)

    - [Geoduck-gonad-RNA-2_S9_L002_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-2_S9_L002_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-2_S9_L002_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-2_S9_L002_R1_001_fastqc.html)

    - [Geoduck-gonad-RNA-2_S9_L002_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-2_S9_L002_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-2_S9_L002_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-2_S9_L002_R2_001_fastqc.html)

    - [Geoduck-gonad-RNA-3_S17_L003_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-3_S17_L003_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-3_S17_L003_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-3_S17_L003_R1_001_fastqc.html)

    - [Geoduck-gonad-RNA-3_S17_L003_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-3_S17_L003_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-3_S17_L003_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-3_S17_L003_R2_001_fastqc.html)

    - [Geoduck-gonad-RNA-4_S25_L004_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-4_S25_L004_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-4_S25_L004_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-4_S25_L004_R1_001_fastqc.html)

    - [Geoduck-gonad-RNA-4_S25_L004_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-4_S25_L004_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-4_S25_L004_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-4_S25_L004_R2_001_fastqc.html)

    - [Geoduck-gonad-RNA-5_S33_L005_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-5_S33_L005_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-5_S33_L005_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-5_S33_L005_R1_001_fastqc.html)

    - [Geoduck-gonad-RNA-5_S33_L005_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-5_S33_L005_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-5_S33_L005_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-5_S33_L005_R2_001_fastqc.html)

    - [Geoduck-gonad-RNA-6_S41_L006_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-6_S41_L006_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-6_S41_L006_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-6_S41_L006_R1_001_fastqc.html)

    - [Geoduck-gonad-RNA-6_S41_L006_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-6_S41_L006_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-6_S41_L006_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-6_S41_L006_R2_001_fastqc.html)

    - [Geoduck-gonad-RNA-7_S49_L007_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-7_S49_L007_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-7_S49_L007_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-7_S49_L007_R1_001_fastqc.html)

    - [Geoduck-gonad-RNA-7_S49_L007_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-7_S49_L007_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-7_S49_L007_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-7_S49_L007_R2_001_fastqc.html)

    - [Geoduck-gonad-RNA-8_S57_L008_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-8_S57_L008_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-8_S57_L008_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-8_S57_L008_R1_001_fastqc.html)

    - [Geoduck-gonad-RNA-8_S57_L008_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-8_S57_L008_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-gonad-RNA-8_S57_L008_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-gonad-RNA-8_S57_L008_R2_001_fastqc.html)

    - [Geoduck-heart-RNA-1_S2_L001_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-1_S2_L001_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-1_S2_L001_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-1_S2_L001_R1_001_fastqc.html)

    - [Geoduck-heart-RNA-1_S2_L001_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-1_S2_L001_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-1_S2_L001_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-1_S2_L001_R2_001_fastqc.html)

    - [Geoduck-heart-RNA-2_S10_L002_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-2_S10_L002_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-2_S10_L002_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-2_S10_L002_R1_001_fastqc.html)

    - [Geoduck-heart-RNA-2_S10_L002_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-2_S10_L002_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-2_S10_L002_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-2_S10_L002_R2_001_fastqc.html)

    - [Geoduck-heart-RNA-3_S18_L003_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-3_S18_L003_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-3_S18_L003_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-3_S18_L003_R1_001_fastqc.html)

    - [Geoduck-heart-RNA-3_S18_L003_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-3_S18_L003_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-3_S18_L003_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-3_S18_L003_R2_001_fastqc.html)

    - [Geoduck-heart-RNA-4_S26_L004_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-4_S26_L004_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-4_S26_L004_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-4_S26_L004_R1_001_fastqc.html)

    - [Geoduck-heart-RNA-4_S26_L004_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-4_S26_L004_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-4_S26_L004_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-4_S26_L004_R2_001_fastqc.html)

    - [Geoduck-heart-RNA-5_S34_L005_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-5_S34_L005_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-5_S34_L005_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-5_S34_L005_R1_001_fastqc.html)

    - [Geoduck-heart-RNA-5_S34_L005_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-5_S34_L005_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-5_S34_L005_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-5_S34_L005_R2_001_fastqc.html)

    - [Geoduck-heart-RNA-6_S42_L006_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-6_S42_L006_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-6_S42_L006_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-6_S42_L006_R1_001_fastqc.html)

    - [Geoduck-heart-RNA-6_S42_L006_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-6_S42_L006_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-6_S42_L006_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-6_S42_L006_R2_001_fastqc.html)

    - [Geoduck-heart-RNA-7_S50_L007_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-7_S50_L007_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-7_S50_L007_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-7_S50_L007_R1_001_fastqc.html)

    - [Geoduck-heart-RNA-7_S50_L007_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-7_S50_L007_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-7_S50_L007_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-7_S50_L007_R2_001_fastqc.html)

    - [Geoduck-heart-RNA-8_S58_L008_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-8_S58_L008_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-8_S58_L008_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-8_S58_L008_R1_001_fastqc.html)

    - [Geoduck-heart-RNA-8_S58_L008_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-8_S58_L008_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-heart-RNA-8_S58_L008_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-heart-RNA-8_S58_L008_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-1_S4_L001_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-1_S4_L001_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-1_S4_L001_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-1_S4_L001_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-1_S4_L001_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-1_S4_L001_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-1_S4_L001_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-1_S4_L001_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-2_S12_L002_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-2_S12_L002_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-2_S12_L002_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-2_S12_L002_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-2_S12_L002_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-2_S12_L002_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-2_S12_L002_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-2_S12_L002_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-3_S20_L003_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-3_S20_L003_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-3_S20_L003_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-3_S20_L003_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-3_S20_L003_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-3_S20_L003_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-3_S20_L003_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-3_S20_L003_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-4_S28_L004_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-4_S28_L004_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-4_S28_L004_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-4_S28_L004_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-4_S28_L004_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-4_S28_L004_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-4_S28_L004_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-4_S28_L004_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-5_S36_L005_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-5_S36_L005_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-5_S36_L005_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-5_S36_L005_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-5_S36_L005_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-5_S36_L005_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-5_S36_L005_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-5_S36_L005_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-6_S44_L006_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-6_S44_L006_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-6_S44_L006_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-6_S44_L006_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-6_S44_L006_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-6_S44_L006_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-6_S44_L006_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-6_S44_L006_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-7_S52_L007_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-7_S52_L007_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-7_S52_L007_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-7_S52_L007_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-7_S52_L007_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-7_S52_L007_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-7_S52_L007_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-7_S52_L007_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-8_S60_L008_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-8_S60_L008_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-8_S60_L008_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-8_S60_L008_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-8_S60_L008_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-8_S60_L008_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-115-8_S60_L008_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-8_S60_L008_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-1_S5_L001_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-1_S5_L001_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-1_S5_L001_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-1_S5_L001_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-1_S5_L001_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-1_S5_L001_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-1_S5_L001_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-1_S5_L001_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-2_S13_L002_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-2_S13_L002_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-2_S13_L002_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-2_S13_L002_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-2_S13_L002_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-2_S13_L002_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-2_S13_L002_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-2_S13_L002_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-3_S21_L003_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-3_S21_L003_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-3_S21_L003_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-3_S21_L003_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-3_S21_L003_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-3_S21_L003_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-3_S21_L003_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-3_S21_L003_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-4_S29_L004_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-4_S29_L004_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-4_S29_L004_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-4_S29_L004_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-4_S29_L004_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-4_S29_L004_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-4_S29_L004_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-4_S29_L004_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-5_S37_L005_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-5_S37_L005_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-5_S37_L005_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-5_S37_L005_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-5_S37_L005_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-5_S37_L005_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-5_S37_L005_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-5_S37_L005_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-6_S45_L006_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-6_S45_L006_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-6_S45_L006_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-6_S45_L006_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-6_S45_L006_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-6_S45_L006_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-6_S45_L006_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-6_S45_L006_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-7_S53_L007_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-7_S53_L007_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-7_S53_L007_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-7_S53_L007_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-7_S53_L007_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-7_S53_L007_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-7_S53_L007_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-7_S53_L007_R2_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-8_S61_L008_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-8_S61_L008_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-8_S61_L008_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-8_S61_L008_R1_001_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-8_S61_L008_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-8_S61_L008_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-OA-exposure-RNA-EPI-116-8_S61_L008_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-8_S61_L008_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-1_S6_L001_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-1_S6_L001_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-1_S6_L001_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-1_S6_L001_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-1_S6_L001_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-1_S6_L001_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-1_S6_L001_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-1_S6_L001_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-2_S14_L002_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-2_S14_L002_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-2_S14_L002_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-2_S14_L002_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-2_S14_L002_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-2_S14_L002_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-2_S14_L002_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-2_S14_L002_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-3_S22_L003_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-3_S22_L003_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-3_S22_L003_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-3_S22_L003_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-3_S22_L003_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-3_S22_L003_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-3_S22_L003_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-3_S22_L003_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-4_S30_L004_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-4_S30_L004_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-4_S30_L004_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-4_S30_L004_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-4_S30_L004_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-4_S30_L004_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-4_S30_L004_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-4_S30_L004_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-5_S38_L005_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-5_S38_L005_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-5_S38_L005_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-5_S38_L005_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-5_S38_L005_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-5_S38_L005_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-5_S38_L005_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-5_S38_L005_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-6_S46_L006_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-6_S46_L006_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-6_S46_L006_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-6_S46_L006_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-6_S46_L006_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-6_S46_L006_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-6_S46_L006_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-6_S46_L006_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-7_S54_L007_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-7_S54_L007_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-7_S54_L007_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-7_S54_L007_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-7_S54_L007_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-7_S54_L007_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-7_S54_L007_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-7_S54_L007_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-8_S62_L008_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-8_S62_L008_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-8_S62_L008_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-8_S62_L008_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-8_S62_L008_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-8_S62_L008_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-123-8_S62_L008_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-8_S62_L008_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-1_S7_L001_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-1_S7_L001_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-1_S7_L001_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-1_S7_L001_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-1_S7_L001_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-1_S7_L001_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-1_S7_L001_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-1_S7_L001_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-2_S15_L002_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-2_S15_L002_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-2_S15_L002_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-2_S15_L002_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-2_S15_L002_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-2_S15_L002_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-2_S15_L002_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-2_S15_L002_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-3_S23_L003_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-3_S23_L003_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-3_S23_L003_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-3_S23_L003_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-3_S23_L003_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-3_S23_L003_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-3_S23_L003_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-3_S23_L003_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-4_S31_L004_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-4_S31_L004_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-4_S31_L004_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-4_S31_L004_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-4_S31_L004_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-4_S31_L004_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-4_S31_L004_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-4_S31_L004_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-5_S39_L005_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-5_S39_L005_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-5_S39_L005_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-5_S39_L005_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-5_S39_L005_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-5_S39_L005_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-5_S39_L005_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-5_S39_L005_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-6_S47_L006_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-6_S47_L006_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-6_S47_L006_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-6_S47_L006_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-6_S47_L006_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-6_S47_L006_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-6_S47_L006_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-6_S47_L006_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-7_S55_L007_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-7_S55_L007_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-7_S55_L007_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-7_S55_L007_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-7_S55_L007_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-7_S55_L007_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-7_S55_L007_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-7_S55_L007_R2_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-8_S63_L008_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-8_S63_L008_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-8_S63_L008_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-8_S63_L008_R1_001_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-8_S63_L008_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-8_S63_L008_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-juvenile-ambient-exposure-RNA-EPI-124-8_S63_L008_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-8_S63_L008_R2_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-1_S8_L001_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-1_S8_L001_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-1_S8_L001_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-1_S8_L001_R1_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-1_S8_L001_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-1_S8_L001_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-1_S8_L001_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-1_S8_L001_R2_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-2_S16_L002_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-2_S16_L002_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-2_S16_L002_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-2_S16_L002_R1_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-2_S16_L002_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-2_S16_L002_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-2_S16_L002_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-2_S16_L002_R2_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-3_S24_L003_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-3_S24_L003_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-3_S24_L003_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-3_S24_L003_R1_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-3_S24_L003_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-3_S24_L003_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-3_S24_L003_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-3_S24_L003_R2_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-4_S32_L004_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-4_S32_L004_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-4_S32_L004_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-4_S32_L004_R1_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-4_S32_L004_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-4_S32_L004_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-4_S32_L004_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-4_S32_L004_R2_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-5_S40_L005_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-5_S40_L005_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-5_S40_L005_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-5_S40_L005_R1_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-5_S40_L005_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-5_S40_L005_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-5_S40_L005_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-5_S40_L005_R2_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-6_S48_L006_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-6_S48_L006_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-6_S48_L006_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-6_S48_L006_R1_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-6_S48_L006_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-6_S48_L006_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-6_S48_L006_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-6_S48_L006_R2_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-7_S56_L007_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-7_S56_L007_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-7_S56_L007_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-7_S56_L007_R1_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-7_S56_L007_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-7_S56_L007_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-7_S56_L007_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-7_S56_L007_R2_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-8_S64_L008_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-8_S64_L008_R1_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-8_S64_L008_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-8_S64_L008_R1_001_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-8_S64_L008_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-8_S64_L008_R2_001.fastp-trim.20220908_fastqc.html)

    - [Geoduck-larvae-day5-RNA-EPI-99-8_S64_L008_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Geoduck-larvae-day5-RNA-EPI-99-8_S64_L008_R2_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L001_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L001_R1_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L001_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L001_R1_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L001_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L001_R2_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L001_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L001_R2_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L002_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L002_R1_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L002_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L002_R1_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L002_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L002_R2_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L002_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L002_R2_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L001_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L001_R1_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L001_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L001_R1_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L001_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L001_R2_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L001_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L001_R2_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L002_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L002_R1_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L002_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L002_R1_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L002_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L002_R2_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L002_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L002_R2_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L001_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L001_R1_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L001_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L001_R1_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L001_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L001_R2_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L001_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L001_R2_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L002_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L002_R1_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L002_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L002_R1_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L002_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L002_R2_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L002_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L002_R2_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L001_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L001_R1_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L001_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L001_R1_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L001_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L001_R2_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L001_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L001_R2_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L002_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L002_R1_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L002_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L002_R1_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L002_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L002_R2_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L002_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L002_R2_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L001_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L001_R1_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L001_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L001_R1_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L001_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L001_R2_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L001_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L001_R2_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L002_R1_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L002_R1_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L002_R1_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L002_R1_001_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L002_R2_001.fastp-trim.20220908_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L002_R2_001.fastp-trim.20220908_fastqc.html)

    - [Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L002_R2_001_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L002_R2_001_fastqc.html)