---
layout: post
title: RNAseq Alignment - C.virginica Adult OA Gonad Data to GCF_002022765.2 Genome Using HISAT2 on Mox
date: '2022-01-31 13:35'
tags: 
  - HISAT2
  - Crassostrea virginica
  - RNAseq
  - Mox
  - Eastern oyster
categories: 
  - Miscellaneous
---
As part of [this project](https://github.com/epigeneticstoocean/2018_L18-adult-methylation), Steven's asked that [I identify long, non-coding RNAs (lncRNAs)](https://github.com/RobertsLab/resources/issues/1375) (GitHub Issue) in the [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) adult OA gonad RNAseq data we have. The initial step for this is to assemble transcriptome. Since there is a [published genome (NCBI RefSeq GCF_002022765.2_C_virginica-3.0)](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/022/765/GCF_002022765.2_C_virginica-3.0/) for [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster), I will perform a genome-guided assembly using [`Trinity`](https://github.com/trinityrnaseq/trinityrnaseq/wiki). That process requires a sorted BAM file as input. In order to generate that file, I used [`HISAT2`](https://daehwankimlab.github.io/hisat2/). I've already generated the necessary [`HISAT2`](https://daehwankimlab.github.io/hisat2/) genome index files ([as of 20210720](https://robertslab.github.io/sams-notebook/2021/07/20/Genome-Annotations-Splice-Site-and-Exon-Extractions-for-C.virginica-GCF_002022765.2-Genome-Using-Hisat2-on-Mox.html)), which also identified/incorporated splice sites and exons, which the [`HISAT2`](https://daehwankimlab.github.io/hisat2/) alignment process requires to run.

[`fastp`](https://github.com/OpenGene/fastp)-trimmed RNAseq data from [20210714](https://robertslab.github.io/sams-notebook/2021/07/14/Trimming-C.virginica-Gonad-RNAseq-with-FastP-on-Mox.html) was used.

The [`HISAT2`](https://daehwankimlab.github.io/hisat2/) alignment job was run on Mox.


SBATCH script (GitHub):

- [20220131_cvir_hisat2-GCF_002022765.2_adult-oa-gonad.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20220131_cvir_hisat2-GCF_002022765.2_adult-oa-gonad.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20220131_cvir_hisat2-GCF_002022765.2_adult-oa-gonad
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=5-00:00:00
## Memory per node
#SBATCH --mem=200G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20220131_cvir_hisat2-GCF_002022765.2_adult-oa-gonad

## Hisat2 alignment of C.virginica adult OA gonad RNAseq to NCBI C.virginica genome assembly
## using HiSat2 index generated on 20210720.

## Expects FastQ input filenames to match *fastp-trim.20210714.fq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=40

# Index name for Hisat2 use
# Needs to match index naem used in previous Hisat2 indexing step
genome_index_name="cvir_GCF_002022765.2"

# Set output filename
sample_name="20210131-cvir-hisat2"

# Paths to programs
hisat2_dir="/gscratch/srlab/programs/hisat2-2.1.0"
hisat2="${hisat2_dir}/hisat2"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"


# Input/output files
genome_index_dir="/gscratch/srlab/sam/data/C_virginica/genomes"
fastq_dir="/gscratch/srlab/sam/data/C_virginica/RNAseq/"


# Programs associative array
declare -A programs_array
programs_array=(
[hisat2]="${hisat2}" \
[samtools_index]="${samtools} index" \
[samtools_sort]="${samtools} sort" \
[samtools_view]="${samtools} view"
)


###################################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

## Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()

# Copy Hisat2 genome index files
rsync -av "${genome_index_dir}"/${genome_index_name}*.ht2 .

# Create array of fastq R1 files
# and generate MD5 checksums file.
for fastq in "${fastq_dir}"*fastp-trim.20210714.fq.gz
do
  fastq_array_R1+=("${fastq}")
  echo "Generating checksum for ${fastq}..."
  md5sum "${fastq}" >> input_fastqs_checksums.md5
  echo "Checksum for ${fastq} completed."
  echo ""
done

# Create array of fastq R2 files
# and append to MD5 checksums file.
for fastq in "${fastq_dir}"*fastp-trim.20210714.fq.gz
do
  fastq_array_R2+=("${fastq}")
  echo "Generating checksum for ${fastq}..."
  md5sum "${fastq}" >> input_fastqs_checksums.md5
  echo "Checksum for ${fastq} completed."
  echo ""
done

# Create comma-separated lists of FastQs for Hisat2
printf -v joined_R1 '%s,' "${fastq_array_R1[@]}"
fastq_list_R1=$(echo "${joined_R1%,}")

printf -v joined_R2 '%s,' "${fastq_array_R2[@]}"
fastq_list_R2=$(echo "${joined_R2%,}")


# Hisat2 alignments
"${programs_array[hisat2]}" \
-x "${genome_index_name}" \
-1 "${fastq_list_R1}" \
-2 "${fastq_list_R2}" \
-S "${sample_name}".sam \
2> "${sample_name}"_hisat2.err

# Sort SAM files, convert to BAM, and index
${programs_array[samtools_view]} \
-@ "${threads}" \
-Su "${sample_name}".sam \
| ${programs_array[samtools_sort]} - \
-@ "${threads}" \
-o "${sample_name}".sorted.bam
${programs_array[samtools_index]} "${sample_name}".sorted.bam


# Delete unneccessary index files
rm "${genome_index_name}"*.ht2

# Delete unneded SAM files
rm ./*.sam

# Generate checksums
for file in *
do
  md5sum "${file}" >> checksums.md5
done

#######################################################################################################

# Capture program options
if [[ "${#programs_array[@]}" -gt 0 ]]; then
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

    # Handle DIAMOND BLAST menu
    elif [[ "${program}" == "diamond" ]]; then
      ${programs_array[$program]} help

    # Handle NCBI BLASTx menu
    elif [[ "${program}" == "blastx" ]]; then
      ${programs_array[$program]} -help
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
fi


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

Runtime was ~6 days, 7hrs:

![HISAT2 runtime for C.virginica adult gonad OA exposed RNAseq on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20220131_cvir_hisat2-GCF_002022765.2_adult-oa-gonad_runtime.png?raw=true)

Output folder:

- [20220131_cvir_hisat2-GCF_002022765.2_adult-oa-gonad/](https://gannet.fish.washington.edu/Atumefaciens/20220131_cvir_hisat2-GCF_002022765.2_adult-oa-gonad/)

  - BAM alignment file and corresponding BAM index file (useful for IGV):

    - [20210131-cvir-hisat2.sorted.bam](https://gannet.fish.washington.edu/Atumefaciens/20220131_cvir_hisat2-GCF_002022765.2_adult-oa-gonad/20210131-cvir-hisat2.sorted.bam) (99G)

      - MD5: `8cbd5bb64759411927de6a46785b28d6`

    - [20210131-cvir-hisat2.sorted.bam.bai](https://gannet.fish.washington.edu/Atumefaciens/20220131_cvir_hisat2-GCF_002022765.2_adult-oa-gonad/20210131-cvir-hisat2.sorted.bam.bai) (38M)

      - MD5: `92c6e7d6106ffc91ab9a5cb420376783`

  - List of input FASTQ files (and corresponding MD5 checksums)

    - [input_fastqs_checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20220131_cvir_hisat2-GCF_002022765.2_adult-oa-gonad/input_fastqs_checksums.md5) (128K)


  - Standard error output (alignment stats):

    ```
    1355938330 reads; of these:
    1355938330 (100.00%) were paired; of these:
      1342685071 (99.02%) aligned concordantly 0 times
      81131 (0.01%) aligned concordantly exactly 1 time
      13172128 (0.97%) aligned concordantly >1 times
      ----
      1342685071 pairs aligned concordantly 0 times; of these:
        585339805 (43.59%) aligned discordantly 1 time
      ----
      757345266 pairs aligned 0 times concordantly or discordantly; of these:
        1514690532 mates make up the pairs; of these:
          879327626 (58.05%) aligned 0 times
          346977576 (22.91%) aligned exactly 1 time
          288385330 (19.04%) aligned >1 times
    67.57% overall alignment rate
    ```


The overall alignment rate was surprisingly low. For a good set of RNAseq, I'd fully expect >80% of reads to align. I revisted the [`fastp` trimming performed on 20210714](https://robertslab.github.io/sams-notebook/2021/07/14/Trimming-C.virginica-Gonad-RNAseq-with-FastP-on-Mox.html) and confirmed that paired-end adaptor trimming was enabled. Additionally, the [MultiQC report from the trimming](https://gannet.fish.washington.edu/Atumefaciens/20210714_cvir_gonad_RNAseq_fastp_trimming/multiqc_report.html) shows that the post-trim read quality is good; nothing to be concerned about. Those two variables would've been the easiest things to explain a low alignment rate like this, but they don't seem to be the cause. With that being the case, I'm wondering if there's a lot of residual rRNA in the samples (which wouldn't map due to their highly repetetive nature and the fact that they would end up being mapped to multiple locations throughout the genome - leading them to be discarded when mapping).

After looking into this a bit futher, I'm wondering if [ZymoResearch's modified rRNA removal technique](https://github.com/RobertsLab/project-oyster-comparative-omics/blob/master/metadata/RNA-Seq%20Synopsis_Venkataraman_zr4059.pdf) (PDF of Zymo project summary) still doesn't work for shellfish rRNA (like other kits)... In the future, we should remember to specifically request polyA selection as the means for mRNA enrichment. It's not a huge deal, as we still have a ton of RNAseq data, but it's still a shame that a lot of the sequencing data may have ended up just capturing rRNA...

Alignments completed. Next up is to perform a genome-guided transcriptome assembly using the BAM file generated by [`HISAT2`](https://daehwankimlab.github.io/hisat2/) with [`Trinity`](https://github.com/trinityrnaseq/trinityrnaseq/wiki).