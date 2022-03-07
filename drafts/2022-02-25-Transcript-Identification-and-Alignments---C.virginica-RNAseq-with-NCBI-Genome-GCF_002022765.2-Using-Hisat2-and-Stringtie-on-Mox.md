---
layout: post
title: Transcript Identification and Alignments - C.virginica RNAseq with NCBI Genome GCF_002022765.2 Using Hisat2 and Stringtie on Mox
date: '2022-02-25 07:16'
tags: 
  - hisat2
  - stringtie
  - Crassostrea virginica
  - Eastern oyster
  - RNAseq
  - GCF_002022765.2
categories: 
  - Miscellaneous
---
After [an additional round of trimming yesterday](https://robertslab.github.io/sams-notebook/2022/02/24/Trimming-Additional-20bp-from-C.virginica-Gonad-RNAseq-with-fastp-on-Mox.html), I needed to identify alternative transcripts in the [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) gonad RNAseq data we have. I previously used [`HISAT2`](https://daehwankimlab.github.io/hisat2/) to index the NCBI [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) genome and identify exon/splice sites [on 20210720](https://robertslab.github.io/sams-notebook/2021/07/20/Genome-Annotations-Splice-Site-and-Exon-Extractions-for-C.virginica-GCF_002022765.2-Genome-Using-Hisat2-on-Mox.html). Then, I used this genome index to run [`StringTie`](https://ccb.jhu.edu/software/stringtie/) on Mox in order to map sequencing reads to the genome/alternative isoforms.

Job was run on Mox.

SBATCH Script (GitHub):

- [20220225_cvir_stringtie_GCF_002022765.2_isoforms.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20220225_cvir_stringtie_GCF_002022765.2_isoforms.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20220225_cvir_stringtie_GCF_002022765.2_isoforms
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=3-12:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20220225_cvir_stringtie_GCF_002022765.2_isoforms


## Script using Stringtie with NCBI C.virginica genome assembly
## and HiSat2 index generated on 20210714.

## Expects FastQ input filenames to match <sample name>_R[12].fastp-trim.20bp-5prime.20220224.fq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=28

# Index name for Hisat2 use
# Needs to match index naem used in previous Hisat2 indexing step
genome_index_name="cvir_GCF_002022765.2"

# Location of Hisat2 index files
# Must keep variable name formatting, as it's used by HiSat2
HISAT2_INDEXES=$(pwd)
export HISAT2_INDEXES

# Paths to programs
hisat2_dir="/gscratch/srlab/programs/hisat2-2.1.0"
hisat2="${hisat2_dir}/hisat2"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"
stringtie="/gscratch/srlab/programs/stringtie-1.3.6.Linux_x86_64/stringtie"

# Input/output files
genome_index_dir="/gscratch/srlab/sam/data/C_virginica/genomes"
genome_gff="${genome_index_dir}/GCF_002022765.2_C_virginica-3.0_genomic.gff"
fastq_dir="/gscratch/srlab/sam/data/C_virginica/RNAseq/"
gtf_list="gtf_list.txt"
merged_bam="20220225_cvir_stringtie_GCF_002022765-sorted-bams-merged.bam"

# Declare associative array of sample names and metadata
declare -A samples_associative_array=()

# Set total number of samples (NOT number of FastQ files)
total_samples=26

# Programs associative array
declare -A programs_array
programs_array=(
[hisat2]="${hisat2}" \
[samtools_index]="${samtools} index" \
[samtools_merge]="${samtools} merge" \
[samtools_sort]="${samtools} sort" \
[samtools_view]="${samtools} view" \
[stringtie]="${stringtie}"
)


###################################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

## Load associative array
## Only need to use one set of reads to capture sample name

# Set sample counter for array verification
sample_counter=0

# Load array
for fastq in "${fastq_dir}"*_R1.fastp-trim.20bp-5prime.20220224.fq.gz
do
  # Increment counter
  ((sample_counter+=1))

  # Remove path
  sample_name="${fastq##*/}"

  # Get sample name from first _-delimited field
  sample_name=$(echo "${sample_name}" | awk -F "_" '{print $1}')
  
  # Set treatment condition for each sample
  if [[ "${sample_name}" == "S12M" ]] \
  || [[ "${sample_name}" == "S22F" ]] \
  || [[ "${sample_name}" == "S23M" ]] \
  || [[ "${sample_name}" == "S29F" ]] \
  || [[ "${sample_name}" == "S31M" ]] \
  || [[ "${sample_name}" == "S35F" ]] \
  || [[ "${sample_name}" == "S36F" ]] \
  || [[ "${sample_name}" == "S3F" ]] \
  || [[ "${sample_name}" == "S41F" ]] \
  || [[ "${sample_name}" == "S48F" ]] \
  || [[ "${sample_name}" == "S50F" ]] \
  || [[ "${sample_name}" == "S59M" ]] \
  || [[ "${sample_name}" == "S77F" ]] \
  || [[ "${sample_name}" == "S9M" ]]
  then
    treatment="exposed"
  else
    treatment="control"
  fi

  # Append to associative array
  samples_associative_array+=(["${sample_name}"]="${treatment}")

done

# Check array size to confirm it has all expected samples
# Exit if mismatch
if [[ "${#samples_associative_array[@]}" != "${sample_counter}" ]] \
|| [[ "${#samples_associative_array[@]}" != "${total_samples}" ]]
  then
    echo "samples_associative_array doesn't have all 26 samples."
    echo ""
    echo "samples_associative_array contents:"
    echo ""
    for item in "${!samples_associative_array[@]}"
    do
      printf "%s\t%s\n" "${item}" "${samples_associative_array[${item}]}"
    done

    exit
fi

# Copy Hisat2 genome index files
rsync -av "${genome_index_dir}"/${genome_index_name}*.ht2 .

for sample in "${!samples_associative_array[@]}"
do

  ## Inititalize arrays
  fastq_array_R1=()
  fastq_array_R2=()

  # Create array of fastq R1 files
  # and generated MD5 checksums file.
  for fastq in "${fastq_dir}""${sample}"*_R1.fastp-trim.20bp-5prime.20220224.fq.gz
  do
    fastq_array_R1+=("${fastq}")
    echo "Generating checksum for ${fastq}..."
    md5sum "${fastq}" >> input_fastqs_checksums.md5
    echo "Checksum for ${fastq} completed."
    echo ""
  done

  # Create array of fastq R2 files
  for fastq in "${fastq_dir}""${sample}"*_R2.fastp-trim.20bp-5prime.20220224.fq.gz
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

  # Create and switch to dedicated sample directory
  mkdir "${sample}" && cd "$_"

  # Hisat2 alignments
  # Sets read group info (RG) using samples array
  "${programs_array[hisat2]}" \
  -x "${genome_index_name}" \
  -1 "${fastq_list_R1}" \
  -2 "${fastq_list_R2}" \
  -S "${sample}".sam \
  --rg-id "${sample}" \
  --rg "SM:""${samples_associative_array[$sample]}" \
  2> "${sample}"_hisat2.err

  # Sort SAM files, convert to BAM, and index
  ${programs_array[samtools_view]} \
  -@ "${threads}" \
  -Su "${sample}".sam \
  | ${programs_array[samtools_sort]} - \
  -@ "${threads}" \
  -o "${sample}".sorted.bam
  # Index BAM
  ${programs_array[samtools_index]} "${sample}".sorted.bam


  # Run stringtie on alignments
  # Uses "-B" option to output tables intended for use in Ballgown
  # Uses "-e" option; recommended when using "-B" option.
  # Limits analysis to only reads alignments matching reference.
  "${programs_array[stringtie]}" "${sample}".sorted.bam \
  -p "${threads}" \
  -o "${sample}".gtf \
  -G "${genome_gff}" \
  -C "${sample}.cov_refs.gtf" \
  -B \
  -e

# Add GTFs to list file, only if non-empty
# Identifies GTF files that only have header
  gtf_lines=$(wc -l < "${sample}".gtf )
  if [ "${gtf_lines}" -gt 2 ]; then
    echo "$(pwd)/${sample}.gtf" >> ../"${gtf_list}"
  fi

  # Delete unneeded SAM files
  rm ./*.sam

  # Generate checksums
  for file in *
  do
    md5sum "${file}" >> ${sample}_checksums.md5
  done

  # Move up to orig. working directory
  cd ../

done

# Merge all BAMs to singular BAM for use in transcriptome assembly later
## Create list of sorted BAMs for merging
find . -name "*sorted.bam" > sorted_bams.list

## Merge sorted BAMs
${programs_array[samtools_merge]} \
-b sorted_bams.list \
${merged_bam} \
--threads ${threads}

## Index merged BAM
${programs_array[samtools_index]} ${merged_bam}



# Create singular transcript file, using GTF list file
"${programs_array[stringtie]}" --merge \
"${gtf_list}" \
-p "${threads}" \
-G "${genome_gff}" \
-o "${genome_index_name}".stringtie.gtf

# Delete unneccessary index files
rm "${genome_index_name}"*.ht2


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
  echo "Finished logging programs options."
  echo ""
fi


# Document programs in PATH (primarily for program version ID)
echo "Logging system $PATH..."
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log
echo "Finished logging system $PATH."

```


---

#### RESULTS

Runtime was a bit over two days, as expected:

![C.virginica StringTie runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20220225_cvir_stringtie_GCF_002022765.2_isoforms_runtime.png?raw=true)

NOTE: The runtime screencap indicates the job failed. Although this is technically true, the actual [`StringTie`](https://ccb.jhu.edu/software/stringtie/) job ran to completion. The script exited due to error during MD5 checksum generation (it encountered a directory instead of a file) due to poor implementation by me.

Output folder:

- [20220225_cvir_stringtie_GCF_002022765.2_isoforms/](https://gannet.fish.washington.edu/Atumefaciens/20220225_cvir_stringtie_GCF_002022765.2_isoforms/)

  - List of input FastQs and checksums (text):

    - [20220225_cvir_stringtie_GCF_002022765.2_isoforms/input_fastqs_checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20220225_cvir_stringtie_GCF_002022765.2_isoforms/input_fastqs_checksums.md5)

  - Full GTF file (GTF; 143MB):

    - [20220225_cvir_stringtie_GCF_002022765.2_isoforms/cvir_GCF_002022765.2.stringtie.gtf](https://gannet.fish.washington.edu/Atumefaciens/20220225_cvir_stringtie_GCF_002022765.2_isoforms/cvir_GCF_002022765.2.stringtie.gtf)

  - Merged BAM file (79GB):

    - [20220225_cvir_stringtie_GCF_002022765.2_isoforms/20220225_cvir_stringtie_GCF_002022765-sorted-bams-merged.bam](https://gannet.fish.washington.edu/Atumefaciens/20220225_cvir_stringtie_GCF_002022765.2_isoforms/20220225_cvir_stringtie_GCF_002022765-sorted-bams-merged.bam)

      - MD5 checksum:

        - `7912e86b241ddf49918e3eae89423898`

    - Merged BAM index file (useful for IGV):

      - [20220225_cvir_stringtie_GCF_002022765.2_isoforms/20220225_cvir_stringtie_GCF_002022765-sorted-bams-merged.bam.bai](https://gannet.fish.washington.edu/Atumefaciens/20220225_cvir_stringtie_GCF_002022765.2_isoforms/20220225_cvir_stringtie_GCF_002022765-sorted-bams-merged.bam.bai)

Since there are a large number of folders/files, the resulting directory structure for all of the [`StringTie`](https://ccb.jhu.edu/software/stringtie/) output is shown at the end of this post. Here's a description of all the file types found in each directory:

- `*.ctab`: See [`ballgown` documentation](https://github.com/alyssafrazee/ballgown) for description of these.

- `*.checksums.md5`: MD5 checksums for all files in each directory.

- `*.cov_refs.gtf`: Coverage GTF generate by [`StringTie`](https://ccb.jhu.edu/software/stringtie/) and used to generate final GTF for each sample.

- `*.gtf`: Final GTF file produced by [`StringTie`](https://ccb.jhu.edu/software/stringtie/) for each sample.

- `*_hisat2.err`: Standard error output from [`HISAT2`](https://daehwankimlab.github.io/hisat2/). Contains alignment info.

- `*.sorted.bam`: Sorted BAM alignments file produced by [`HISAT2`](https://daehwankimlab.github.io/hisat2/).

- `*.sorted.bam.bai`: BAM index file.


The [initial alignments from 20210726](https://robertslab.github.io/sams-notebook/2021/07/26/Transcript-Identification-and-Quantification-C.virginia-RNAseq-With-NCBI-Genome-GCF_002022765.2-Using-StringTie-on-Mox.html) which accidentally used untrimmed sequencing reads had some truly abysmal alignment rates (males were ~30% and females were around 45%). This round is a _marked_ improvement. The females exhibit alignment rates around what one would expect (> 80%), while the males, even though relatively low (around 57%), it is drasticalliy better than the 30% seen when using the untrimmed reads. Still, the alignment rates are consistently low/lower in males, compared to the females. Not sure of what this means, but exploring some additional avenues to investigate (e.g. possible residual rRNA, possible contamination with other organismal RNA)

Here's a table. The letter `M` or `F` in the sample name column indicates sex.

| S12M | 58.09% |
|------|--------|
| S13M | 58.44% |
| S16F | 81.08% |
| S19F | 82.05% |
| S22F | 82.16% |
| S23M | 57.06% |
| S29F | 75.92% |
| S31M | 61.12% |
| S35F | 81.95% |
| S36F | 80.60% |
| S39F | 82.52% |
| S3F  | 82.31% |
| S41F | 78.38% |
| S44F | 78.70% |
| S48M | 57.60% |
| S50F | 82.96% |
| S52F | 73.20% |
| S53F | 81.48% |
| S54F | 77.75% |
| S59M | 65.81% |
| S64M | 71.53% |
| S6M  | 57.82% |
| S76F | 82.82% |
| S77F | 84.37% |
| S7M  | 58.74% |
| S9M  | 57.95% |


```shell
.
├── [8.8K]  20220225_cvir_stringtie_GCF_002022765.2_isoforms.sh
├── [ 79G]  20220225_cvir_stringtie_GCF_002022765-sorted-bams-merged.bam
├── [ 23M]  20220225_cvir_stringtie_GCF_002022765-sorted-bams-merged.bam.bai
├── [ 457]  checksums.md5
├── [143M]  cvir_GCF_002022765.2.stringtie.gtf
├── [2.5K]  gtf_list.txt
├── [6.3K]  input_fastqs_checksums.md5
├── [4.0K]  S12M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S12M_checksums.md5
│   ├── [1.8M]  S12M.cov_refs.gtf
│   ├── [136M]  S12M.gtf
│   ├── [ 642]  S12M_hisat2.err
│   ├── [4.1G]  S12M.sorted.bam
│   ├── [2.2M]  S12M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S13M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S13M_checksums.md5
│   ├── [877K]  S13M.cov_refs.gtf
│   ├── [136M]  S13M.gtf
│   ├── [ 642]  S13M_hisat2.err
│   ├── [3.0G]  S13M.sorted.bam
│   ├── [1.4M]  S13M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S16F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 27M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S16F_checksums.md5
│   ├── [ 19M]  S16F.cov_refs.gtf
│   ├── [137M]  S16F.gtf
│   ├── [ 641]  S16F_hisat2.err
│   ├── [2.7G]  S16F.sorted.bam
│   ├── [1.3M]  S16F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S19F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 27M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S19F_checksums.md5
│   ├── [ 15M]  S19F.cov_refs.gtf
│   ├── [136M]  S19F.gtf
│   ├── [ 641]  S19F_hisat2.err
│   ├── [2.7G]  S19F.sorted.bam
│   ├── [1.2M]  S19F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S22F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 27M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S22F_checksums.md5
│   ├── [ 16M]  S22F.cov_refs.gtf
│   ├── [137M]  S22F.gtf
│   ├── [ 643]  S22F_hisat2.err
│   ├── [3.1G]  S22F.sorted.bam
│   ├── [1.4M]  S22F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S23M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S23M_checksums.md5
│   ├── [1.8M]  S23M.cov_refs.gtf
│   ├── [137M]  S23M.gtf
│   ├── [ 642]  S23M_hisat2.err
│   ├── [4.6G]  S23M.sorted.bam
│   ├── [2.5M]  S23M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S29F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S29F_checksums.md5
│   ├── [ 17M]  S29F.cov_refs.gtf
│   ├── [137M]  S29F.gtf
│   ├── [ 642]  S29F_hisat2.err
│   ├── [2.7G]  S29F.sorted.bam
│   ├── [1.3M]  S29F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S31M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S31M_checksums.md5
│   ├── [681K]  S31M.cov_refs.gtf
│   ├── [136M]  S31M.gtf
│   ├── [ 642]  S31M_hisat2.err
│   ├── [2.9G]  S31M.sorted.bam
│   ├── [1.5M]  S31M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S35F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S35F_checksums.md5
│   ├── [ 15M]  S35F.cov_refs.gtf
│   ├── [136M]  S35F.gtf
│   ├── [ 640]  S35F_hisat2.err
│   ├── [2.3G]  S35F.sorted.bam
│   ├── [1.1M]  S35F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S36F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S36F_checksums.md5
│   ├── [ 15M]  S36F.cov_refs.gtf
│   ├── [136M]  S36F.gtf
│   ├── [ 640]  S36F_hisat2.err
│   ├── [2.5G]  S36F.sorted.bam
│   ├── [1.2M]  S36F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S39F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 27M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S39F_checksums.md5
│   ├── [ 15M]  S39F.cov_refs.gtf
│   ├── [136M]  S39F.gtf
│   ├── [ 641]  S39F_hisat2.err
│   ├── [2.7G]  S39F.sorted.bam
│   ├── [1.2M]  S39F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S3F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 468]  S3F_checksums.md5
│   ├── [ 16M]  S3F.cov_refs.gtf
│   ├── [137M]  S3F.gtf
│   ├── [ 640]  S3F_hisat2.err
│   ├── [2.4G]  S3F.sorted.bam
│   ├── [1.1M]  S3F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S41F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 27M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S41F_checksums.md5
│   ├── [ 18M]  S41F.cov_refs.gtf
│   ├── [137M]  S41F.gtf
│   ├── [ 641]  S41F_hisat2.err
│   ├── [2.6G]  S41F.sorted.bam
│   ├── [1.2M]  S41F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S44F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 27M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S44F_checksums.md5
│   ├── [ 18M]  S44F.cov_refs.gtf
│   ├── [137M]  S44F.gtf
│   ├── [ 643]  S44F_hisat2.err
│   ├── [2.9G]  S44F.sorted.bam
│   ├── [1.3M]  S44F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S48M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 27M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S48M_checksums.md5
│   ├── [1.6M]  S48M.cov_refs.gtf
│   ├── [137M]  S48M.gtf
│   ├── [ 645]  S48M_hisat2.err
│   ├── [6.7G]  S48M.sorted.bam
│   ├── [3.2M]  S48M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S50F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 27M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S50F_checksums.md5
│   ├── [ 16M]  S50F.cov_refs.gtf
│   ├── [137M]  S50F.gtf
│   ├── [ 640]  S50F_hisat2.err
│   ├── [2.3G]  S50F.sorted.bam
│   ├── [1.1M]  S50F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S52F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 27M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S52F_checksums.md5
│   ├── [ 21M]  S52F.cov_refs.gtf
│   ├── [138M]  S52F.gtf
│   ├── [ 642]  S52F_hisat2.err
│   ├── [2.8G]  S52F.sorted.bam
│   ├── [1.3M]  S52F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S53F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 27M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S53F_checksums.md5
│   ├── [ 16M]  S53F.cov_refs.gtf
│   ├── [137M]  S53F.gtf
│   ├── [ 641]  S53F_hisat2.err
│   ├── [2.6G]  S53F.sorted.bam
│   ├── [1.2M]  S53F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S54F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 27M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S54F_checksums.md5
│   ├── [ 17M]  S54F.cov_refs.gtf
│   ├── [137M]  S54F.gtf
│   ├── [ 642]  S54F_hisat2.err
│   ├── [2.7G]  S54F.sorted.bam
│   ├── [1.2M]  S54F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S59M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S59M_checksums.md5
│   ├── [ 11M]  S59M.cov_refs.gtf
│   ├── [137M]  S59M.gtf
│   ├── [ 642]  S59M_hisat2.err
│   ├── [2.7G]  S59M.sorted.bam
│   ├── [1.2M]  S59M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S64M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S64M_checksums.md5
│   ├── [8.8M]  S64M.cov_refs.gtf
│   ├── [137M]  S64M.gtf
│   ├── [ 644]  S64M_hisat2.err
│   ├── [3.3G]  S64M.sorted.bam
│   ├── [2.2M]  S64M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S6M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 27M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 468]  S6M_checksums.md5
│   ├── [1.4M]  S6M.cov_refs.gtf
│   ├── [136M]  S6M.gtf
│   ├── [ 643]  S6M_hisat2.err
│   ├── [4.5G]  S6M.sorted.bam
│   ├── [2.3M]  S6M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S76F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 27M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S76F_checksums.md5
│   ├── [ 16M]  S76F.cov_refs.gtf
│   ├── [137M]  S76F.gtf
│   ├── [ 641]  S76F_hisat2.err
│   ├── [2.8G]  S76F.sorted.bam
│   ├── [1.2M]  S76F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S77F
│   ├── [8.7M]  e2t.ctab
│   ├── [ 27M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 473]  S77F_checksums.md5
│   ├── [ 17M]  S77F.cov_refs.gtf
│   ├── [137M]  S77F.gtf
│   ├── [ 643]  S77F_hisat2.err
│   ├── [3.0G]  S77F.sorted.bam
│   ├── [1.3M]  S77F.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S7M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 468]  S7M_checksums.md5
│   ├── [1.8M]  S7M.cov_refs.gtf
│   ├── [136M]  S7M.gtf
│   ├── [ 643]  S7M_hisat2.err
│   ├── [3.6G]  S7M.sorted.bam
│   ├── [1.9M]  S7M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [4.0K]  S9M
│   ├── [8.7M]  e2t.ctab
│   ├── [ 26M]  e_data.ctab
│   ├── [7.8M]  i2t.ctab
│   ├── [ 14M]  i_data.ctab
│   ├── [ 468]  S9M_checksums.md5
│   ├── [1.4M]  S9M.cov_refs.gtf
│   ├── [136M]  S9M.gtf
│   ├── [ 642]  S9M_hisat2.err
│   ├── [4.3G]  S9M.sorted.bam
│   ├── [2.2M]  S9M.sorted.bam.bai
│   └── [7.3M]  t_data.ctab
├── [ 14K]  slurm-2578858.out
└── [ 590]  sorted_bams.list
```