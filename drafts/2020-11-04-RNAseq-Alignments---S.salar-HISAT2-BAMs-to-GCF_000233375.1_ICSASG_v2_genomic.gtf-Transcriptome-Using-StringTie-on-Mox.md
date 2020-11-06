---
layout: post
title: RNAseq Alignments - S.salar HISAT2 BAMs to GCF_000233375.1_ICSASG_v2_genomic.gtf Transcriptome Using StringTie on Mox
date: '2020-11-04 20:37'
tags:
  - Salmo salar
  - Atlantic salmon
  - stringtie
  - mox
  - transcriptome
categories:
  - Miscellaneous
---
This is a continuation of addressing [Shelly Trigg's (regarding some _Salmo salar_ RNAseq data) request (GitHub Issue)](https://github.com/RobertsLab/resources/issues/1016) to trim ([completed 20201029](https://robertslab.github.io/sams-notebook/2020/10/29/Trimming-Shelly-S.salar-RNAseq-Using-fastp-and-MultiQC-on-Mox.html)), perform genome alignment ([completed on 20201103](https://robertslab.github.io/sams-notebook/2020/11/03/RNAseq-Alignments-Trimmed-S.salar-RNAseq-to-GCF_000233375.1_ICSASG_v2_genomic.fa-Using-Hisat2-on-Mox.html)), and transcriptome alignment.

To finish this up, I used [`StringTie`](https://ccb.jhu.edu/software/stringtie/) to align to a subset of the `GCF_000233375.1_ICSASG_v2_genomic.gtf` provided by Shelly. I created a subset (see SBATCH script below for deets) that only included the same sequence IDs in Shelly's subsetted genome Fasta (see genome alignment [completed on 20201103](https://robertslab.github.io/sams-notebook/2020/11/03/RNAseq-Alignments-Trimmed-S.salar-RNAseq-to-GCF_000233375.1_ICSASG_v2_genomic.fa-Using-Hisat2-on-Mox.html) for more info on that.).

Shelly indicated she really just needed the FPKM and/or TPM values, so I ran [`StringTie`](https://ccb.jhu.edu/software/stringtie/) with the `-A` option which spits out a tab-delimited table with both of those values in columns 8 and 9.

This was run on Mox.



SBATCH script (GitHub):

- [20201104_ssal_RNAseq_stringtie_alignment.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20201104_ssal_RNAseq_stringtie_alignment.sh)


```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20201104_ssal_RNAseq_stringtie_alignment
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201104_ssal_RNAseq_stringtie_alignment


### S.salar RNAseq StringTie alignment.

### Uses BAM alignment files from 20201103 and transcriptome
### GTF provided by Shelly (presumably GTF is from NCBI).


###################################################################################
# These variables need to be set by user

## Assign Variables

wd=$(pwd)

# Set number of CPUs to use
threads=27

# Input/output files
bam_dir="/gscratch/scrubbed/samwhite/outputs/20201103_ssal_RNAseq_hisat2_alignment/"
bam_md5s=bam_checksums.md5
genome="/gscratch/srlab/sam/data/S_salar/genomes/GCF_000233375.1_ICSASG_v2_genomic.fa"
gtf_md5=gtf_checksums.md5
ncbi_transcriptome="/gscratch/srlab/sam/data/S_salar/transcriptomes/GCF_000233375.1_ICSASG_v2_genomic.gtf"
chr_only_transriptome="GCF_000233375.1_ICSASG_v2_genomic_NC-chr-only.gtf"
# Paths to programs
stringtie="/gscratch/srlab/programs/stringtie-2.1.4.Linux_x86_64/stringtie"

# Programs associative array
declare -A programs_array
programs_array=(
[stringtie]="${stringtie}"
)

###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Subset transcriptome with NC_ only entries to match Shelly's genome
# Only lines beginning with "NC_"
grep "^NC_" "${ncbi_transcriptome}" >> "${chr_only_transriptome}"


# Run StringTie
for bam in "${bam_dir}"*.bam
do
  # Parse out sample name by removing all text up to and including the last period.
  sample_name_no_path=${bam##*/}
  sample_name=${sample_name_no_path%%.*}

  # Exectute StringTie
  # Use list of of chromosome IDs (ref_list)
  # Output an abundance file with TPM and FPKM data in dedicated columns
  ${programs_array[stringtie]} \
  ${bam} \
  -G ${chr_only_transriptome} \
  -A ${sample_name}_gene-abund.tab \
  -p ${threads}

  # Generate BAM MD5 checksums
  md5sum "${bam}" >> "${bam_md5s}"
done


# Generate GTF MD5 checksum
md5sum "${ncbi_transcriptome}" >> "${gtf_md5}"
md5sum "${chr_only_transriptome}" >> "${gtf_md5}"

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

Runtime was pretty quick, just under 18mins:

![Runtime of StringTie RNAseq alignments on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201104_ssal_RNAseq_stringtie_alignment_runtime.png?raw=true)

Output folder/files:

Runtime was fast; just under 18mins:

![Cumulative StringTie runtime on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201104_ssal_RNAseq_stringtie_alignment_runtime.png?raw=true)

- [20201104_ssal_RNAseq_stringtie_alignment](https://gannet.fish.washington.edu/Atumefaciens/20201104_ssal_RNAseq_stringtie_alignment)


  ##### Subsetted GTF file used for alignment:

  - [GCF_000233375.1_ICSASG_v2_genomic_NC-chr-only.gtf](https://gannet.fish.washington.edu/Atumefaciens/20201104_ssal_RNAseq_stringtie_alignment/GCF_000233375.1_ICSASG_v2_genomic_NC-chr-only.gtf)

  ##### Abundance files with FPKM and TPM in columns 8 & 9.

  - [Pool26_16_gene-abund.tab](https://gannet.fish.washington.edu/Atumefaciens/20201104_ssal_RNAseq_stringtie_alignment/Pool26_16_gene-abund.tab)

  - [Pool26_8_gene-abund.tab](https://gannet.fish.washington.edu/Atumefaciens/20201104_ssal_RNAseq_stringtie_alignment/Pool26_8_gene-abund.tab)

  - [Pool32_16_gene-abund.tab](https://gannet.fish.washington.edu/Atumefaciens/20201104_ssal_RNAseq_stringtie_alignment/Pool32_16_gene-abund.tab)

  - [Pool32_8_gene-abund.tab](https://gannet.fish.washington.edu/Atumefaciens/20201104_ssal_RNAseq_stringtie_alignment/Pool32_8_gene-abund.tab)
