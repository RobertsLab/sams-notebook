---
layout: post
title: Trimming - Ronits C.gigas Ploidy WGBS 10bp 5 and 3 Prime Ends Using fastp and MultiQC on Mox
date: '2020-12-02 16:19'
tags:
  - WGBS
  - BSseq
  - mox
  - fastp
  - multiqc
  - Crassostrea gigas
  - Pacific oyster
categories:
  - Miscellaneous
---
[Steven asked me to trim](https://github.com/RobertsLab/resources/issues/1039) (GitHub Issue) Ronit's WGBS sequencing data we [received on 20201110](https://robertslab.github.io/sams-notebook/2020/11/10/Data-Received-C.gigas-Ploidy-WGBS-from-Ronits-Project-via-ZymoResearch.html), according to [`Bismark`](https://github.com/FelixKrueger/Bismark) guidelines for [libraries made with the ZymoResearch Pico MethylSeq Kit](https://github.com/FelixKrueger/Bismark/blob/master/Docs/README.md#ix-notes-about-different-library-types-and-commercial-kits).

I trimmed the files using [`fastp`](https://github.com/OpenGene/fastp).

The trimming trims adapters and 10bp from _both_ the 5' and 3' ends of each read.

I [previously ran a trimming where I trimmed only from the 5' end](https://robertslab.github.io/sams-notebook/2020/11/30/Trimming-Ronits-C.gigas-Ploidy-WGBS-Using-fastp-and-MultiQC-on-Mox.html). Reading the [`Bismark`](https://github.com/FelixKrueger/Bismark) documentation more carefully, the documentation suggests that a user "should probably perform 3' trimming". So, I'm doing that here.

Job was run on Mox.

SBATCH script (GitHub):

- [20201202_cgig_fastp-10bp-5-3-prime_ronit-ploidy-wgbs.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20201202_cgig_fastp-10bp-5-3-prime_ronit-ploidy-wgbs.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20201202_cgig_fastp-10bp-5-3-prime_ronit-ploidy-wgbs
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201202_cgig_fastp-10bp-5-3-prime_ronit-ploidy-wgbs


### Fastp trimming of Ronit's ploidy WGBS.

### Trims adapters, 10bp from 5' and 3' ends of reads

### Trimming is performed according to recommendation for use with Bismark
### for libraries created using ZymoResearch Pico MethylSeq Kit:
### https://github.com/FelixKrueger/Bismark/blob/master/Docs/README.md#ix-notes-about-different-library-types-and-commercial-kits


### Expects input filenames to be in format: zr3534_3_R1.fq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=27

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5
raw_reads_dir=/gscratch/srlab/sam/data/C_gigas/wgbs/
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
"${raw_reads_dir}"zr3534*.fq.gz .

# Create arrays of fastq R1 files and sample names
for fastq in *R1.fq.gz
do
  fastq_array_R1+=("${fastq}")
	R1_names_array+=("$(echo "${fastq}" | awk 'BEGIN {FS = "[_.]"; OFS = "_"} {print $1, $2, $3}')")
done

# Create array of fastq R2 files
for fastq in *R2.fq.gz
do
  fastq_array_R2+=("${fastq}")
	R2_names_array+=("$(echo "${fastq}" | awk 'BEGIN {FS = "[_.]"; OFS = "_"} {print $1, $2, $3}')")
done


# Run fastp on files
# Trim 10bp from 5' from each read
# Adds JSON report output for downstream usage by MultiQC
for index in "${!fastq_array_R1[@]}"
do
  R1_sample_name=$(echo "${R1_names_array[index]}")
	R2_sample_name=$(echo "${R2_names_array[index]}")
	${fastp} \
	--in1 ${fastq_array_R1[index]} \
	--in2 ${fastq_array_R2[index]} \
	--detect_adapter_for_pe \
  --detect_adapter_for_pe \
  --trim_front1 10 \
  --trim_front2 10 \
  --trim_tail1 10 \
  --trim_tail2 10 \
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

  # Create list of fastq files used in analysis
  # Create MD5 checksum for reference
  echo "${fastq_array_R1[index]}" >> input.fastq.list.txt
  echo "${fastq_array_R2[index]}" >> input.fastq.list.txt
  md5sum "${fastq_array_R1[index]}" >> ${fastq_checksums}
  md5sum "${fastq_array_R2[index]}" >> ${fastq_checksums}

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
  # Handle samtools help menus
  if [[ "${program}" == "samtools_index" ]] \
  || [[ "${program}" == "samtools_sort" ]] \
  || [[ "${program}" == "samtools_view" ]]
  then
    ${programs_array[$program]}
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

Runtime was actually faster than just the 10bp 5' trimming from the other day; just over 2hrs:

![fastp runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201202_cgig_fastp-10bp-5-3-prime_ronit-ploidy-wgbs_runtime.png?raw=true)

NOTE: The report files ([`MultiQC`](https://multiqc.info/) and [`fastp`](https://github.com/OpenGene/fastp)) all suffer from a naming error, but do contain data for both read 1 (R1) and read 2 (R2).

Output folder:

- [20201202_cgig_fastp-10bp-5-3-prime_ronit-ploidy-wgbs/](https://gannet.fish.washington.edu/Atumefaciens/20201202_cgig_fastp-10bp-5-3-prime_ronit-ploidy-wgbs/)

- [`MultiQC`](https://multiqc.info/) report (HTML; open with web browser):

  - [20201202_cgig_fastp-10bp-5-3-prime_ronit-ploidy-wgbs/multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20201202_cgig_fastp-10bp-5-3-prime_ronit-ploidy-wgbs/multiqc_report.html)

- [[`fastp`](https://github.com/OpenGene/fastp)] Reports (HTML; open in web browser):

  - [zr3534_10_R1.fastp-trim.20201202.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_10_R1.fastp-trim.20201202.report.html)

  - [zr3534_1_R1.fastp-trim.20201202.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_1_R1.fastp-trim.20201202.report.html)

  - [zr3534_2_R1.fastp-trim.20201202.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_2_R1.fastp-trim.20201202.report.html)

  - [zr3534_3_R1.fastp-trim.20201202.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_3_R1.fastp-trim.20201202.report.html)

  - [zr3534_4_R1.fastp-trim.20201202.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_4_R1.fastp-trim.20201202.report.html)

  - [zr3534_5_R1.fastp-trim.20201202.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_5_R1.fastp-trim.20201202.report.html)

  - [zr3534_6_R1.fastp-trim.20201202.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_6_R1.fastp-trim.20201202.report.html)

  - [zr3534_7_R1.fastp-trim.20201202.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_7_R1.fastp-trim.20201202.report.html)

  - [zr3534_8_R1.fastp-trim.20201202.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_8_R1.fastp-trim.20201202.report.html)

  - [zr3534_9_R1.fastp-trim.20201202.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_9_R1.fastp-trim.20201202.report.html)

- Trimmed FastQ files (gzipped):

  - [zr3534_10_R1.fastp-trim.20201202.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_10_R1.fastp-trim.20201202.fq.gz) (4.0G)

    - MD5: `a16658d4c034361963a6def0ff266189`

  - [zr3534_10_R2.fastp-trim.20201202.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_10_R2.fastp-trim.20201202.fq.gz) (4.0G)

    - MD5: `8a994705dada067c8440aba9fe9d23f4`

  - [zr3534_1_R1.fastp-trim.20201202.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_1_R1.fastp-trim.20201202.fq.gz) (3.9G)

    - MD5: `9c0a247865d2c4f508f285c7835c09e4`

  - [zr3534_1_R2.fastp-trim.20201202.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_1_R2.fastp-trim.20201202.fq.gz) (4.0G)

    - MD5: `aa4b80519c65404867c91aa037bb7aa0`

  - [zr3534_2_R1.fastp-trim.20201202.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_2_R1.fastp-trim.20201202.fq.gz) (3.9G)

    - MD5: `c0bb9cf83cec7d2e52c1e43300da6d4e`

  - [zr3534_2_R2.fastp-trim.20201202.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_2_R2.fastp-trim.20201202.fq.gz) (4.0G)

    - MD5: `4208221b6ad68f1f75c031a4b376a68d`
