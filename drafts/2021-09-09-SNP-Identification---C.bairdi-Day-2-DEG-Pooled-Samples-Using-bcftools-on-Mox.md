---
layout: post
title: SNP Identification - C.bairdi Day 2 DEG Pooled Samples Using bcftools on Mox
date: '2021-09-09 11:23'
tags: 
  - bcftools
  - Tanner crab
  - Chionoecetes bairdi
  - Mox
  - SNP
categories: 
  - Tanner Crab RNAseq
---
After getting our the RNAseq data aligned with [`HISAT2`](https://daehwankimlab.github.io/hisat2/) on [20210908](https://robertslab.github.io/sams-notebook/2021/09/08/RNAseq-Alignments-C.bairdi-Day-2-Infected-Uninfected-Temperature-Increase-Decrease-RNAseq-to-cbai_transcriptome_v3.1.fasta-with-Hisat2-on-Mox.html), the next step was to make variant calls. I opted to do so using [`bcftools`](https://samtools.github.io/bcftools/bcftools.html#common_options) `mpileup`. Previously, this was usually done with samtools, but using [`bcftools`](https://samtools.github.io/bcftools/bcftools.html#common_options) is preferred for better downstream compatibility with other [`bcftools`](https://samtools.github.io/bcftools/bcftools.html#common_options).

The job was run on Mox and generated a [VCF file](https://samtools.github.io/hts-specs/VCFv4.2.pdf).

SBATCH script (GitHub):

- [20210909-cbai-bcftools-snp_calling.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210909-cbai-bcftools-snp_calling.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210909-cbai-bcftools-snp_calling
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=3-00:00:00
## Memory per node
#SBATCH --mem=200G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210909-cbai-bcftools-snp_calling

## Hisat2 alignment of C.bairdi RNAseq to cbai_transcriptome_v3.1 transcriptome assembly
## using HiSat2 index generated on 20210908.

## Expects FastQ input filenames to match *R[12]*.fq.gz.


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=40

# Paths to programs
bcftools_dir="/gscratch/srlab/programs/bcftools-1.13"
bcftools="${bcftools_dir}/bcftools"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"


# Input/output files
bam_dir="/gscratch/scrubbed/samwhite/outputs/20210908-cbai-hisat2-cbai_transcriptome_v3.1"
transcriptome_dir="/gscratch/srlab/sam/data/C_bairdi/transcriptomes"
transcriptome_fasta="${transcriptome_dir}"/cbai_transcriptome_v3.1.fasta
bcf_out=cbai_v3.1-SNPS.vcf

# Initialize array for BAM files
bam_array=()

# Programs associative array
declare -A programs_array
programs_array=(
[bcftools]="${bcftools}" \
[bcftools_call]="${bcftools} call" \
[bcftools_index]="${bcftools} index" \
[bcftools_mpileup]="${bcftools} mpileup" \
[bcftools_view]="${bcftools} view" \
[samtools_index]="${samtools} index" \
[samtools_sort]="${samtools} sort" \
[samtools_view]="${samtools} view"
)


###################################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017



# Create array of fastq R2 files
for bam in "${bam_dir}"/*sorted.bam
do
  bam_array+=("${bam}")
  echo "Generating checksum for ${bam}..."
  md5sum "${bam}" >> input_bam_checksums.md5
  echo "Checksum for ${bam} completed."
  echo ""
done

# Run bcftools
## Create space-separated list to pass to bcftools
bam_list=$(echo "${bam_array[*]}")


## mpileup and call SNPs.
## Generates uncompressed VCF file.
echo ""
echo "Beginning SNP calls."

${programs_array[bcftools_mpileup]} \
--fasta-ref ${transcriptome_fasta} \
${bam_list} \
--threads ${threads} \
--output-type u \
| ${programs_array[bcftools_call]} \
--output-type v \
--multiallelic-caller \
--variants-only \
--threads ${threads} \
> ${bcf_out}


echo "SNP calls complete."
echo ""


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
    # Handle samtools/bcftools help menus
    if [[ "${program}" == "samtools_index" ]] \
    || [[ "${program}" == "samtools_sort" ]] \
    || [[ "${program}" == "samtools_view" ]] \
    || [[ "${program}" == "bcftools_call" ]] \
    || [[ "${program}" == "bcftools_index" ]] \
    || [[ "${program}" == "bcftools_mpileup" ]] \
    || [[ "${program}" == "bcftools_view" ]]
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

Output folder:

- []()

