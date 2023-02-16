#!/bin/bash
## Job Name
#SBATCH --job-name=20230216-pver-stringtie-Pver_genome_assembly_v1.0-isoforms
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=12-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230216-pver-stringtie-Pver_genome_assembly_v1.0-isoforms


## Script using Stringtie with P.verrucosa v1.0 genome assembly
## and HiSat2 index generated on 20230131.

## Genome and GFF from here: http://pver.reefgenomics.org/download/

## GTF generated on 20230127 by SJW:
## https://robertslab.github.io/sams-notebook/2023/01/27/Data-Wrangling-P.verrucosa-Genome-GFF-to-GTF-Using-gffread.html

## HiSat2 index generated on 20230131 by SJW:
## https://robertslab.github.io/sams-notebook/2023/01/31/Genome-Indexing-P.verrucosa-v1.0-Assembly-with-HiSat2-on-Mox.html

## Using trimmed FastQs from 20230215.

## Expects FastQ input filenames to match <sample name>_R[12].fastp-trim.20230215.fq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set total number of SAMPLES (NOT number of FastQ files)
total_samples=32

# Set number of CPUs to use
threads=28

# Index name for Hisat2 use
# Needs to match index naem used in previous Hisat2 indexing step
genome_index_name="Pver_genome_assembly_v1.0"

# HiSat2 indexes tarball
index_tarball="Pver_genome_assembly_v1.0-hisat2-indices.tar.gz"

# Set input FastQ patterns
R1_fastq_pattern='*R1*fq.gz'
fastq_pattern='*.fastp-trim.20230215.fq.gz'

# Location of Hisat2 index files
# Must keep variable name formatting, as it's used by HiSat2
HISAT2_INDEXES=$(pwd)
export HISAT2_INDEXES

# Paths to programs
gffcompare="/gscratch/srlab/programs/gffcompare-0.12.6.Linux_x86_64/gffcompare"
hisat2_dir="/gscratch/srlab/programs/hisat2-2.1.0"
hisat2="${hisat2_dir}/hisat2"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"
stringtie="/gscratch/srlab/programs/stringtie-1.3.6.Linux_x86_64/stringtie"

# Input/output files
genome_index_dir="/gscratch/srlab/sam/data/P_verrucosa/genomes"
genome_gff="${genome_index_dir}/Pver_genome_assembly_v1.0.gff3"
fastq_dir="/gscratch/srlab/sam/data/P_verrucosa/RNAseq/"
gtf_list="gtf_list.txt"
merged_bam="20230216-pver-stringtie-pver_v1.0-sorted-bams-merged.bam"

# Declare associative array of sample names and metadata
declare -A samples_associative_array=()

# Programs associative array
declare -A programs_array
programs_array=(
[gffcompare]="${gffcompare}" \
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
# DO NOT QUOTE ${R1_fastq_pattern} - WILL NOT POPULATE ARRAY!
for fastq in "${fastq_dir}"${R1_fastq_pattern}
do
  # Increment counter
  ((sample_counter+=1))

  # Remove path
  sample_name="${fastq##*/}"

  # Get sample name from first _-delimited field
  sample_name=$(echo "${sample_name}" | awk -F "_" '{print $1}')
  
  # Set treatment condition for each sample
  # Used for setting read group (@RG) in SAM files
  if [[ "${sample_name}" == "C17" ]] || \
[[ "${sample_name}" == "C18" ]] || \
[[ "${sample_name}" == "C19" ]] || \
[[ "${sample_name}" == "C20" ]] || \
[[ "${sample_name}" == "C21" ]] || \
[[ "${sample_name}" == "C22" ]] || \
[[ "${sample_name}" == "C23" ]] || \
[[ "${sample_name}" == "C24" ]] || \
[[ "${sample_name}" == "C25" ]] || \
[[ "${sample_name}" == "C26" ]] || \
[[ "${sample_name}" == "C27" ]] || \
[[ "${sample_name}" == "C28" ]] || \
[[ "${sample_name}" == "C29" ]] || \
[[ "${sample_name}" == "C30" ]] || \
[[ "${sample_name}" == "C31" ]] || \
[[ "${sample_name}" == "C32" ]];
  then
    treatment="control"
  else
    treatment="enriched"
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

# Copy Hisat2 genome index files
echo ""
echo "Transferring HiSat2 index file now."
echo ""
rsync -av "${genome_index_dir}/${index_tarball}" .
echo ""

# Unpack Hisat2 index files
echo ""
echo "Unpacking Hisat2 index tarball: ${index_tarball}..."
echo ""
tar -xzvf ${index_tarball}
echo "Finished unpacking ${index_tarball}"
echo ""

#### BEGIN HISAT2 ALIGNMENTS ####
echo "Beginning HiSat2 alignments and StringTie analysis..."
echo ""
for sample in "${!samples_associative_array[@]}"
do

  ## Inititalize arrays
  fastq_array_R1=()
  fastq_array_R2=()

  # Create array of fastq R1 files
  # and generated MD5 checksums file.

  # DO NOT QUOTE ${fastq_pattern} 
  for fastq in "${fastq_dir}""${sample}"*_R1${fastq_pattern}
  do
    fastq_array_R1+=("${fastq}")
    echo "Generating checksum for ${fastq}..."
    md5sum "${fastq}" >> input_fastqs_checksums.md5
    echo "Checksum for ${fastq} completed."
    echo ""
  done

  # Create array of fastq R2 files
  # DO NOT QUOTE ${fastq_pattern} 
  for fastq in "${fastq_dir}""${sample}"*_R2${fastq_pattern}
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
  echo ""
  echo "Creating ${sample} directory."
  mkdir "${sample}" && cd "$_"
  echo ""
  echo "Now in ${sample} directory."

  # HiSat2 alignments
  # Sets read group info (RG) using samples array
  echo ""
  echo "Running HiSat2..."
  "${programs_array[hisat2]}" \
  -x "${genome_index_name}" \
  -1 "${fastq_list_R1}" \
  -2 "${fastq_list_R2}" \
  -S "${sample}".sam \
  --rg-id "${sample}" \
  --rg "SM:""${samples_associative_array[$sample]}" \
  2> "${sample}-hisat2_stats.txt"
  echo ""
  echo "Hisat2 for  ${fastq_list_R1} and ${fastq_list_R2} complete."
  echo ""

  # Sort SAM files, convert to BAM, and index
  echo ""
  echo "Sorting ${sample}.sam..."
  echo ""
  ${programs_array[samtools_view]} \
  -@ "${threads}" \
  -Su "${sample}".sam \
  | ${programs_array[samtools_sort]} - \
  -@ "${threads}" \
  -o "${sample}".sorted.bam
  echo "Created "${sample}".sorted.bam"
  echo ""


  # Index BAM
  echo ""
  echo "Indexing ${sample}.sorted.bam..."
  ${programs_array[samtools_index]} "${sample}".sorted.bam
  echo ""
  echo "Indexing complete for ${sample}.sorted.bam."
  echo ""

#### END HISAT2 ALIGNMENTS ####

#### BEGIN STRINGTIE ####

  # Run stringtie on alignments
  # Uses "-B" option to output tables intended for use in Ballgown
  # Uses "-e" option; recommended when using "-B" option.
  # Limits analysis to only reads alignments matching reference.
  echo "Beginning StringTie analysis on ${sample}.sorted.bam."
  echo ""
  "${programs_array[stringtie]}" "${sample}".sorted.bam \
  -p "${threads}" \
  -o "${sample}".gtf \
  -G "${genome_gff}" \
  -C "${sample}.cov_refs.gtf" \
  -B \
  -e
  echo "StringTie analysi finished for ${sample}.sorted.bam."
#### END STRINGTIE ####

# Add GTFs to list file, only if non-empty
# Identifies GTF files that only have header
  echo ""
  echo "Adding ${sample}.gtf to ../${gtf_list}."
  gtf_lines=$(wc -l < "${sample}".gtf )
  if [ "${gtf_lines}" -gt 2 ]; then
    echo "$(pwd)/${sample}.gtf" >> ../"${gtf_list}"
  fi
  echo ""

  # Delete unneeded SAM files
  echo "Removing any SAM files."
  echo ""
  rm ./*.sam

  # Generate checksums
  for file in *
  do
    echo ""
    echo "Generating MD5 checksum for ${file}."
    echo ""
    md5sum "${file}" | tee --append "${sample}_checksums.md5"
    echo ""
    echo "${file} checksum added to ${sample}_checksums.md5."
    echo ""
  done

  # Move up to orig. working directory
  echo "Moving to original working directory."
  echo ""
  cd ../
  echo "Now in $(pwd)."
  echo ""

done

echo "Finished all HiSat2 alignments and StringTie analysis."
echo ""


#### BEGIN MERGING BAMs ####

# Merge all BAMs to singular BAM for use in transcriptome assembly later
## Create list of sorted BAMs for merging
echo ""
echo "Creating list file of sorted BAMs..."
find . -name "*sorted.bam" > sorted_bams.list
echo "List of BAMs created: sorted_bams.list"
echo ""

## Merge sorted BAMs
echo "Merging all BAM files..."
echo ""
${programs_array[samtools_merge]} \
-b sorted_bams.list \
${merged_bam} \
--threads ${threads}
echo ""
echo "Finished creating ${merged_bam}."

#### END MERGING BAMs ####

#### BEGIN INDEXING MERGED BAM ####

## Index merged BAM
echo ""
echo "Indexing ${merged_bam}..."
echo ""
${programs_array[samtools_index]} ${merged_bam}
echo "Finished indexing ${merged_bam}."
echo ""

#### END INDEXING MERGED BAM ####

#### BEGIN MERGE STRINGTIE GTFs ####

# Create singular transcript file, using GTF list file
echo "Merging GTFs..."
echo ""
"${programs_array[stringtie]}" --merge \
"${gtf_list}" \
-p "${threads}" \
-G "${genome_gff}" \
-o "${genome_index_name}.stringtie.gtf"
echo ""
echo "Finished merging GTFs into ${genome_index_name}.stringtie.gtf"
echo ""
#### END MERGE STRINGTIE GTFs ####

# Delete unneccessary index files
echo ""
echo "Removing HiSat2 genome index files..."
echo ""
rm "${genome_index_name}"*.ht2
echo "All genome index files removed."
echo ""

#### BEGIN GFFCOMPARE ####
echo ""
echo "Beginning gffcompare..."
echo ""
"${programs_array[gffcompare]}" \
-r "${genome_gff}" \
-o "${genome_index_name}-gffcmp" \
"${genome_index_name}.stringtie.gtf"
echo ""
echo "Finished gffcompare"
echo ""

#### END GFFCOMPARE ####

# Generate checksums
for file in *
do
  echo ""
  echo "Generating checksum for ${file}..."
  echo ""
  md5sum "${file}" | tee --append checksums.md5
  echo ""
  echo "Checksum generated."
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
