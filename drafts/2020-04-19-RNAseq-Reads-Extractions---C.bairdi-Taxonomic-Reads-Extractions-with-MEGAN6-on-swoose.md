---
layout: post
title: RNAseq Reads Extractions - C.bairdi Taxonomic Reads Extractions with MEGAN6 on swoose
date: '2020-04-19 12:10'
tags:
  - Tanner crab
  - MEGAN6
  - taxonomy
  - swoose
  - Jupyter
  - Hematodinium
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
After [receiving our final set of RNAseq data from NWGSC earlier today](https://robertslab.github.io/sams-notebook/2020/04/13/Data-Received-C.bairdi-RNAseq-from-NWGSC.html), I need to trim and check trimmed reads with FastQC/MultiQC.

`fastp` trimming was run on Mox, followed by MultiQC.

FastQC on trimmed reads were run Mox, followed by MultiQC.

SBATCH script (GitHub):

- [20200414_cbai_RNAseq_fastp_trimming.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200414_cbai_RNAseq_fastp_trimming.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_fastp_trimming_RNAseq
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200414_cbai_RNAseq_fastp_trimming


### C.bairdi RNAseq trimming using fastp.

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
raw_reads_dir=/gscratch/srlab/sam/data/C_bairdi/RNAseq/

# Paths to programs
fastp=/gscratch/srlab/programs/fastp-0.20.0/fastp
fastqc=/gscratch/srlab/programs/fastqc_v0.11.8/fastqc
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc

## Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()
programs_array=()
R1_names_array=()
R2_names_array=()

# Programs array
programs_array=("${fastp}" "${multiqc}" "${fastqc}")

# Capture program options
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${programs_array[program]}: "
	echo ""
	${programs_array[program]} -h
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true
done

# Sync raw FastQ files to working directory
rsync --archive --verbose \
"${raw_reads_dir}"[3][8]*.fastq.gz .

# Sync checkums file
rsync --archive --verbose \
"${raw_reads_dir}"20200413_cbai_checkums.md5 .

# Check md5 checksums
md5sum --check 20200413_cbai_checkums.md5

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

	# Run FastQC
	${fastqc} --threads ${threads} \
	"${R1_sample_name}".fastp-trim."${timestamp}".fq.gz \
	"${R2_sample_name}".fastp-trim."${timestamp}".fq.gz

	# Remove original FastQ files
	rm "${fastq_array_R1[index]}" "${fastq_array_R2[index]}"
done



# Run MultiQC
${multiqc} .
```



---

#### RESULTS

Run time was just under 31 mins:

![fastp runtime screencap](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200414_cbai_RNAseq_fastp_trimming_runtime.png?raw=true)



Output folder:

- [20200414_cbai_RNAseq_fastp_trimming/](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_RNAseq_fastp_trimming/)

MultiQC report (HTML):

- Contains summary data for both fastp and FastQC

- [20200414_cbai_RNAseq_fastp_trimming/multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_RNAseq_fastp_trimming/multiqc_report.html)

Individual fastp reports are also available (HTML). An example is below.

https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_RNAseq_fastp_trimming/380820_S1_L001_R1_001.fastp-trim.202004143431.report.html
