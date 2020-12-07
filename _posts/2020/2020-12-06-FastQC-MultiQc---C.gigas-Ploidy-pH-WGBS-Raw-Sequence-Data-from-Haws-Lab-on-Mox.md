---
layout: post
title: FastQC-MultiQc - C.gigas Ploidy pH WGBS Raw Sequence Data from Haws Lab on Mox
date: '2020-12-06 20:46'
tags:
  - ploidy
  - Mox
  - fastqc
  - multiqc
  - pH
  - haws
  - hawaii
categories:
  - Miscellaneous
---
[Yesterday (20201205), we received the whole genome bisulfite sequencing (WGBS) data back from ZymoResearch](https://robertslab.github.io/sams-notebook/2020/12/05/Data-Received-C.gigas-Diploid-Triploid-pH-Treatments-Ctenidia-WGBS-from-ZymoResearch.html) from the 24 _C.gigas_ diploid/triploid subjected to two different pH treatments ([received from the Haws' Lab on 20200820](https://robertslab.github.io/sams-notebook/2020/08/20/Samples-Received-C.gigas-High-Low-pH-Triploid-Diploid-from-Maria-Haws-Lab.html) that we [submitted to ZymoResearch on 20200824](https://robertslab.github.io/sams-notebook/2020/08/24/Sample-Submitted-C.gigas-Diploid-Triploid-pH-Treatments-Ctenidia-to-ZymoResearch-for-WGBS.html). As part of our standard sequencing data receipt pipeline, I needed to generate [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) files for each sample.

[`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) was run on Mox.

Links to [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) reports will be added to our NGS database spreadsheet, [`Nightingales`](https://b.link/nightingales) (Google Sheet).

SBATCH script (GitHub):

- [20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs


### FastQC assessment of raw sequencing from Haw's Lab ploidy pH WGBS.


###################################################################################
# These variables need to be set by user

# FastQC output directory
output_dir=$(pwd)

# Set number of CPUs to use
threads=28

# Input/output files
checksums=fastq_checksums.md5
fastq_list=fastq_list.txt
raw_reads_dir=/gscratch/srlab/sam/data/C_gigas/wgbs/

# Paths to programs
fastqc=/gscratch/srlab/programs/fastqc_v0.11.9/fastqc
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc


# Programs associative array
declare -A programs_array
programs_array=(
[fastqc]="${fastqc}" \
[multiqc]="${multiqc}"
)

###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Sync raw FastQ files to working directory
rsync --archive --verbose \
"${raw_reads_dir}"zr3644*.fq.gz .

# Populate array with FastQ files
fastq_array=(*.fq.gz)

# Pass array contents to new variable
fastqc_list=$(echo "${fastq_array[*]}")

# Run FastQC
# NOTE: Do NOT quote ${fastqc_list}
${programs_array[fastqc]} \
--threads ${threads} \
--outdir ${output_dir} \
${fastqc_list}


# Create list of fastq files used in analysis
echo "${fastqc_list}" | tr " " "\n" >> ${fastq_list}

# Generate checksums for reference
while read -r line
do

	# Generate MD5 checksums for each input FastQ file
	echo "Generating MD5 checksum for ${line}."
	md5sum "${line}" >> "${checksums}"
	echo "Completed: MD5 checksum for ${line}."
	echo ""

	# Remove fastq files from working directory
	echo "Removing ${line} from directory"
	rm "${line}"
	echo "Removed ${line} from directory"
	echo ""
done < ${fastq_list}

# Run MultiQC
${programs_array[multiqc]} .


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

Runtime was ~30mins:

![FastQC and MultiQC cumulative runtime on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs_runtime.png?raw=true)

Output folder:

- [20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs)

  - FastQ MD5 checksums (TEXT):

    - [fastq_checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/fastq_checksums.md5)

  - [`MultiQC`](https://multiqc.info/) Report (HTML; open in web browser):

    - [multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/multiqc_report.html)


  - Individual [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) Reports (HTML; open in web browser):

    - [zr3644_10_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_10_R1_fastqc.html)

    - [zr3644_10_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_10_R2_fastqc.html)

    - [zr3644_11_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_11_R1_fastqc.html)

    - [zr3644_11_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_11_R2_fastqc.html)

    - [zr3644_12_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_12_R1_fastqc.html)

    - [zr3644_12_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_12_R2_fastqc.html)

    - [zr3644_13_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_13_R1_fastqc.html)

    - [zr3644_13_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_13_R2_fastqc.html)

    - [zr3644_14_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_14_R1_fastqc.html)

    - [zr3644_14_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_14_R2_fastqc.html)

    - [zr3644_15_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_15_R1_fastqc.html)

    - [zr3644_15_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_15_R2_fastqc.html)

    - [zr3644_16_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_16_R1_fastqc.html)

    - [zr3644_16_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_16_R2_fastqc.html)

    - [zr3644_17_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_17_R1_fastqc.html)

    - [zr3644_17_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_17_R2_fastqc.html)

    - [zr3644_18_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_18_R1_fastqc.html)

    - [zr3644_18_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_18_R2_fastqc.html)

    - [zr3644_19_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_19_R1_fastqc.html)

    - [zr3644_19_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_19_R2_fastqc.html)

    - [zr3644_1_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_1_R1_fastqc.html)

    - [zr3644_1_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_1_R2_fastqc.html)

    - [zr3644_20_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_20_R1_fastqc.html)

    - [zr3644_20_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_20_R2_fastqc.html)

    - [zr3644_21_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_21_R1_fastqc.html)

    - [zr3644_21_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_21_R2_fastqc.html)

    - [zr3644_22_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_22_R1_fastqc.html)

    - [zr3644_22_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_22_R2_fastqc.html)

    - [zr3644_23_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_23_R1_fastqc.html)

    - [zr3644_23_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_23_R2_fastqc.html)

    - [zr3644_24_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_24_R1_fastqc.html)

    - [zr3644_24_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_24_R2_fastqc.html)

    - [zr3644_2_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_2_R1_fastqc.html)

    - [zr3644_2_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_2_R2_fastqc.html)

    - [zr3644_3_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_3_R1_fastqc.html)

    - [zr3644_3_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_3_R2_fastqc.html)

    - [zr3644_4_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_4_R1_fastqc.html)

    - [zr3644_4_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_4_R2_fastqc.html)

    - [zr3644_5_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_5_R1_fastqc.html)

    - [zr3644_5_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_5_R2_fastqc.html)

    - [zr3644_6_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_6_R1_fastqc.html)

    - [zr3644_6_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_6_R2_fastqc.html)

    - [zr3644_7_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_7_R1_fastqc.html)

    - [zr3644_7_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_7_R2_fastqc.html)

    - [zr3644_8_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_8_R1_fastqc.html)

    - [zr3644_8_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_8_R2_fastqc.html)

    - [zr3644_9_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_9_R1_fastqc.html)

    - [zr3644_9_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201206_cgig_fastqc_multiqc_ploidy-pH-wgbs/zr3644_9_R2_fastqc.html)
