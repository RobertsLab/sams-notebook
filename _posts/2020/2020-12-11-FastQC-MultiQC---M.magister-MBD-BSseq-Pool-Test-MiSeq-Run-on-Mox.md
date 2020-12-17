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

Runtime was fast, ~3.5mins:

![Cumulative runtime for FastQC and MultiQC on C.magister MiSeq data](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201211_mmag_fastqc_multiqc_mbd-bsseq_miseq_runtime.png?raw=true)


Will add [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) report links to [`Nightingales`](https://b.link/nightingales) spreadsheet (Google Sheet) for those that did _not_ fail.

NOTE: This post was updated on 20201217 using a newly transferred set of FastQs that Mac set up. See [the previous commit of this post](https://github.com/RobertsLab/sams-notebook/blob/c11f5f8c6149376d5896c2f0acd104960512b972/_posts/2020/2020-12-11-FastQC-MultiQC---M.magister-MBD-BSseq-Pool-Test-MiSeq-Run-on-Mox.md) for more info.

Output folder:

- [20201211_mmag_fastqc_multiqc_mbd-bsseq_miseq/](https://gannet.fish.washington.edu/Atumefaciens/20201211_mmag_fastqc_multiqc_mbd-bsseq_miseq/)

[`MultiQC`](https://multiqc.info/) Report (HTML; open with web browser):

- [20201211_mmag_fastqc_multiqc_mbd-bsseq_miseq/multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20201211_mmag_fastqc_multiqc_mbd-bsseq_miseq/multiqc_report.html)

Individual [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) reports can be found by browsing the output folder linked above and/or by clicking through the [`MultiQC`](https://multiqc.info/) report that's linked above.

This test run was to help evaluate evenness of the sample pooling, as well as identify any other possible issues. Evenness appears OK (not great), but I'm not entirely sure how this would be addressed, as an aliquot of each library was created at a concentration of 4nM and then 1uL of each of these aliquots was combined. Is it safe to assume that any sequencing biases leading to preferential library sequencing is due to the individual libraries? And, that this can be adjusted for when making the final pooling that gets sent off for a full sequencing run? Also, I'm a bit surprised at the high levels of adapter content. I'm curious how these data will look after trimming. Anyway, at this point, I'll let Laura Spencer and Mac make decisions about going forward with a full sequencing run, as it's really their project anyway.
