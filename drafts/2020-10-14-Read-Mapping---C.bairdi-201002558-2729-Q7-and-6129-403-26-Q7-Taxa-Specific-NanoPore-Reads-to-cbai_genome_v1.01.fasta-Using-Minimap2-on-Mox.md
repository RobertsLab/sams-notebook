---
layout: post
title: Read Mapping - C.bairdi 201002558-2729-Q7 and 6129-403-26-Q7 Taxa-Specific NanoPore Reads to cbai_genome_v1.01.fasta Using Minimap2 on Mox
date: '2020-10-14 09:59'
tags:
  - mox
  - Tanner crab
  - minimap2
  - nanopore
categories:
  - Miscellaneous
---
After extracting [FastQ reads using `seqtk` on 20201013](https://robertslab.github.io/sams-notebook/2020/10/13/Data-Wrangling-C.bairdi-NanoPore-Reads-Extractions-With-Seqtk-on-Mephisto.html) from the various taxa I had been interested in, the next thing needed doing was mapping reads to the [`cbai_genome_v1.01` "genome" assembly from 20200917](https://robertslab.github.io/sams-notebook/2020/09/17/Genome-Assembly-C.bairdi-cbai_v1.0-Using-All-NanoPore-Data-With-Flye-on-Mox.html). I found that [Minimap2](https://github.com/lh3/minimap2) will map long reads (e.g. NanoPore), in addition to short reads, so I decided to give that a rip.

Minimap2 was run on Mox.

SBATCH script (GitHub):

- [20201014_cbai_minimap_nanopore-megan6-taxa-reads.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20201014_cbai_minimap_nanopore-megan6-taxa-reads.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20201014__cbai_minimap_nanopore-megan6-taxa-reads
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=15-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201014_cbai_minimap_nanopore-megan6-taxa-reads


###################################################################################
# These variables need to be set by user

## Assign Variables

# CPU threads to use
threads=27

# Genome FastA path
genome_fasta=/gscratch/srlab/sam/data/C_bairdi/genomes/cbai_genome_v1.01.fasta


# Paths to programs
minimap2="/gscratch/srlab/programs/minimap2-2.17_x64-linux/minimap2"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"



# Programs array
declare -A programs_array
programs_array=(
[minimap2]="${minimap2}" \
[samtools_sort]="${samtools} sort" \
[samtools_view]="${samtools} view"
)



###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Capture date
timestamp=$(date +%Y%m%d)

# Loop through each FastQ
for fastq in *.fq
do

  # Parse out sample name
  sample=$(echo "${fastq}" | awk -F"_" '{print $2}')

  # Caputure taxa
  taxa=$(echo "${fastq}" | awk -F"_" '{print $3}')

  # Capture filename prefix
  prefix="${timestamp}_${sample}_${taxa}"

  # Run Minimap2 with Oxford NanoPore Technologies (ONT) option
  # Using SAM output format (-a option)
  ${programs_array[minimap2]} \
  -ax map-ont \
  ${genome_fasta} \
  ${fastq} \
  | ${programs_array[samtools_sort]} --threads ${threads} \
  -O sam \
  > "${prefix}".sorted.sam


  # Capture FastA checksums for verification ()
  echo "Generating checksum for ${fastq}"
  md5sum "${fastq}" > fastq_checksums.md5
  echo "Finished generating checksum for ${fastq}"
  echo ""


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

# Capture program options
## Note: Trinity util/support scripts don't have options/help menus
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${program}: "
	echo ""
	${programs_array[$program]} --help
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true
done
```


---

#### RESULTS

Although there aren't that many total number of sequences to map, I was still surprised at how quick this was; ~5mins:

![Minimap2 runtime on Mox for all taxa read mapping](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201014_cbai_minimap_nanopore-megan6-taxa-reads_runtime.png?raw=true)

Output folder and files:

- [20201014_cbai_minimap_nanopore-megan6-taxa-reads/](https://gannet.fish.washington.edu/Atumefaciens/20201014_cbai_minimap_nanopore-megan6-taxa-reads/)

  - [20201014_201002558-2729-Q7_Aquifex.sorted.sam](20201014_201002558-2729-Q7_Aquifex.sorted.sam) (1.5M)

  - [20201014_201002558-2729-Q7_Arthropoda.sorted.sam](20201014_201002558-2729-Q7_Arthropoda.sorted.sam) (11M)

  - [20201014_201002558-2729-Q7_Enterospora.sorted.sam](20201014_201002558-2729-Q7_Enterospora.sorted.sam) (8.3M)

  - [20201014_201002558-2729-Q7_Sar.sorted.sam](20201014_201002558-2729-Q7_Sar.sorted.sam) (104K)

  - [20201014_6129-403-26-Q7_Alveolata.sorted.sam](20201014_6129-403-26-Q7_Alveolata.sorted.sam) (5.6M)

  - [20201014_6129-403-26-Q7_Aquifex.sorted.sam](20201014_6129-403-26-Q7_Aquifex.sorted.sam) (68M)

  - [20201014_6129-403-26-Q7_Arthropoda.sorted.sam](20201014_6129-403-26-Q7_Arthropoda.sorted.sam) (491M)

  - [20201014_6129-403-26-Q7_Enterospora.sorted.sam](20201014_6129-403-26-Q7_Enterospora.sorted.sam) (261M)
