---
layout: post
title: Trimming/FastQC/MultiQC - C.bairdi RNAseq FastQ with fastp on Mox
date: '2019-12-18 09:51'
tags:
  - fastp
  - fastqc
  - multiqc
  - Chionoecetes bairdi
  - tanner crab
  - mox
categories:
  - Tanner Crab RNAseq
---
Grace/Steven asked me to generate a _de novo_ transcriptome assembly of our current _C.bairdi_ RNAseq data in [this GitHub issue](https://github.com/RobertsLab/resources/issues/808). As part of that, I needed to quality trim the data first. Although I could automate this as part of the transcriptome assembly (Trinity has Trimmomatic built-in), I would be unable to view the post-trimming results until after the assembly was completed. So, I opted to do the trimming step separately, to evaluate the data prior to assembly.

Trimming was performed using [fastp (v0.20.0)](https://github.com/OpenGene/fastp) on Mox.

I used the following Bash script to initiate file transfer to Mox and then call the SBATCH script for trimming:


- [20191218_cbai_RNAseq_rsync.sh](https://gannet.fish.washington.edu/Atumefaciens/20191218_cbai_fastp_RNAseq_trimming/20191218_cbai_RNAseq_rsync.sh)

```shell
#!/bin/bash

## Script to transfer C.bairdi RNAseq files and then run SBATCH script for fastp trimming.

# Exit script if any command fails
set -e

# Transfer files
rsync -av --progress owl:/volume1/web/nightingales/C_bairdi/*.gz .

# Run SBATCH script to begin fastp trimming
sbatch 20191218_cbai_fastp_RNAseq_trimming.sh

```


SBATCH script (GitHub):

- [20191218_cbai_fastp_RNAseq_trimming.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20191218_cbai_fastp_RNAseq_trimming.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=pgen_fastp_trimming_EPI
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20191218_cbai_fastp_RNAseq_trimming


### C.bairdi RNAseq trimming using fastp.

# This script is called by 20191218_cbai_RNAseq_rsync.sh. That script transfers the FastQ files
# to the working directory from: https://owl.fish.washington.edu/nightingales/C_bairdi/

# Exit script if any command fails
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

# Set number of CPUs to use
threads=27

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5

# Paths to programs
fastp=/gscratch/srlab/programs/fastp-0.20.0/fastp

## Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()
R1_names_array=()
R2_names_array=()

# Create array of fastq R1 files
for fastq in *R1*.gz
do
  fastq_array_R1+=("${fastq}")
done

# Create array of fastq R2 files
for fastq in *R2*.gz
do
  fastq_array_R2+=("${fastq}")
done


# Create array of sample names
## Uses awk to parse out sample name from filename
for R1_fastq in *R1*.gz
do
  R1_names_array+=($(echo "${R1_fastq}" | awk -F"." '{print $1}'))
done

# Create array of sample names
## Uses awk to parse out sample name from filename
for R2_fastq in *R2*.gz
do
  R2_names_array+=($(echo "${R2_fastq}" | awk -F"." '{print $1}'))
done

# Create list of fastq files used in analysis
for fastq in *.gz
do
  echo "${fastq}" >> fastq.list.txt
done

# Run fastp on files
for index in "${!fastq_array_R1[@]}"
do
	timestamp=$(date +%Y%m%d%M%S)
  R1_sample_name=$(echo "${R1_names_array[index]}")
	R2_sample_name=$(echo "${R2_names_array[index]}")
	${fastp} \
	--in1 "${fastq_array_R1[index]}" \
	--in2 "${fastq_array_R2[index]}" \
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
	rm "${fastq_array_R1[index]}" "${fastq_array_R2[index]}"
done
```


---

#### RESULTS

Took ~40 minutes to complete:

![screencap of fastp runtime on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20191218_cbai_fastp_RNAseq_trimming_runtime.png?raw=true)

Output folder:

- [20191218_cbai_fastp_RNAseq_trimming](https://gannet.fish.washington.edu/Atumefaciens/20191218_cbai_fastp_RNAseq_trimming)


MultiQC Report (HTML):

- [20191218_cbai_fastp_RNAseq_trimming/multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20191218_cbai_fastp_RNAseq_trimming/multiqc_report.html)


Overall, the data looks fine. There's a high degree of sequence duplication, but this is expected when dealing with RNAseq libraries.

One really nice aspect of using [fastp](https://github.com/OpenGene/fastp) is that it generates HTML reports for each file trimmed, and the reports include before and after data/plots. There's almost no need for FastQC. With that said, MultiQC only doesn't recognize the [fastp](https://github.com/OpenGene/fastp) reports, but _does_ recognize the FastQC reports. Have the aggregated report of all files that MultiQC is _very_ nice for looking at all the data at one time.


Will proceed with Trinity _de novo_ assembly.
