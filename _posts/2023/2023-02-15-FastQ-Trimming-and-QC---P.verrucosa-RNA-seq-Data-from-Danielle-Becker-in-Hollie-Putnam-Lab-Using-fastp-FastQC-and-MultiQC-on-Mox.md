---
layout: post
title: FastQ Trimming and QC - P.verrucosa RNA-seq Data from Danielle Becker in Hollie Putnam Lab Using fastp FastQC and MultiQC on Mox
date: '2023-02-15 12:09'
tags: 
  - RNAseq
  - fastp
  - FastQC
  - MultiQC
  - mox
  - Pocillopora verrucosa
categories: 
  - E5
---
After receiving the _P.verrucosa_ RNA-seq data from Danielle Becker (Hollie Putnam's Lab, Univ. of Rhode Island), I noticed that [the trimmed reads](https://gannet.fish.washington.edu/Atumefaciens/hputnam-Becker_E5/Becker_RNASeq/data/trimmed/) didn't appear to actually be trimmed. There was still adapter contamination (solely in R2 reads - suggesting the `detect_adapter_for_pe` option had been omitted from the `fastp` command?), but the reads had an average read length of 150bp - _except_ when looking at the adapter content report!!??.

![Screencap of FastQC Adapter content report for trimmed sample C17_R2_001.fastq.gz. Plot shows read lengths of 150bp, despite trimming. Additionally, shows "bumpy" stuff in first 20bp of all reads.](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20230215-pver-fastqc-fastp-multiqc-E5-RNAseq-previous_fastqc-01.png?raw=true)

![Screencap of FastQC Per base sequence content report for trimmed sample C17_R2_001.fastq.gz. Plot shows residual adapter content, and, inexplicalbly, shows read lengths of <150bp, despite what's reported in all other length-based reports in the FastQC output!](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20230215-pver-fastqc-fastp-multiqc-E5-RNAseq-previous_fastqc-02.png?raw=true)



If they had been trimmed, then the average read length should be shorter than 150bp... Oddly, I experienced this [with other coral sequencing data from the Putnam Lab back in January](https://robertslab.github.io/sams-notebook/2023/01/13/SRA-Data-Coral-SRA-BioProject-PRJNA744403-Download-and-QC.html).

So, with all of this info, I decided to trim the raw FastQs using [`fastp`](https://github.com/OpenGene/fastp), and perform a 20bp 5' end hard trim to all reads like I did [with the other coral sequencing data from the Putnam Lab back in January](https://robertslab.github.io/sams-notebook/2023/01/13/SRA-Data-Coral-SRA-BioProject-PRJNA744403-Download-and-QC.html).

Job was run on Mox using [`fastp`](https://github.com/OpenGene/fastp), [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/), and [`MultiQC`](https://multiqc.info/).

SBATCH script (GitHub):

- [20230215-pver-fastqc-fastp-multiqc-E5-RNAseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20230215-pver-fastqc-fastp-multiqc-E5-RNAseq.sh)


```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20230215-pver-fastqc-fastp-multiqc-E5-RNAseq
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=5-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230215-pver-fastqc-fastp-multiqc-E5-RNAseq

### FastQC and fastp trimming E5 coral project P.verrucosa RNA-seq data from Danielle Becker.

### fastp expects input FastQ files to be in format: *R[12]_001.fastq.gz
### E.g. C17_R1_001.fastq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set FastQ filename patterns
fastq_pattern='*.fastq.gz'
R1_fastq_pattern='*R1_001.fastq.gz'
R2_fastq_pattern='*R2_001.fastq.gz'

# Set number of CPUs to use
threads=40

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5
fastq_checksums=input_fastq_checksums.md5

# FastQC output directory
output_dir=$(pwd)

# Data directories
reads_dir=/gscratch/srlab/sam/data/hputnam-Becker_E5/Becker_RNASeq/data/raw/


## Inititalize arrays
raw_fastqs_array=()
R1_names_array=()
R2_names_array=()

# Paths to programs
fastp=/gscratch/srlab/programs/fastp.0.23.1
fastqc=/gscratch/srlab/programs/fastqc_v0.11.9/fastqc
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc

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

  # Use parameter substitution to remove all text up to and including first "_" from
  # right side of string.
  R1_names_array+=("${fastq%_*}")
done

# Create array of fastq R2 files
# Do NOT quote R2_fastq_pattern variable
for fastq in ${R2_fastq_pattern}
do
  fastq_array_R2+=("${fastq}")

  # Use parameter substitution to remove all text up to and including first "_" from
  # right side of string.
  R2_names_array+=("${fastq%_*}")
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
# Adds JSON report output for downstream usage by MultiQC
# Trims 20bp from 5' end of all reads
# Trims poly G, if present
# Uses parameter substitution (e.g. ${R1_sample_name%%_*})to rm the _R[12] for report names.
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
  --trim_poly_g \
  --trim_front1 20 \
  --trim_front2 20 \
  --thread ${threads} \
  --html "${R1_sample_name%%_*}".fastp-trim."${timestamp}".report.html \
  --json "${R1_sample_name%%_*}".fastp-trim."${timestamp}".report.json \
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

Runtime was Just under two hours:

![Screencap showing runtime of 1 hour 48 minutes and 29 seconds for trimming and QC on Mox for Danielle Becker RNA-seq data](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20230215-pver-fastqc-fastp-multiqc-E5-RNAseq_runtime.png?raw=true)


Output folder:

- [20230215-pver-fastqc-fastp-multiqc-E5-RNAseq/](https://gannet.fish.washington.edu/Atumefaciens/20230215-pver-fastqc-fastp-multiqc-E5-RNAseq/)

    - #### Trimmed FastQs (FastQ)

      - All trimmed FastQs follow this pattern: `*fastp-trim.20230215.fq.gz`

    - #### Trimmed FastQ MD5 checksums (text)

      - [20230215-pver-fastqc-fastp-multiqc-E5-RNAseq/trimmed_fastq_checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20230215-pver-fastqc-fastp-multiqc-E5-RNAseq/trimmed_fastq_checksums.md5)

    - #### MultiQC Report (HTML)

      - [20230215-pver-fastqc-fastp-multiqc-E5-RNAseq/multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20230215-pver-fastqc-fastp-multiqc-E5-RNAseq/multiqc_report.html)

      - NOTE: The report is a bit confusing due to the fact that it has summarized the follwing in a single report:
      
        - _raw_ (e.g. `C17_R[12]_001`)
        - _trimmed_ (e.g. `C17_R[12]`)
        - _fastp_ (e.g. `C17`)

Okay, the trimmed FastQs look better - no adapter contamination in R1 or R2 reads, and no "bumpy stuff" at 5' ends of reads. Plus, average read length is 130bp, reflecting the trimming that was supposed to take place. Next steps will be to align the trimmed reads to the _P.verrucosa_ genomes and the endosymbiont genome(s) in order to seperate reads matching to each genome.