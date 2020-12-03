---
layout: post
title: Trimming - Ronits C.gigas Ploidy WGBS Using fastp and MultiQC on Mox
date: '2020-11-30 05:43'
tags:
  - fastp
  - multiqc
  - Crassostrea gigas
  - Pacific oyster
  - wgbs
  - mox
  - trimming
categories:
  - Miscellaneous
---
[Steven asked me to trim](https://github.com/RobertsLab/resources/issues/1039) (GitHub Issue) Ronit's WGBS sequencing data we [received on 20201110](https://robertslab.github.io/sams-notebook/2020/11/10/Data-Received-C.gigas-Ploidy-WGBS-from-Ronits-Project-via-ZymoResearch.html), according to [`Bismark`](https://github.com/FelixKrueger/Bismark) guidelines for [libraries made with the ZymoResearch Pico MethylSeq Kit](https://github.com/FelixKrueger/Bismark/blob/master/Docs/README.md#ix-notes-about-different-library-types-and-commercial-kits).

I trimmed the files using [`fastp`](https://github.com/OpenGene/fastp).

The trimming trims adapters and 10bp from the 5' ends of each read.

Job was run on Mox.

SBATCH script (GitHub):

- [20201130_cgig_fastp_ronit-ploidy-wgbs.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20201130_cgig_fastp_ronit-ploidy-wgbs.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20201130_cgig_fastp_ronit-ploidy-wgbs
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201130_cgig_fastp_ronit-ploidy-wgbs


### Fastp trimming of Ronit's ploidy WGBS.

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

A little under 2.5hrs to run:

![fastp runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201130_cgig_fastp_ronit-ploidy-wgbs_runtime.png?raw=true)

NOTE: The report files ([`MultiQC`](https://multiqc.info/) and [`fastp`](https://github.com/OpenGene/fastp)) all suffer from a naming error, but do contain data for both read 1 (R1) and read 2 (R2).

Output folder:

- [20201130_cgig_fastp_ronit-ploidy-wgbs/](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/)

  - [`MultiQC`](https://multiqc.info/) report (HTML; open with web browser):

    - [20201130_cgig_fastp_ronit-ploidy-wgbs/multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/multiqc_report.html)

  - [[`fastp`](https://github.com/OpenGene/fastp)] Reports (HTML; open in web browser):

    - [zr3534_10_R1.fastp-trim.20201130.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_10_R1.fastp-trim.20201130.report.html)

    - [zr3534_1_R1.fastp-trim.20201130.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_1_R1.fastp-trim.20201130.report.html)

    - [zr3534_2_R1.fastp-trim.20201130.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_2_R1.fastp-trim.20201130.report.html)

    - [zr3534_3_R1.fastp-trim.20201130.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_3_R1.fastp-trim.20201130.report.html)

    - [zr3534_4_R1.fastp-trim.20201130.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_4_R1.fastp-trim.20201130.report.html)

    - [zr3534_5_R1.fastp-trim.20201130.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_5_R1.fastp-trim.20201130.report.html)

    - [zr3534_6_R1.fastp-trim.20201130.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_6_R1.fastp-trim.20201130.report.html)

    - [zr3534_7_R1.fastp-trim.20201130.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_7_R1.fastp-trim.20201130.report.html)

    - [zr3534_8_R1.fastp-trim.20201130.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_8_R1.fastp-trim.20201130.report.html)

    - [zr3534_9_R1.fastp-trim.20201130.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_9_R1.fastp-trim.20201130.report.html)

  - Trimmed FastQ files (gzipped):

    - [zr3534_10_R1.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_10_R1.fastp-trim.20201130.fq.gz) (4.2G)

      - MD5: `7324282409549a013c4b7b2a5a6a14a6`

    - [zr3534_10_R2.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_10_R2.fastp-trim.20201130.fq.gz) (4.3G)

      - MD5: `9fb1357e0af5e071c0dfe545499cccb7`

    - [zr3534_1_R1.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_1_R1.fastp-trim.20201130.fq.gz) (4.2G)

      - MD5: `33a32d98e98189f4acf068c7a76b86e0`

    - [zr3534_1_R2.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_1_R2.fastp-trim.20201130.fq.gz) (4.2G)

      - MD5: `e979a919090cf463694ddbca7d016f5e`

    - [zr3534_2_R1.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_2_R1.fastp-trim.20201130.fq.gz) (4.1G)

      - MD5: `111d3d7c516c15a7d6915761bffd0260`

    - [zr3534_2_R2.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_2_R2.fastp-trim.20201130.fq.gz) (4.2G)

      - MD5: `a2de2f420e8d580dcd419386adc2fca9`

    - [zr3534_3_R1.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_3_R1.fastp-trim.20201130.fq.gz) (4.3G)

      - MD5: `99cbaa5703cb44e2fb71c0793482ca39`

    - [zr3534_3_R2.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_3_R2.fastp-trim.20201130.fq.gz) (4.4G)

      - MD5: `91070b1e5f083430a9101e4874b6f72b`

    - [zr3534_4_R1.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_4_R1.fastp-trim.20201130.fq.gz) (4.2G)

      - MD5: `c5ff85f06b374f8488f85af877e8ab33`

    - [zr3534_4_R2.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_4_R2.fastp-trim.20201130.fq.gz) (4.1G)

      - MD5: `1eb69d729f3511ab28a0bacc223623dd`

    - [zr3534_5_R1.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_5_R1.fastp-trim.20201130.fq.gz) (4.5G)

      - MD5: `abfa3ceeddab59d82c9ed5734a6e83a5`

    - [zr3534_5_R2.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_5_R2.fastp-trim.20201130.fq.gz) (4.7G)

      - MD5: `846a177f02f08713186537ebd8101126`

    - [zr3534_6_R1.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_6_R1.fastp-trim.20201130.fq.gz) (4.1G)

      - MD5: `1cc04bf49ac933c18936ebfa8b1e30d5`

    - [zr3534_6_R2.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_6_R2.fastp-trim.20201130.fq.gz) (4.2G)

      - MD5: `1d287dfcdf57d28db4b1307aded2b592`

    - [zr3534_7_R1.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_7_R1.fastp-trim.20201130.fq.gz) (3.7G)

      - MD5: `fd3ed000d01b71e3e85277f27e9a8df4`

    - [zr3534_7_R2.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_7_R2.fastp-trim.20201130.fq.gz) (3.7G)

      - MD5: `f9aa2a37729b00c3789e29a742030cdb`

    - [zr3534_8_R1.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_8_R1.fastp-trim.20201130.fq.gz) (5.3G)

      - MD5: `a75b297f5d0348c543e18e2b0e5bc460`

    - [zr3534_8_R2.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_8_R2.fastp-trim.20201130.fq.gz) (4.9G)

      - MD5: `b4f5ec54b07285f11a7010bd1ec1e5f1`

    - [zr3534_9_R1.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_9_R1.fastp-trim.20201130.fq.gz) (4.0G)

      - MD5: `2e05bbd9c4b2b1b5e4f6f07c8a210bd6`

    - [zr3534_9_R2.fastp-trim.20201130.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201130_cgig_fastp_ronit-ploidy-wgbs/zr3534_9_R2.fastp-trim.20201130.fq.gz) (4.1G)

      - MD5: `4a9a112c87f49f32ae1b8e10841e0a50`
