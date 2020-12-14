---
layout: post
title: FastQC-MultiQC - M.magister MBD-BSseq Pool Test MiSeq Run on Mox
date: '2020-12-11 15:35'
tags:
  - fastqtc
  - multiqc
  - Metacarcinus magister
  - Cancer magister
  - Dungeness crab
  - mox
categories:
  - Miscellaneous
---
Earlier today we received the [_M.magister_ (_C.magister_; Dungeness crab) MiSeq data from Mac](https://robertslab.github.io/sams-notebook/2020/12/11/Data-Received-M.magister-MBD-BSseq-Pool-Test-MiSeq-Run.html).

I ran [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) and [`MultiQC`](https://multiqc.info/) on Mox.

SBATCH script (GitHub):

- [20201211_mmag_fastqc_multiqc_mbd-bsseq_miseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20201211_mmag_fastqc_multiqc_mbd-bsseq_miseq.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20201211_mmag_fastqc_multiqc_mbd-bsseq_miseq
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201211_mmag_fastqc_multiqc_mbd-bsseq_miseq


### FastQC assessment of raw MiSeq sequencing test run for
### MBD-BSseq pool of M.magister samples from 20201202.


###################################################################################
# These variables need to be set by user

# FastQC output directory
output_dir=$(pwd)

# Set number of CPUs to use
threads=28

# Input/output files
checksums=fastq_checksums.md5
fastq_list=fastq_list.txt
raw_reads_dir=/gscratch/srlab/sam/data/C_magister/MBD-BSseq/

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
"${raw_reads_dir}"CH*.fastq.gz .

# Populate array with FastQ files
fastq_array=(CH*.fastq.gz)

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

Output folder:

- []()
