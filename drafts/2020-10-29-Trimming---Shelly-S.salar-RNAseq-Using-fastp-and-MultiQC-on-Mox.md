---
layout: post
title: Trimming - Shelly S.salar RNAseq Using fastp and MultiQC on Mox
date: '2020-10-29 10:11'
tags:
  - Salmo salar
  - fastp
  - Atlantic slamon
  - RNAseq
  - trimming
  - mox
  - MultiQC
categories:
  - Miscellaneous
---
Shelly asked that I trim, align to a genome, and perform transcriptome alignment counts [in this GitHub issue](https://github.com/RobertsLab/resources/issues/1016) with some _Salmo salar_ RNAseq data she had and, using a subset of the NCBI _Salmo salar_ RefSeq genome, [GCF_000233375.1](https://www.ncbi.nlm.nih.gov/assembly/GCF_000233375.1/). She created a subset of this genome using only sequences designated as "chromosomes." A link to the FastA (and a link to her notebook on creating this file) are in that GitHub issue link above. The transcriptome she has provided has _not_ been subsetted in a similar fashion; maybe I'll do that prior to alignment.

Here, I performed adapter trimming using [`fastp`](https://github.com/OpenGene/fastp). I opt for this trimmer as:

- It's fast (duh).

- It automatically generates trimming reports similar to FastQC without the need for FastQC.

- The results can be read by MultiQC.

I'll run `fastp`, followed by [MultiQC](https://multiqc.info/) on Mox.

SBATCH script (GitHub):

- [20201029_ssal_RNAseq_fastp_trimming.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20201029_ssal_RNAseq_fastp_trimming.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=202001029_ssal_RNAseq_fastp_trimming
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201029_ssal_RNAseq_fastp_trimming


### S.salar RNAseq trimming using fastp, and MultiQC.

### FastQ files provided by Shelly Trigg. See this GitHub issue for deets:
### https://github.com/RobertsLab/resources/issues/1016#issuecomment-718812876

### Expects input FastQ files to be in format: Pool26_16_P_31_1.fastq.gz



###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=27

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5
raw_reads_dir=/gscratch/srlab/sam/data/S_salar/RNAseq/
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
for fastq in *_1.fastq.gz
do
  fastq_array_R1+=("${fastq}")
	R1_names_array+=("$(echo "${fastq}" | awk 'BEGIN {FS = "[._]";OFS = "_"} {print $1, $2, $3, $4, $5}')")
done

# Create array of fastq R2 files
for fastq in *_2.fastq.gz
do
  fastq_array_R2+=("${fastq}")
	R2_names_array+=("$(echo "${fastq}" |awk 'BEGIN {FS = "[._]";OFS = "_"} {print $1, $2, $3, $4, $5}')")
done

# Create list of fastq files used in analysis
# Create MD5 checksum for reference
for fastq in *.gz
do
  echo "${fastq}" >> input.fastq.list.txt
	md5sum >> ${fastq_checksums}
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
	rm "${fastq_array_R1[index]}" "${fastq_array_R2[index]}"
done

# Run MultiQC
${multiqc} .



# Capture program options
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${program}: "
	echo ""
	${programs_array[$program]} -h
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true

  # If MultiQC is in programs_array, copy the config file to this directory.
  if [[ "${program}" == "multiqc" ]]; then
  	cp --preserve ~/.multiqc_config.yaml "${timestamp}_multiqc_config.yaml"
  fi
done


# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log

# Remove raw FastQ file
while read -r line
do
	echo ""
	echo "Removing ${line}"
	rm "${line}"
done < input.fastq.list.txt
```

---

#### RESULTS

Cumulative runtime for `fastp` and `MultiQC` was very fast; ~18mins:

![Cumulative runtime for `fastp` and `MultiQC`](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201029_ssal_RNAseq_fastp_trimming_runtime.png?raw=true)

NOTE: Despite the "FAILED" indication, the script ran to completion. The last command in the script is a redundant file removal step, which triggered the script "failure". Left the command in the SBATCH script above for reproducibility.

Output folder:

- [20201029_ssal_RNAseq_fastp_trimming/](https://gannet.fish.washington.edu/Atumefaciens/20201029_ssal_RNAseq_fastp_trimming/)

MultiQC Report (HTML; can open link in browser):

- NOTE: Sample names listed in the report are inaccurate and reflect a filename parsing issue, however, the data/results are fine.

- [multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20201029_ssal_RNAseq_fastp_trimming/multiqc_report.html)

##### Trimmed FastQ files and corresponding `fastp` HTML reportj:

- NOTE: The same naming issue applies here for the `fastp` reports. The report name is only named after the first of the two samples, but the report encompasses the two pairs of FastQ files.

- [Pool26_16_P_31_1.fastp-trim.20201029.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201029_ssal_RNAseq_fastp_trimming/Pool26_16_P_31_1.fastp-trim.20201029.fq.gz)

- [Pool26_16_P_31_2.fastp-trim.20201029.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201029_ssal_RNAseq_fastp_trimming/Pool26_16_P_31_2.fastp-trim.20201029.fq.gz)

  - [Pool26_16_P_31_1.fastp-trim.20201029.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201029_ssal_RNAseq_fastp_trimming/Pool26_16_P_31_1.fastp-trim.20201029.report.html)

- [Pool26_8_P_31_1.fastp-trim.20201029.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201029_ssal_RNAseq_fastp_trimming/Pool26_8_P_31_1.fastp-trim.20201029.fq.gz)

- [Pool26_8_P_31_2.fastp-trim.20201029.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201029_ssal_RNAseq_fastp_trimming/Pool26_8_P_31_2.fastp-trim.20201029.fq.gz)

  - [Pool26_8_P_31_1.fastp-trim.20201029.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201029_ssal_RNAseq_fastp_trimming/Pool26_8_P_31_1.fastp-trim.20201029.report.html)

- [Pool32_16_P_31_1.fastp-trim.20201029.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201029_ssal_RNAseq_fastp_trimming/Pool32_16_P_31_1.fastp-trim.20201029.fq.gz)

- [Pool32_16_P_31_2.fastp-trim.20201029.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201029_ssal_RNAseq_fastp_trimming/Pool32_16_P_31_2.fastp-trim.20201029.fq.gz)

  - [Pool32_16_P_31_1.fastp-trim.20201029.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201029_ssal_RNAseq_fastp_trimming/Pool32_16_P_31_1.fastp-trim.20201029.report.html)

- [Pool32_8_P_31_1.fastp-trim.20201029.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201029_ssal_RNAseq_fastp_trimming/Pool32_8_P_31_1.fastp-trim.20201029.fq.gz)

- [Pool32_8_P_31_2.fastp-trim.20201029.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201029_ssal_RNAseq_fastp_trimming/Pool32_8_P_31_2.fastp-trim.20201029.fq.gz)

  - [Pool32_8_P_31_1.fastp-trim.20201029.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201029_ssal_RNAseq_fastp_trimming/Pool32_8_P_31_1.fastp-trim.20201029.report.html)
