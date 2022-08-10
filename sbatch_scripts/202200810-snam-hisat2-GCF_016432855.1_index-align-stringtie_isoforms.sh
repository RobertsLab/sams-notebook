#!/bin/bash
## Job Name
#SBATCH --job-name=202200810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=21-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/202200810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms


## Script for HiSat2 indexing of NCBI S.namaycush genome assembly GCF_016432855.1
## aligning trimmed SRA RNAseq from 20220706, and running Stringtie to identify splice sites.

###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=28

# Index name for Hisat2 use
# Needs to match index naem used in previous Hisat2 indexing step
genome_index_name="snam-GCF_016432855.1"

# Location of Hisat2 index files
# Must keep variable name formatting, as it's used by HiSat2
HISAT2_INDEXES=$(pwd)
export HISAT2_INDEXES

# Paths to programs
hisat2_dir="/gscratch/srlab/programs/hisat2-2.1.0"
hisat2="${hisat2_dir}/hisat2"
hisat2_build="${hisat2_dir}/hisat2-build"
hisat2_exons="${hisat2_dir}/hisat2_extract_exons.py"
hisat2_splice_sites="${hisat2_dir}/hisat2_extract_splice_sites.py"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"
stringtie="/gscratch/srlab/programs/stringtie-1.3.6.Linux_x86_64/stringtie"

# Input/output files
exons="cvir_GCF_002022765.2_hisat2_exons.tab"
fastq_dir="/gscratch/srlab/sam/data/S_namaycush/RNAseq/"
genome_dir="/gscratch/srlab/sam/data/S_namaycush/genomes"
genome_index_dir="/gscratch/srlab/sam/data/S_namaycush/genomes"
genome_fasta="${genome_dir}/GCF_002022765.2_S_namaycush-3.0_genomic.fna"
genome_gff="${genome_index_dir}/GCF_002022765.2_S_namaycush-3.0_genomic.gff"
gtf_list="gtf_list.txt"
merged_bam="20220810-snam-stringtie-GCF_016432855.1-sorted_bams-merged.bam"
splice_sites="cvir_GCF_002022765.2_hisat2_splice_sites.tab"
transcripts_gtf="${genome_dir}/GCF_002022765.2_S_namaycush-3.0_genomic.gtf"

# Set FastQ naming pattern
fastq_pattern="fastq.trimmed.20220707.fq.gz"

# Declare associative array of sample names and metadata
declare -A samples_associative_array=()

# Set total number of samples (NOT number of FastQ files)
total_samples=72

# Programs associative array
declare -A programs_array
programs_array=(
[hisat2]="${hisat2}" \
[hisat2_build]="${hisat2_build}" \
[hisat2_exons]="${hisat2_exons}" \
[hisat2_splice_sites]="${hisat2_splice_sites}"
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

# Create Hisat2 exons tab file
"${programs_array[hisat2_exons]}" \
"${transcripts_gtf}" \
> "${exons}"

# Create Hisat2 splice sites tab file
"${programs_array[hisat2_splice_sites]}" \
"${transcripts_gtf}" \
> "${splice_sites}"

# Build Hisat2 reference index using splice sites and exons
"${programs_array[hisat2_build]}" \
"${genome_fasta}" \
"${genome_index_name}" \
--exon "${exons}" \
--ss "${splice_sites}" \
-p "${threads}" \
2> hisat2_build.err

# Generate checksums for all files
md5sum * >> checksums.md5

# Copy Hisat2 index files to my data directory for later use with StringTie
rsync -av "${genome_index_name}"*.ht2 "${genome_dir}"

## Load associative array
## Only need to use one set of reads to capture sample name

# Set sample counter for array verification
sample_counter=0

# Load array
for fastq in "${fastq_dir}"*"${fastq_pattern}"
do
  # Increment counter
  ((sample_counter+=1))

  # Remove path
  sample_name="${fastq##*/}"

  # Get sample name from first "."-delimited field
  sample_name=$(echo "${sample_name}" | awk -F "." '{print $1}')
  
  # Set treatment condition for each sample
  # Primarily used for setting read group (RG) during BAM creation
  if [[ "${sample_name}" == "SRR3321200" ]] \
|| [[ "${sample_name}" == "SRR3321201" ]] \
|| [[ "${sample_name}" == "SRR3321212" ]] \
|| [[ "${sample_name}" == "SRR3321217" ]] \
|| [[ "${sample_name}" == "SRR3321218" ]] \
|| [[ "${sample_name}" == "SRR3321219" ]] \
|| [[ "${sample_name}" == "SRR3321220" ]] \
|| [[ "${sample_name}" == "SRR3321221" ]] \
|| [[ "${sample_name}" == "SRR3321222" ]] \
|| [[ "${sample_name}" == "SRR3321223" ]] \
|| [[ "${sample_name}" == "SRR3321234" ]] \
|| [[ "${sample_name}" == "SRR3321243" ]] \
|| [[ "${sample_name}" == "SRR3321244" ]] \
|| [[ "${sample_name}" == "SRR3321245" ]] \
|| [[ "${sample_name}" == "SRR3321246" ]] \
|| [[ "${sample_name}" == "SRR3321247" ]] \
|| [[ "${sample_name}" == "SRR3321248" ]] \
|| [[ "${sample_name}" == "SRR3321249" ]]
  then
    treatment="lean-non_parasitized"
  elif [[ "${sample_name}" == "SRR3321202" ]] \
|| [[ "${sample_name}" == "SRR3321203" ]] \
|| [[ "${sample_name}" == "SRR3321224" ]] \
|| [[ "${sample_name}" == "SRR3321225" ]] \
|| [[ "${sample_name}" == "SRR3321226" ]] \
|| [[ "${sample_name}" == "SRR3321227" ]] \
|| [[ "${sample_name}" == "SRR3321228" ]] \
|| [[ "${sample_name}" == "SRR3321229" ]] \
|| [[ "${sample_name}" == "SRR3321250" ]] \
|| [[ "${sample_name}" == "SRR3321251" ]] \
|| [[ "${sample_name}" == "SRR3321252" ]] \
|| [[ "${sample_name}" == "SRR3321253" ]] \
|| [[ "${sample_name}" == "SRR3321254" ]] \
|| [[ "${sample_name}" == "SRR3321255" ]] \
|| [[ "${sample_name}" == "SRR3321256" ]] \
|| [[ "${sample_name}" == "SRR3321267" ]] \
|| [[ "${sample_name}" == "SRR3321270" ]] \
|| [[ "${sample_name}" == "SRR3321271" ]]
  then
    treatment="siscowet-non_parasitized"
  elif
  [[ "${sample_name}" == "SRR3321204" ]] \
|| [[ "${sample_name}" == "SRR3321205" ]] \
|| [[ "${sample_name}" == "SRR3321206" ]] \
|| [[ "${sample_name}" == "SRR3321207" ]] \
|| [[ "${sample_name}" == "SRR3321208" ]] \
|| [[ "${sample_name}" == "SRR3321209" ]] \
|| [[ "${sample_name}" == "SRR3321230" ]] \
|| [[ "${sample_name}" == "SRR3321231" ]] \
|| [[ "${sample_name}" == "SRR3321232" ]] \
|| [[ "${sample_name}" == "SRR3321233" ]] \
|| [[ "${sample_name}" == "SRR3321235" ]] \
|| [[ "${sample_name}" == "SRR3321236" ]] \
|| [[ "${sample_name}" == "SRR3321257" ]] \
|| [[ "${sample_name}" == "SRR3321258" ]] \
|| [[ "${sample_name}" == "SRR3321259" ]] \
|| [[ "${sample_name}" == "SRR3321260" ]] \
|| [[ "${sample_name}" == "SRR3321261" ]] \
|| [[ "${sample_name}" == "SRR3321262" ]]
  then
    treatment="lean-parasitized"
  else
    treatment="siscowet-parasitized"  
  fi

  # Append to associative array
  samples_associative_array+=(["${sample_name}"]="${treatment}")

done

# Check array size to confirm it has all expected samples
# Exit if mismatch
if [[ "${#samples_associative_array[@]}" != "${sample_counter}" ]] \
|| [[ "${#samples_associative_array[@]}" != "${total_samples}" ]]
  then
    echo "samples_associative_array doesn't have all ${total_samples} samples."
    echo ""
    echo "samples_associative_array contents:"
    echo ""
    for item in "${!samples_associative_array[@]}"
    do
      printf "%s\t%s\n" "${item}" "${samples_associative_array[${item}]}"
    done

    exit
fi

# Run Hisat2 on each FastQ file
for sample in "${!samples_associative_array[@]}"
do

  fastq=$("${fastq_dir}""${sample}"*"${fastq_pattern}")

  # Create and switch to dedicated sample directory
  mkdir "${sample}" && cd "$_"

  # Hisat2 alignments
  # Sets read group info (RG) using samples array
  "${programs_array[hisat2]}" \
  -x "${genome_index_name}" \
  -U "${fastq}" \
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
