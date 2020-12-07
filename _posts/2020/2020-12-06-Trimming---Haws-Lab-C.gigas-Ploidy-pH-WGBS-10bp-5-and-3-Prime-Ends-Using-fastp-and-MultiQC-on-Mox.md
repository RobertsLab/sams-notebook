---
layout: post
title: Trimming - Haws Lab C.gigas Ploidy pH WGBS 10bp 5 and 3 Prime Ends Using fastp and MultiQC on Mox
date: '2020-12-06 20:58'
tags:
  - haws
  - mox
  - wgbs
  - ploidy
  - Crassostrea gigas
  - Pacific oyster
  - fastp
  - multiqc
categories:
  - Miscellaneous
---
Making the assumption that [the 24 _C.gigas_ ploidy pH WGBS data we receved 20201205](https://robertslab.github.io/sams-notebook/2020/12/05/Data-Received-C.gigas-Diploid-Triploid-pH-Treatments-Ctenidia-WGBS-from-ZymoResearch.html) will be analyzed using [`Bismark`](https://github.com/FelixKrueger/Bismark), I decided to go ahead and trim the files according to [`Bismark`](https://github.com/FelixKrueger/Bismark) guidelines for [libraries made with the ZymoResearch Pico MethylSeq Kit](https://github.com/FelixKrueger/Bismark/blob/master/Docs/README.md#ix-notes-about-different-library-types-and-commercial-kits).

I trimmed the files using [`fastp`](https://github.com/OpenGene/fastp).

The trimming trims adapters and 10bp from _both_ the 5' and 3' ends of each read. The [`Bismark`](https://github.com/FelixKrueger/Bismark) guidelines suggest that the user "probably should" trim in this fashion (as opposed to just trimming 10bp from the 5' end).

The job was run on Mox.

SBATCH script (GitHub):

- [20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs


### Fastp trimming of Haw's Lab ploidy pH WGBS.

### Trims adapters, 10bp from 5' and 3' ends of reads

### Trimming is performed according to recommendation for use with Bismark
### for libraries created using ZymoResearch Pico MethylSeq Kit:
### https://github.com/FelixKrueger/Bismark/blob/master/Docs/README.md#ix-notes-about-different-library-types-and-commercial-kits


### Expects input filenames to be in format: zr3644_3_R1.fq.gz


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
"${raw_reads_dir}"zr3644*.fq.gz .

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

Runtime was just shy of 3.5hrs:

![fastp runtime on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs_runtime.png?raw=true)

NOTE: The report files from ([`MultiQC`](https://multiqc.info/) and [`fastp`](https://github.com/OpenGene/fastp)) all suffer from a naming error, but _do_ contain data for both read 1 (R1) and read 2 (R2).

Output folder:

- [20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs)

  - [`MultiQC`](https://multiqc.info/) Report (HTML; open in web browser):

    - [multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/multiqc_report.html)

  - Trimmed FastQ MD5 checksums (TEXT):

    - [trimmed_fastq_checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/trimmed_fastq_checksums.md5)

  - [[`fastp`](https://github.com/OpenGene/fastp)] Reports (HTML; open in web browser):

    - [zr3644_10_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_10_R1.fastp-trim.20201206.report.html)

    - [zr3644_11_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_11_R1.fastp-trim.20201206.report.html)

    - [zr3644_12_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_12_R1.fastp-trim.20201206.report.html)

    - [zr3644_13_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_13_R1.fastp-trim.20201206.report.html)

    - [zr3644_14_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_14_R1.fastp-trim.20201206.report.html)

    - [zr3644_15_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_15_R1.fastp-trim.20201206.report.html)

    - [zr3644_16_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_16_R1.fastp-trim.20201206.report.html)

    - [zr3644_17_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_17_R1.fastp-trim.20201206.report.html)

    - [zr3644_18_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_18_R1.fastp-trim.20201206.report.html)

    - [zr3644_19_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_19_R1.fastp-trim.20201206.report.html)

    - [zr3644_1_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_1_R1.fastp-trim.20201206.report.html)

    - [zr3644_20_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_20_R1.fastp-trim.20201206.report.html)

    - [zr3644_21_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_21_R1.fastp-trim.20201206.report.html)

    - [zr3644_22_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_22_R1.fastp-trim.20201206.report.html)

    - [zr3644_23_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_23_R1.fastp-trim.20201206.report.html)

    - [zr3644_24_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_24_R1.fastp-trim.20201206.report.html)

    - [zr3644_2_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_2_R1.fastp-trim.20201206.report.html)

    - [zr3644_3_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_3_R1.fastp-trim.20201206.report.html)

    - [zr3644_4_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_4_R1.fastp-trim.20201206.report.html)

    - [zr3644_5_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_5_R1.fastp-trim.20201206.report.html)

    - [zr3644_6_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_6_R1.fastp-trim.20201206.report.html)

    - [zr3644_7_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_7_R1.fastp-trim.20201206.report.html)

    - [zr3644_8_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_8_R1.fastp-trim.20201206.report.html)

    - [zr3644_9_R1.fastp-trim.20201206.report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_9_R1.fastp-trim.20201206.report.html)

---

List of trimmed FastQs and corresponding MD5 checksums:

- [zr3644_10_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_10_R1.fastp-trim.20201206.fq.gz) (2.7G)

  - MD5: `1d5aa2fc7d812281bafa7ecacc10d065`

- [zr3644_10_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_10_R2.fastp-trim.20201206.fq.gz) (2.7G)

  - MD5: `93d62fca7cb553a421782714f023da67`

- [zr3644_11_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_11_R1.fastp-trim.20201206.fq.gz) (2.9G)

  - MD5: `e7002c3fc579137d9b2d96367ab38a65`

- [zr3644_11_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_11_R2.fastp-trim.20201206.fq.gz) (2.9G)

  - MD5: `870412d303f4a0bc1557ff6ef0780fab`

- [zr3644_12_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_12_R1.fastp-trim.20201206.fq.gz) (2.4G)

  - MD5: `3f83cc934f90939447e1d8dc4699ef9f`

- [zr3644_12_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_12_R2.fastp-trim.20201206.fq.gz) (2.5G)

  - MD5: `df9cbbbc0b578fa49f9340cd05daffb3`

- [zr3644_13_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_13_R1.fastp-trim.20201206.fq.gz) (2.8G)

  - MD5: `8fd09a92630d8e087facfd51152bc0de`

- [zr3644_13_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_13_R2.fastp-trim.20201206.fq.gz) (2.8G)

  - MD5: `660e1b48b4d5ad3be6fa8261c979e4a2`

- [zr3644_14_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_14_R1.fastp-trim.20201206.fq.gz) (2.1G)

  - MD5: `099bdd1ee643c359178c90a1b95dcf8a`

- [zr3644_14_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_14_R2.fastp-trim.20201206.fq.gz) (1.9G)

  - MD5: `63f688d1a5253d083bbe65916b876ea7`

- [zr3644_15_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_15_R1.fastp-trim.20201206.fq.gz) (3.0G)

  - MD5: `1033bb9db553f48dd0d09ec248a47607`

- [zr3644_15_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_15_R2.fastp-trim.20201206.fq.gz) (3.1G)

  - MD5: `b57c5a5773a4639895e54ed4032bbb46`

- [zr3644_16_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_16_R1.fastp-trim.20201206.fq.gz) (2.7G)

  - MD5: `145b0de1fa99bce71b75ae626399e1b1`

- [zr3644_16_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_16_R2.fastp-trim.20201206.fq.gz) (2.7G)

  - MD5: `496ee5843c2605aaaebaed8e3d276d3d`

- [zr3644_17_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_17_R1.fastp-trim.20201206.fq.gz) (2.9G)

  - MD5: `14e082604a8511e32a14879db230a7ba`

- [zr3644_17_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_17_R2.fastp-trim.20201206.fq.gz) (3.0G)

  - MD5: `819e432d9c6099a00aa9bb94efdd5b1e`

- [zr3644_18_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_18_R1.fastp-trim.20201206.fq.gz) (2.6G)

  - MD5: `9eaf6df5cfe7871697dae993082dda1f`

- [zr3644_18_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_18_R2.fastp-trim.20201206.fq.gz) (2.7G)

  - MD5: `70f7fa3d3311ec9c2450bbb6f66e2e3d`

- [zr3644_19_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_19_R1.fastp-trim.20201206.fq.gz) (2.5G)

  - MD5: `2fdaa42984c74f731092acbfe589f896`

- [zr3644_19_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_19_R2.fastp-trim.20201206.fq.gz) (2.6G)

  - MD5: `793bf4226b452e676d8b6ddcadb2ba09`

- [zr3644_1_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_1_R1.fastp-trim.20201206.fq.gz) (2.6G)

  - MD5: `5ee80234cac3d8e8017ca57bccb21eaf`

- [zr3644_1_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_1_R2.fastp-trim.20201206.fq.gz) (2.8G)

  - MD5: `668ae326f386d7f02158f2023044e0ef`

- [zr3644_20_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_20_R1.fastp-trim.20201206.fq.gz) (3.2G)

  - MD5: `c6b535af634b6ca6fed1e7e970c03440`

- [zr3644_20_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_20_R2.fastp-trim.20201206.fq.gz) (2.8G)

  - MD5: `c14c2165e7a1d1cdbdb39b00b813ad78`

- [zr3644_21_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_21_R1.fastp-trim.20201206.fq.gz) (2.8G)

  - MD5: `07d78424ad87f66731a598497c7465b0`

- [zr3644_21_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_21_R2.fastp-trim.20201206.fq.gz) (2.7G)

  - MD5: `283c84e628237f5f9a2d0ff2302e9b9d`

- [zr3644_22_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_22_R1.fastp-trim.20201206.fq.gz) (2.4G)

  - MD5: `1a66fb92e4da94af67738e47639654e6`

- [zr3644_22_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_22_R2.fastp-trim.20201206.fq.gz) (2.5G)

  - MD5: `6e0cd9c04f559c71f10a9ba881841c15`

- [zr3644_23_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_23_R1.fastp-trim.20201206.fq.gz) (2.1G)

  - MD5: `6d2e5db2770ad49b5c6055a73f813870`

- [zr3644_23_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_23_R2.fastp-trim.20201206.fq.gz) (2.1G)

  - MD5: `35d8f23c55d2885774bbc667e7ea6438`

- [zr3644_24_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_24_R1.fastp-trim.20201206.fq.gz) (2.7G)

  - MD5: `5670f429eec3fda094d2956c5b6f73e4`

- [zr3644_24_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_24_R2.fastp-trim.20201206.fq.gz) (2.8G)

  - MD5: `a2dec66c27ef6b35cab389c17adfad3b`

- [zr3644_2_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_2_R1.fastp-trim.20201206.fq.gz) (2.9G)

  - MD5: `3b78ac1977ed68ee6483fce4141863cd`

- [zr3644_2_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_2_R2.fastp-trim.20201206.fq.gz) (2.9G)

  - MD5: `16ede2aa44b0d61e54cb51a33730e443`

- [zr3644_3_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_3_R1.fastp-trim.20201206.fq.gz) (2.1G)

  - MD5: `9c9990d2f982461576dece29dd429e40`

- [zr3644_3_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_3_R2.fastp-trim.20201206.fq.gz) (2.1G)

  - MD5: `f4e79bb6c49492ae1935c1a642c27a7d`

- [zr3644_4_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_4_R1.fastp-trim.20201206.fq.gz) (2.7G)

  - MD5: `918e02f3067d6ab374734dae1bdf5cd7`

- [zr3644_4_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_4_R2.fastp-trim.20201206.fq.gz) (2.6G)

  - MD5: `a2ce85d93d20d4b57500e3f1e89d4511`

- [zr3644_5_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_5_R1.fastp-trim.20201206.fq.gz) (2.5G)

  - MD5: `061394481f1e9f3cce686db052ef57d7`

- [zr3644_5_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_5_R2.fastp-trim.20201206.fq.gz) (2.3G)

  - MD5: `eb25b5f76c81ab58fbd1e404008c045c`

- [zr3644_6_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_6_R1.fastp-trim.20201206.fq.gz) (2.8G)

  - MD5: `d6bef0da74751e12604c1ac74d846dd9`

- [zr3644_6_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_6_R2.fastp-trim.20201206.fq.gz) (2.8G)

  - MD5: `bb9ad6883c228f7f9d6b58e942009546`

- [zr3644_7_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_7_R1.fastp-trim.20201206.fq.gz) (4.2G)

  - MD5: `423e07836aaef454e6cb19828fccd2f2`

- [zr3644_7_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_7_R2.fastp-trim.20201206.fq.gz) (4.3G)

  - MD5: `3a0922fdd5ca436c9a3ea6c40e2a4d9d`

- [zr3644_8_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_8_R1.fastp-trim.20201206.fq.gz) (2.2G)

  - MD5: `d3905851870ecbce6b3a35c3734b9509`

- [zr3644_8_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_8_R2.fastp-trim.20201206.fq.gz) (2.3G)

  - MD5: `a14a1c6c7ab5fc5ac6ace28f10af0e3f`

- [zr3644_9_R1.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_9_R1.fastp-trim.20201206.fq.gz) (2.4G)

  - MD5: `2870c21684f14487d7e040e2dda48b79`

- [zr3644_9_R2.fastp-trim.20201206.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastp-10bp-5-3-prime_ploidy-pH-wgbs/zr3644_9_R2.fastp-trim.20201206.fq.gz) (2.5G)

  - MD5: `dab6d90fff69aac28a819fad25c21975`
