---
layout: post
title: Data Wrangling - C.bairdi NanoPore Quality Filtering Using NanoFilt on Mox
date: '2020-09-17 11:52'
tags:
  - Tanner crab
  - NanoFilt
  - mox
  - nanopore
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
I previously converting our _C.bairdi_ NanoPre sequencing data from the raw Fast5 format to FastQ format for our three sets of data:

- [C.bairdi-20102558-2729-Run-01](https://robertslab.github.io/sams-notebook/2020/09/04/Data-Wrangling-NanoPore-Fast5-Conversion-to-FastQ-of-C.bairdi-20102558-2729-Run-01-on-Mox-with-GPU-Node.html)

- [C.bairdi-20102558-2729-Run-02](https://robertslab.github.io/sams-notebook/2020/09/04/Data-Wrangling-NanoPore-Fast5-Conversion-to-FastQ-of-C.bairdi-20102558-2729-Run-02-on-Mox-with-GPU-Node.html)

- [C.bairdi-6129_403_26](https://robertslab.github.io/sams-notebook/2020/09/04/Data-Wrangling-NanoPore-Fast5-Conversion-to-FastQ-of-C.bairdi-6129_403_26-on-Mox-with-GPU-Node.html)

I [visualized the data with NanoPlot on 20200914](https://robertslab.github.io/sams-notebook/2020/09/14/Data-Wrangling-Visualization-of-C.bairdi-NanoPore-Sequencing-Using-NanoPlot-on-Mox.html).

In preparation for an attempt at a _de novo_ assembly, I decided to quality filter the sequencing data using [NanoFilt](https://github.com/wdecoster/nanofilt). I semi-arbitrarily selected a quality score of 7 as the cutoff. This is primarily based on the fact that this value is the default used by ONT when you allow their software to automatically make basecalls and quality selections. Additionally, some of the visualizations of the raw sequencing reads show a bit of a bifurcation in quality above/below this quality score.

The job was run on Mox.

SBATCH script (GitHub):

- [20200917_cbai_nanofilt_nanopore-data.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200917_cbai_nanofilt_nanopore-data.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_nanofilt_Q7_nanopore-data
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200917_cbai_nanofilt_Q7_nanopore-data




###################################################################################
# These variables need to be set by user

# Load Anaconda
# Uknown why this is needed, but Anaconda will not run if this line is not included.
. "/gscratch/srlab/programs/anaconda3/etc/profile.d/conda.sh"


# Activate the NanoPlot Anaconda environment
conda activate nanofilt_2.6.0_env


# Declare array
raw_reads_dir_array=()

# Paths to reads
raw_reads_dir_array=(
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL58500_04bb4d86_20102558-2729" \
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL58500_94244ffd_20102558-2729" \
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL86873_d8db260e_cbai_6129_403_26"
)

# FastQ concatenation filename
fastq_cat=20200917_cbai_nanopore_all.fastq

fastq_filtered=20200917_cbai_nanopore_all_quality-7.fastq

# Paths to programs
nanofilt=NanoFilt

# Set mean quality filter (integer)
quality=7

###################################################################################


# Exit script if any command fails
set -e

# Inititalize array
programs_array=()

# Programs array
programs_array=("${nanofilt}")


# Loop through NanoPore data directories
# to run NanoPlot, FastQC, and MultiQC
for directory in "${raw_reads_dir_array[@]}"
do

  # Find all FastQ files and concatenate into singel file
  while IFS= read -r -d '' filename
  do
    # Concatenate all FastQ files into single file
    # for NanoFilt and generate MD5 checksums
    echo "Now concatenating ${filename} to ${fastq_cat}..."
    cat "${filename}" >> ${fastq_cat}

    # Create checksums file
    echo "Now generating checksum for ${filename}..."
    echo ""
    md5sum "${filename}" >> fastq_checksums.md5

  done < <(find "${directory}" -name "*.fastq" -type f -print0)

done

# Generate MD5 checksum for concatenated FastQ file
echo "Now generating checksum for ${fastq_cat}..."
echo ""
md5sum "${fastq_cat}" >> fastq_checksums.md5

# Run NanoFilt
## Sets readtype to 1D (default)
## Filters on mean quality >= 7 (ONT "standard")
## FYI: seems to require piping stdin (i.e. cat fastq |)to NanoFilt...
echo "Running ${programs_array[nanofilt]}"
echo ""
cat ${fastq_cat} \
| ${programs_array[nanofilt]} \
--readtype 1D \
--quality ${quality} \
> ${fastq_filtered}
echo "${programs_array[nanofilt]} complete."
echo ""

# Generate MD5 checksum for concatenated FastQ file
echo "Now generating checksum for ${fastq_filtered}..."
echo ""
md5sum "${fastq_filtered}" >> fastq_checksums.md5


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
