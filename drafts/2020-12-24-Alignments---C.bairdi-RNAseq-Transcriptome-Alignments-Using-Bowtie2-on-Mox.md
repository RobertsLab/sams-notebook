---
layout: post
title: Alignments - C.bairdi RNAseq Transcriptome Alignments Using Bowtie2 on Mox
date: '2020-12-24 05:10'
tags:
  - bowtie2
  - Tanner crab
  - mox
  - bowtie2
  - transcriptome
  - RNAseq
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---


SBATCH script (GitHub):

- [20201224_cbai_bowtie2_transcriptomes_alignments.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20201224_cbai_bowtie2_transcriptomes_alignments.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20201224_cbai_bowtie2_transcriptomes_alignments
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=15-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201224_cbai_bowtie2_transcriptomes_alignments
# This is a script to generate BAM files for use in DETONATE's
# rsem-eval program to compare C.bairdi transcriptome assembly "qualities".

###################################################################################
# These variables need to be set by user

# Assign Variables
reads_dir=/gscratch/srlab/sam/data/C_bairdi/RNAseq
transcriptomes_dir=/gscratch/srlab/sam/data/C_bairdi/transcriptomes
threads=28
mem_per_thread=10G

# Program paths
bowtie2_dir="/gscratch/srlab/programs/bowtie2-2.4.2-linux-x86_64"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"

# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
transcriptomes_array=(
"${transcriptomes_dir}"/cbai_transcriptome_v1.0.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v1.5.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v1.6.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v1.7.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v2.0.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v2.1.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v3.0.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v3.1.fasta
)


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017


# Programs array
declare -A programs_array
programs_array=(
[bowtie2]="${bowtie2_dir}/bowtie2" \
[bowtie2_build]="${bowtie2_dir}/bowtie2-build" \
[samtools_index]="${samtools} index" \
[samtools_sort]="${samtools} sort" \
[samtools_view]="${samtools} view"
)




# Loop through each comparison
for transcriptome in "${!transcriptomes_array[@]}"
do

  ## Inititalize arrays
  R1_array=()
  R2_array=()
  reads_array=()

  # Variables
  R1_list=""
  R2_list=""

  transcriptome_name="${transcriptomes_array[$transcriptome]##*/}"

  # Capture FastA checksums for verification
  echo "Generating checksum for ${transcriptome_name}"
  md5sum "${transcriptomes_array[transcriptome]}" >> fasta.checksums.md5
  echo "Finished generating checksum for ${transcriptome_name}"
  echo ""

	if [[ "${transcriptome_name}" == "cbai_transcriptome_v1.0.fasta" ]]; then

    reads_array=("${reads_dir}"/20200[15][13][138]*megan*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/20200[15][13][138]*megan*R1.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/20200[15][13][138]*megan*R2.fq)



  elif [[ "${transcriptome_name}" == "cbai_transcriptome_v1.5.fasta" ]]; then

    reads_array=("${reads_dir}"/20200[145][13][138]*megan*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/20200[145][13][138]*megan*R1.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/20200[145][13][138]*megan*R2.fq)

  elif [[ "${transcriptome_name}" == "cbai_transcriptome_v1.6.fasta" ]]; then

    reads_array=("${reads_dir}"/*megan*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/*megan*R1.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/*megan*R2.fq)

  elif [[ "${transcriptome_name}" == "cbai_transcriptome_v1.7.fasta" ]]; then

    reads_array=("${reads_dir}"/20200[145][13][189]*megan*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/20200[145][13][189]*megan*R1.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/20200[145][13][189]*megan*R2.fq)

  elif [[ "${transcriptome_name}" == "cbai_transcriptome_v2.0.fasta" ]] \
  || [[ "${transcriptome_name}" == "cbai_transcriptome_v2.1.fasta" ]]; then

    reads_array=("${reads_dir}"/*fastp-trim*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/*R1*fastp-trim*.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/*R2*fastp-trim*.fq)

  elif [[ "${transcriptome_name}" == "cbai_transcriptome_v3.0.fasta" ]] \
  || [[ "${transcriptome_name}" == "cbai_transcriptome_v3.1.fasta" ]]; then

    reads_array=("${reads_dir}"/*fastp-trim*20[12][09][01][24]1[48]*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/*R1*fastp-trim*20[12][09][01][24]1[48]*.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/*R2*fastp-trim*20[12][09][01][24]1[48]*.fq)


  fi

  # Create list of fastq files used in analysis
  ## Uses parameter substitution to strip leading path from filename
  printf "%s\n" "${reads_array[@]##*/}" >> "${transcriptome_name}".fastq.list.txt

  # Create comma-separated lists of FastQ reads
  R1_list=$(echo "${R1_array[@]}" | tr " " ",")
  R2_list=$(echo "${R2_array[@]}" | tr " " ",")

  # Build Bowtie2 index
  # Transcriptome name is used as index basename
  ${programs_array[bowtie2_build]} \
  --threads ${threads} \
  ${transcriptomes_array[$transcriptome]} \
  ${transcriptome_name}

  # Run rsem-eval
  # Use bowtie2 and paired-end options
  # Uses settings specified for use with DETONATE
  # and for paired end reads when using DETONATE.
  ${programs_array[bowtie2]} \
  -x ${transcriptome_name} \
  -S ${transcriptome_name}.sam \
  --threads ${threads} \
  -1 ${R1_list} \
  -2 ${R2_list} \
  --sensitive \
  --dpad 0 \
  --gbar 99999999 \
  --mp 1,1 \
  --np 1 \
  --score-min L,0,-0.1 \
  --no-mixed \
  --no-discordant

  # Convert SAM to sorted BAM
  #
  ${programs_array[samtools_view]} \
  -b \
  ${transcriptome_name}.sam \
  | ${programs_array[samtools_sort]} \
  -m ${mem_per_thread} \
  --threads ${threads} \
  -o ${transcriptome_name}.sorted.bam \
  -

  # Capture BAM checksums for verification
  echo "Generating checksum for ${transcriptome_name}.sorted.bam"
  md5sum ${transcriptome_name}.sorted.bam >> bam.checksums.md5
  echo "Finished generating checksum for ${transcriptome_name}.sorted.bam"
  echo ""

done

# Remove leftover SAM files
rm *.sam

# Capture program options
echo "Logging program options..."
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

echo ""
echo "Finished logging program options."
echo ""

echo ""
echo "Logging system PATH."
# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log

echo "Finished logging system PATH"
```

---

#### RESULTS

Run time was ~2.5 days (not counting some weird issues with Mox):

~[Runtime for bowtie2 alignments on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201224_cbai_bowtie2_transcriptomes_alignments_runtime.png?raw=true)

Output folder:

- [20201224_cbai_bowtie2_transcriptomes_alignments/](https://gannet.fish.washington.edu/Atumefaciens/20201224_cbai_bowtie2_transcriptomes_alignments/)
