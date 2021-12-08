---
layout: post
title: Transcript Identification and Quantification - C.virginia RNAseq With NCBI Genome GCF_002022765.2 Using StringTie on Mox
date: '2021-07-26 07:25'
tags: 
  - StringTie
  - mox
  - Crassostrea virginica
  - Eastern oyster
  - RNAseq
  - GCF_002022765.2
categories: 
  - Miscellaneous
---
After having run [`HISAT2`](https://daehwankimlab.github.io/hisat2/) to index and identify exons and splice sites in the NCBI [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) genome (GCF_002022765.2) on [20210720](https://robertslab.github.io/sams-notebook/2021/07/20/Genome-Annotations-Splice-Site-and-Exon-Extractions-for-C.virginica-GCF_002022765.2-Genome-Using-Hisat2-on-Mox.html), the next step was to identify and quantify transcripts from the RNAseq data using [`StringTie`](https://ccb.jhu.edu/software/stringtie/).

[`StringTie`](https://ccb.jhu.edu/software/stringtie/) was run on Mox and was configured to generate output files for donwstream analysis using the R BiocConductor package [`ballgown`](https://github.com/alyssafrazee/ballgown). Used `-B` option to output tables intended for use in [`ballgown`](https://github.com/alyssafrazee/ballgown) and the `-e` option; recommended when using `-B` option, which limits analysis to only reads alignments matching reference. These options should generate a file/directory structure that looks something like this:

```
extdata/
    sample01/
        e2t.ctab
        e_data.ctab
        i2t.ctab
        i_data.ctab
        t_data.ctab
    sample02/
        e2t.ctab
        e_data.ctab
        i2t.ctab
        i_data.ctab
        t_data.ctab
    ...
    sample20/
        e2t.ctab
        e_data.ctab
        i2t.ctab
        i_data.ctab
        t_data.ctab
```

For more information on what those files are and how they are formatted, see the [`ballgown` documentation](https://github.com/alyssafrazee/ballgown).

This analysis was run on Mox.

SBATCH script (GitHub):

- [20210726_cvir_stringtie_GCF_002022765.2_isoforms.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210726_cvir_stringtie_GCF_002022765.2_isoforms.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210726_cvir_stringtie_GCF_002022765.2_isoforms
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=5-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210726_cvir_stringtie_GCF_002022765.2_isoforms

## Script using Stringtie with NCBI C.virginica genome assembly
## and HiSat2 index generated on 20210714.

## Expects FastQ input filenames to match <sample name>_R1.fastq.gz


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

# Programs associative array
declare -A programs_array
programs_array=(
[hisat2]="${hisat2}" \
[samtools_index]="${samtools} index" \
[samtools_sort]="${samtools} sort" \
[samtools_view]="${samtools} view" \
[stringtie]="${stringtie}"
)


###################################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

## Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()
names_array=()

# Copy Hisat2 genome index files
rsync -av "${genome_index_dir}"/${genome_index_name}*.ht2 .

# Create array of fastq R1 files
# and generated MD5 checksums file.
for fastq in "${fastq_dir}"*R1*.gz
do
  fastq_array_R1+=("${fastq}")
  echo "Generating checksum for ${fastq}..."
  md5sum "${fastq}" >> input_fastqs_checksums.md5
  echo "Checksum for ${fastq} completed."
  echo ""
done

# Create array of fastq R2 files
for fastq in "${fastq_dir}"*R2*.gz
do
  fastq_array_R2+=("${fastq}")
  echo "Generating checksum for ${fastq}..."
  md5sum "${fastq}" >> input_fastqs_checksums.md5
  echo "Checksum for ${fastq} completed."
  echo ""
done

# Create array of sample names
## Uses parameter substitution to strip leading path from filename
## Uses awk to parse out sample name from filename
for R1_fastq in "${fastq_dir}"*R1*.gz
do
  names_array+=("$(echo "${R1_fastq#${fastq_dir}}" | awk -F"_" '{print $1}')")
done

# Hisat2 alignments
for index in "${!fastq_array_R1[@]}"
do
  sample_name="${names_array[index]}"

  # Create and switch to dedicated sample directory
  mkdir "${sample_name}" && cd "$_"

  # Generate HiSat2 alignments
  "${programs_array[hisat2]}" \
  -x "${genome_index_name}" \
  -1 "${fastq_array_R1[index]}" \
  -2 "${fastq_array_R2[index]}" \
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

  # Run stringtie on alignments
  # Uses "-B" option to output tables intended for use in Ballgown
  # Uses "-e" option; recommended when using "-B" option.
  # Limits analysis to only reads alignments matching reference.
  "${programs_array[stringtie]}" "${sample_name}".sorted.bam \
  -p "${threads}" \
  -o "${sample_name}".gtf \
  -G "${genome_gff}" \
  -C "${sample_name}.cov_refs.gtf" \
  -B \
  -e

  # Add GTFs to list file, only if non-empty
  # Identifies GTF files that only have header
  gtf_lines=$(wc -l < "${sample_name}".gtf )
  if [ "${gtf_lines}" -gt 2 ]; then
    echo "$(pwd)/${sample_name}.gtf" >> ../"${gtf_list}"
  fi

  # Delete unneded SAM files
  rm ./*.sam


  # Generate checksums
  for file in *
  do
    md5sum "${file}" >> ${sample_name}_checksums.md5
  done

  cd ../

  # Create singular transcript file, using GTF list file
  "${programs_array[stringtie]}" --merge \
  "${gtf_list}" \
  -p "${threads}" \
  -G "${genome_gff}" \
  -o "${genome_index_name}".stringtie.gtf

done


# Delete unneccessary index files
rm "${genome_index_name}"*.ht2


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

Runtime was a little over 2.5 days:

![StringTie runtime on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210726_cvir_stringtie_GCF_002022765.2_isoforms_runtime.png?raw=true)

Output folder:

- [20210726_cvir_stringtie_GCF_002022765.2_isoforms/](https://gannet.fish.washington.edu/Atumefaciens/20210726_cvir_stringtie_GCF_002022765.2_isoforms/)

  - List of input FastQs and checksums (text):

    - [20210726_cvir_stringtie_GCF_002022765.2_isoforms/input_fastqs_checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20210726_cvir_stringtie_GCF_002022765.2_isoforms/input_fastqs_checksums.md5)

  - Full GTF file (GTF; 143MB):

    - [20210726_cvir_stringtie_GCF_002022765.2_isoforms/cvir_GCF_002022765.2.stringtie.gtf](https://gannet.fish.washington.edu/Atumefaciens/20210726_cvir_stringtie_GCF_002022765.2_isoforms/cvir_GCF_002022765.2.stringtie.gtf)

Since there are a large number of folders/files, the resulting directory structure for all of the [`StringTie`](https://ccb.jhu.edu/software/stringtie/) output is shown below. Here's a description of all the file types found in each directory:

- `*.ctab`: See [`ballgown` documentation](https://github.com/alyssafrazee/ballgown) for description of these.

- `*.checksums.md5`: MD5 checksums for all files in each directory.

- `*.cov_refs.gtf`: Coverage GTF generate by [`StringTie`](https://ccb.jhu.edu/software/stringtie/) and used to generate final GTF for each sample.

- `*.gtf`: Final GTF file produced by [`StringTie`](https://ccb.jhu.edu/software/stringtie/) for each sample.

- `*_hisat2.err`: Standard error output from [`HISAT2`](https://daehwankimlab.github.io/hisat2/). Contains alignment info.

- `*.sorted.bam`: Sorted BAM alignments file produced by [`HISAT2`](https://daehwankimlab.github.io/hisat2/).

- `*.sorted.bam.bai`: BAM index file.

Next up is to get this loaded into [`ballgown`](https://github.com/alyssafrazee/ballgown) and see how things fall out!


```shell
├── S12M
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S12M_checksums.md5
│   ├── S12M.cov_refs.gtf
│   ├── S12M.gtf
│   ├── S12M_hisat2.err
│   ├── S12M.sorted.bam
│   ├── S12M.sorted.bam.bai
│   └── t_data.ctab
├── S13M
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S13M_checksums.md5
│   ├── S13M.cov_refs.gtf
│   ├── S13M.gtf
│   ├── S13M_hisat2.err
│   ├── S13M.sorted.bam
│   ├── S13M.sorted.bam.bai
│   └── t_data.ctab
├── S16F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S16F_checksums.md5
│   ├── S16F.cov_refs.gtf
│   ├── S16F.gtf
│   ├── S16F_hisat2.err
│   ├── S16F.sorted.bam
│   ├── S16F.sorted.bam.bai
│   └── t_data.ctab
├── S19F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S19F_checksums.md5
│   ├── S19F.cov_refs.gtf
│   ├── S19F.gtf
│   ├── S19F_hisat2.err
│   ├── S19F.sorted.bam
│   ├── S19F.sorted.bam.bai
│   └── t_data.ctab
├── S22F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S22F_checksums.md5
│   ├── S22F.cov_refs.gtf
│   ├── S22F.gtf
│   ├── S22F_hisat2.err
│   ├── S22F.sorted.bam
│   ├── S22F.sorted.bam.bai
│   └── t_data.ctab
├── S23M
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S23M_checksums.md5
│   ├── S23M.cov_refs.gtf
│   ├── S23M.gtf
│   ├── S23M_hisat2.err
│   ├── S23M.sorted.bam
│   ├── S23M.sorted.bam.bai
│   └── t_data.ctab
├── S29F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S29F_checksums.md5
│   ├── S29F.cov_refs.gtf
│   ├── S29F.gtf
│   ├── S29F_hisat2.err
│   ├── S29F.sorted.bam
│   ├── S29F.sorted.bam.bai
│   └── t_data.ctab
├── S31M
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S31M_checksums.md5
│   ├── S31M.cov_refs.gtf
│   ├── S31M.gtf
│   ├── S31M_hisat2.err
│   ├── S31M.sorted.bam
│   ├── S31M.sorted.bam.bai
│   └── t_data.ctab
├── S35F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S35F_checksums.md5
│   ├── S35F.cov_refs.gtf
│   ├── S35F.gtf
│   ├── S35F_hisat2.err
│   ├── S35F.sorted.bam
│   ├── S35F.sorted.bam.bai
│   └── t_data.ctab
├── S36F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S36F_checksums.md5
│   ├── S36F.cov_refs.gtf
│   ├── S36F.gtf
│   ├── S36F_hisat2.err
│   ├── S36F.sorted.bam
│   ├── S36F.sorted.bam.bai
│   └── t_data.ctab
├── S39F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S39F_checksums.md5
│   ├── S39F.cov_refs.gtf
│   ├── S39F.gtf
│   ├── S39F_hisat2.err
│   ├── S39F.sorted.bam
│   ├── S39F.sorted.bam.bai
│   └── t_data.ctab
├── S3F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S3F_checksums.md5
│   ├── S3F.cov_refs.gtf
│   ├── S3F.gtf
│   ├── S3F_hisat2.err
│   ├── S3F.sorted.bam
│   ├── S3F.sorted.bam.bai
│   └── t_data.ctab
├── S41F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S41F_checksums.md5
│   ├── S41F.cov_refs.gtf
│   ├── S41F.gtf
│   ├── S41F_hisat2.err
│   ├── S41F.sorted.bam
│   ├── S41F.sorted.bam.bai
│   └── t_data.ctab
├── S44F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S44F_checksums.md5
│   ├── S44F.cov_refs.gtf
│   ├── S44F.gtf
│   ├── S44F_hisat2.err
│   ├── S44F.sorted.bam
│   ├── S44F.sorted.bam.bai
│   └── t_data.ctab
├── S48M
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S48M_checksums.md5
│   ├── S48M.cov_refs.gtf
│   ├── S48M.gtf
│   ├── S48M_hisat2.err
│   ├── S48M.sorted.bam
│   ├── S48M.sorted.bam.bai
│   └── t_data.ctab
├── S50F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S50F_checksums.md5
│   ├── S50F.cov_refs.gtf
│   ├── S50F.gtf
│   ├── S50F_hisat2.err
│   ├── S50F.sorted.bam
│   ├── S50F.sorted.bam.bai
│   └── t_data.ctab
├── S52F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S52F_checksums.md5
│   ├── S52F.cov_refs.gtf
│   ├── S52F.gtf
│   ├── S52F_hisat2.err
│   ├── S52F.sorted.bam
│   ├── S52F.sorted.bam.bai
│   └── t_data.ctab
├── S53F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S53F_checksums.md5
│   ├── S53F.cov_refs.gtf
│   ├── S53F.gtf
│   ├── S53F_hisat2.err
│   ├── S53F.sorted.bam
│   ├── S53F.sorted.bam.bai
│   └── t_data.ctab
├── S54F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S54F_checksums.md5
│   ├── S54F.cov_refs.gtf
│   ├── S54F.gtf
│   ├── S54F_hisat2.err
│   ├── S54F.sorted.bam
│   ├── S54F.sorted.bam.bai
│   └── t_data.ctab
├── S59M
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S59M_checksums.md5
│   ├── S59M.cov_refs.gtf
│   ├── S59M.gtf
│   ├── S59M_hisat2.err
│   ├── S59M.sorted.bam
│   ├── S59M.sorted.bam.bai
│   └── t_data.ctab
├── S64M
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S64M_checksums.md5
│   ├── S64M.cov_refs.gtf
│   ├── S64M.gtf
│   ├── S64M_hisat2.err
│   ├── S64M.sorted.bam
│   ├── S64M.sorted.bam.bai
│   └── t_data.ctab
├── S6M
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S6M_checksums.md5
│   ├── S6M.cov_refs.gtf
│   ├── S6M.gtf
│   ├── S6M_hisat2.err
│   ├── S6M.sorted.bam
│   ├── S6M.sorted.bam.bai
│   └── t_data.ctab
├── S76F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S76F_checksums.md5
│   ├── S76F.cov_refs.gtf
│   ├── S76F.gtf
│   ├── S76F_hisat2.err
│   ├── S76F.sorted.bam
│   ├── S76F.sorted.bam.bai
│   └── t_data.ctab
├── S77F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S77F_checksums.md5
│   ├── S77F.cov_refs.gtf
│   ├── S77F.gtf
│   ├── S77F_hisat2.err
│   ├── S77F.sorted.bam
│   ├── S77F.sorted.bam.bai
│   └── t_data.ctab
├── S7M
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S7M_checksums.md5
│   ├── S7M.cov_refs.gtf
│   ├── S7M.gtf
│   ├── S7M_hisat2.err
│   ├── S7M.sorted.bam
│   ├── S7M.sorted.bam.bai
│   └── t_data.ctab
├── S9M
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── S9M_checksums.md5
│   ├── S9M.cov_refs.gtf
│   ├── S9M.gtf
│   ├── S9M_hisat2.err
│   ├── S9M.sorted.bam
│   ├── S9M.sorted.bam.bai
│   └── t_data.ctab
```

