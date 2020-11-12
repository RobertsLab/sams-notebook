---
layout: post
title: FastQC-MultiQc - C.gigas Ploidy WGBS Raw Sequence Data from Ronits Project on Mox
date: '2020-11-10 11:42'
tags:
  - ploidy
  - Crassostrea gigas
  - Pacific oyster
  - wgbs
  - fastqc
  - mox
categories:
  - Miscellaneous
---
[Earlier today, we received the _C.gigas_ ploidy WGBS data](https://robertslab.github.io/sams-notebook/2020/11/10/Data-Received-C.gigas-Ploidy-WGBS-from-Ronits-Project-via-ZymoResearch.html) that we [submitted to ZymoResearch on 20200820](https://robertslab.github.io/sams-notebook/2020/08/20/Samples-Submitted-Ronits-C.gigas-Diploid-and-Triploid-Ctenidia-to-ZymoResearch-for-WGBS.html).

As part of our usual work flow, I needed to run [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/).

Ran [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on Mox.

SBATCH script (GitHub):

- [20201110_cgig_fastqc_ronit-ploidy-wgbs.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20201110_cgig_fastqc_ronit-ploidy-wgbs.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20201110_cgig_fastqc_ronit-ploidy-wgbs
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201110_cgig_fastqc_ronit-ploidy-wgbs


### FastQC assessment of raw sequencing from Ronit's ploidy WGBS.


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
"${raw_reads_dir}"zr3534*.fq.gz .

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
  	cp --preserve ~/.multiqc_config.yaml .
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

Runtime was relatively quick, ~18mins:

![FastQC runtime on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201110_cgig_fastqc_ronit-ploidy-wgbs_runtime.png?raw=true)

Will add links to individual [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) reports to our [Nightingales Google Sheet](https://docs.google.com/spreadsheets/d/1_XqIOPVHSBVGscnjzDSWUeRL7HUHXfaHxVzec-I-8Xk/edit?usp=sharing)

Output folder:

- [20201110_cgig_fastqc_ronit-ploidy-wgbs](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs)


[`MultiQC`](https://multiqc.info/) Report (HTML - open with web browser):

- [multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/multiqc_report.html)


---

Individual FastQC Reports:

- [zr3534_10_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_10_R1_fastqc.html)


- [zr3534_10_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_10_R2_fastqc.html)


- [zr3534_1_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_1_R1_fastqc.html)


- [zr3534_1_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_1_R2_fastqc.html)


- [zr3534_2_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_2_R1_fastqc.html)


- [zr3534_2_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_2_R2_fastqc.html)


- [zr3534_3_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_3_R1_fastqc.html)


- [zr3534_3_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_3_R2_fastqc.html)


- [zr3534_4_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_4_R1_fastqc.html)


- [zr3534_4_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_4_R2_fastqc.html)


- [zr3534_5_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_5_R1_fastqc.html)


- [zr3534_5_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_5_R2_fastqc.html)


- [zr3534_6_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_6_R1_fastqc.html)


- [zr3534_6_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_6_R2_fastqc.html)


- [zr3534_7_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_7_R1_fastqc.html)


- [zr3534_7_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_7_R2_fastqc.html)


- [zr3534_8_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_8_R1_fastqc.html)


- [zr3534_8_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_8_R2_fastqc.html)


- [zr3534_9_R1_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_9_R1_fastqc.html)


- [zr3534_9_R2_fastqc.html](https://gannet.fish.washington.edu/Atumefaciens/20201110_cgig_fastqc_ronit-ploidy-wgbs/zr3534_9_R2_fastqc.html)
