#!/bin/bash
## Job Name
#SBATCH --job-name=20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms

## Script for HiSat2 indexing of P.generosa genome assembly Panopea-generosa-v1.0,
## HiSat2 alignments, running Stringtie to identify splice sites and calculate gene/transcript expression values (FPKM),
## formatted for import into Ballgown (R/Bioconductor).

## Process part of identification of long non-coding RNAs (lnRNA) in geoduck.

###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=28

# Index name for Hisat2 use
# Needs to match index naem used in previous Hisat2 indexing step
genome_index_name="Panopea-generosa-v1.0"

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
exons="Panopea-generosa-v1.0_hisat2_exons.tab"
fastq_dir="/gscratch/scrubbed/samwhite/outputs/20220909-pgen-fastqc-fastp-mutliqc-rnaseq/"
genome_dir="/gscratch/srlab/sam/data/P_generosa/genomes"
genome_index_dir="/gscratch/srlab/sam/data/P_generosa/genomes"
genome_fasta="${genome_dir}/Panopea-generosa-v1.0.fasta"
genome_gff="${genome_index_dir}/Panopea-generosa-v1.0.a4_biotype-trna_strand_converted-no_RNAmmer.gff"
gtf_list="gtf_list.txt"
merged_bam="20220914-pgen-stringtie-Panopea-generosa-v1.0-sorted_bams-merged.bam"
splice_sites="Panopea-generosa-v1.0_hisat2_splice_sites.tab"
transcripts_gtf="${genome_dir}/Panopea-generosa-v1.0.a4_biotype-trna_strand_converted-no_RNAmmer.gtf"


# Set FastQ filename patterns
fastq_pattern="fastp-trim.20220908.fq.gz"
R1_fastq_pattern='*R1*.fastp-trim.20220908.fq.gz'
R2_fastq_pattern='*R2*.fastp-trim.20220908.fq.gz'
R1_fastq_naming_pattern="R1.${fastq_pattern}"
R2_fastq_naming_pattern="R2.${fastq_pattern}"

# Declare associative array of sample names and metadata
declare -A samples_associative_array=()

# Set total number of samples/treatments (NOT number of FastQ files)
# Used for confirming proper array population of samples_associative_array
total_samples=9

# Set total of original FastQ files
# Used for confirming all FastQs are processed.
total_fastqs=150

# Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()

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
echo "Generating Hisat2 exons file..."
"${programs_array[hisat2_exons]}" \
"${transcripts_gtf}" \
> "${exons}"
echo "Exons file created: ${exons}."
echo ""

# Create Hisat2 splice sites tab file
echo "Generating Hisat2 splice sites file..."
"${programs_array[hisat2_splice_sites]}" \
"${transcripts_gtf}" \
> "${splice_sites}"
echo "Splice sites file created: ${splice_sites}."
echo ""

# Build Hisat2 reference index using splice sites and exons
echo "Beginning HiSat2 genome indexing..."
"${programs_array[hisat2_build]}" \
"${genome_fasta}" \
"${genome_index_name}" \
--exon "${exons}" \
--ss "${splice_sites}" \
-p "${threads}" \
2> hisat2_build.err
echo "HiSat2 genome index files completed."
echo ""

# Generate checksums for all files
echo "Generating checksums..."
md5sum ./* | tee --append checksums.md5
echo ""
echo "Finished generating checksums. See file: checksums.md5"
echo ""

# Copy Hisat2 index files to my data directory for later use with StringTie
echo "Rsyncing HiSat2 genome index files to ${genome_dir}."
rsync -av "${genome_index_name}"*.ht2 "${genome_dir}"
echo "Rsync completed."
echo ""

# Create arrays of fastq R1 files and sample names
# Do NOT quote R1_fastq_pattern variable
echo "Creating array of R1 FastQ files..."

for fastq in "${fastq_dir}"${R1_fastq_pattern}
do
  fastq_array_R1+=("${fastq}")

  # Use parameter substitution to remove all text up to and including last "." from
  # right side of string.
  R1_names_array+=("${fastq%%.*}")
done

echo ""

# Create array of fastq R2 files
# Do NOT quote R2_fastq_pattern variable
echo "Creating array of R2 FastQ files..."

for fastq in "${fastq_dir}"${R2_fastq_pattern}
do
  fastq_array_R2+=("${fastq}")

  # Use parameter substitution to remove all text up to and including last "." from
  # right side of string.
  R2_names_array+=("${fastq%%.*}")
done
echo ""

# Set sample counters for array verification
R1_fastq_counter=0
R2_fastq_counter=0

# Concatenate R1 FastQ files
echo "Beginning concatenation of R1 FastQ files..."
echo ""
for fastq in "${fastq_array_R1[@]}"
do

  # Generate MD5 checksums for original set of FastQs
  echo "Generating MD5 checksum for ${fastq}..."
  md5sum "${fastq}" | tee --append original-fastq-checksums.md5
  echo ""

  # Increment counter
  ((R1_fastq_counter+=1))

  # Remove path
  sample_name="${fastq##*/}"

  # Get sample name from first "."-delimited field
  sample_name=$(echo "${sample_name}" | awk -F "." '{print $1}')

  # Parse out tissue/sample types
  juvenile_treatment=$(echo "${sample_name}" | awk -F [-_] '{print $3}')
  tissue=$(echo "${sample_name}" | awk -F "-" '{print $2}')
  trueseq_tissue=$(echo "${sample_name}" | awk -F [-_] '{print $7}')


  # Concatenate reads from multiple runs
  if
    [[ "${tissue}" == "ctenidia" ]] \
    || [[ "${trueseq_tissue}" == "NR012" ]]
  then
    cat "${fastq}" >> concatenated-ctenidia-"${R1_fastq_naming_pattern}"

    echo "Concatenated ${fastq} to concatenated-ctenidia-${R1_fastq_naming_pattern}"
    echo ""

  elif
    [[ "${tissue}" == "gonad" ]] \
    || [[ "${trueseq_tissue}" == "NR006" ]]
  then
    cat "${fastq}" >> concatenated-gonad-"${R1_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-gonad-${R1_fastq_naming_pattern}"
    echo ""
  elif
    [[ "${tissue}" == "heart" ]]
  then
    cat "${fastq}" >> concatenated-heart-"${R1_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-heart-${R1_fastq_naming_pattern}"
    echo ""
  elif
    [[ "${tissue}" == "juvenile" ]] \
    && [[ "${juvenile_treatment}" == "ambient" ]]
  then
    cat "${fastq}" >> concatenated-juvenile_ambient-"${R1_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-juvenile_ambient-${R1_fastq_naming_pattern}"
    echo ""
  elif
    [[ "${tissue}" == "juvenile" ]] \
    && [[ "${trueseq_tissue}" == "NR019" ]]
  then
    cat "${fastq}" >> concatenated-juvenile_ambient-"${R1_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-juvenile_ambient-${R1_fastq_naming_pattern}"
    echo ""
  elif
    [[ "${tissue}" == "juvenile" ]] \
    && [[ "${juvenile_treatment}" == "OA" ]]
  then
    cat "${fastq}" >> concatenated-juvenile_OA-"${R1_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-juvenile_OA-${R1_fastq_naming_pattern}"
    echo ""
  elif
    [[ "${tissue}" == "juvenile" ]] \
    && [[ "${trueseq_tissue}" == "NR005" ]]
  then
    cat "${fastq}" >> concatenated-juvenile_OA-"${R1_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-juvenile_OA-${R1_fastq_naming_pattern}"
    echo ""
  elif
    [[ "${tissue}" == "larvae" ]] \
    || [[ "${trueseq_tissue}" == "NR021" ]]
  then
    cat "${fastq}" >> concatenated-larvae-"${fastq_pattern}"
    echo "Concatenated ${fastq} to concatenated-larvae-${R1_fastq_naming_pattern}"
    echo ""
  # Handles Geo_Pool samples
  else
    rsync -av "${fastq}" .
  fi

done

echo "Finshed R1 FastQ concatenation."
echo ""
echo ""
echo ""

# Concatenate R2 FastQ files
echo "Beginning concatenation of R2 FastQ files..."
echo ""

for fastq in "${fastq_array_R2[@]}"
do

  # Generate MD5 checksums for original set of FastQs
  echo "Generating MD5 checksum for ${fastq}..."
  md5sum "${fastq}" | tee --append original-fastq-checksums.md5
  echo ""

  # Increment counter
  ((R2_fastq_counter+=1))

  # Remove path
  sample_name="${fastq##*/}"

  # Get sample name from first "."-delimited field
  sample_name=$(echo "${sample_name}" | awk -F "." '{print $1}')

  # Parse out tissue/sample types
  juvenile_treatment=$(echo "${sample_name}" | awk -F [-_] '{print $3}')
  tissue=$(echo "${sample_name}" | awk -F "-" '{print $2}')
  trueseq_tissue=$(echo "${sample_name}" | awk -F [-_] '{print $7}')


  # Concatenate reads from multiple runs
  if
    [[ "${tissue}" == "ctenidia" ]] \
    || [[ "${trueseq_tissue}" == "NR012" ]]
  then
    cat "${fastq}" >> concatenated-ctenidia-"${R1_fastq_naming_pattern}"

    echo "Concatenated ${fastq} to concatenated-ctenidia-${R2_fastq_naming_pattern}"
    echo ""

  elif
    [[ "${tissue}" == "gonad" ]] \
    || [[ "${trueseq_tissue}" == "NR006" ]]
  then
    cat "${fastq}" >> concatenated-gonad-"${R2_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-gonad-${R2_fastq_naming_pattern}"
    echo ""
  elif
    [[ "${tissue}" == "heart" ]]
  then
    cat "${fastq}" >> concatenated-heart-"${R2_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-heart-${R2_fastq_naming_pattern}"
    echo ""
  elif
    [[ "${tissue}" == "juvenile" ]] \
    && [[ "${juvenile_treatment}" == "ambient" ]]
  then
    cat "${fastq}" >> concatenated-juvenile_ambient-"${R2_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-juvenile_ambient-${R2_fastq_naming_pattern}"
    echo ""
  elif
    [[ "${tissue}" == "juvenile" ]] \
    && [[ "${trueseq_tissue}" == "NR019" ]]
  then
    cat "${fastq}" >> concatenated-juvenile_ambient-"${R2_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-juvenile_ambient-${R2_fastq_naming_pattern}"
    echo ""
  elif
    [[ "${tissue}" == "juvenile" ]] \
    && [[ "${juvenile_treatment}" == "OA" ]]
  then
    cat "${fastq}" >> concatenated-juvenile_OA-"${R2_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-juvenile_OA-${R2_fastq_naming_pattern}"
    echo ""
  elif
    [[ "${tissue}" == "juvenile" ]] \
    && [[ "${trueseq_tissue}" == "NR005" ]]
  then
    cat "${fastq}" >> concatenated-juvenile_OA-"${R2_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-juvenile_OA-${R2_fastq_naming_pattern}"
    echo ""
  elif
    [[ "${tissue}" == "larvae" ]] \
    || [[ "${trueseq_tissue}" == "NR021" ]]
  then
    cat "${fastq}" >> concatenated-larvae-"${fastq_pattern}"
    echo "Concatenated ${fastq} to concatenated-larvae-${R2_fastq_naming_pattern}"
    echo ""
  # Handles Geo_Pool samples
  else
    rsync -av "${fastq}" .
  fi

done

# Check FastQ array sizes to confirm they have all expected samples
# Exit if mismatch

echo "Confirming expeted number of FastQs processed..."
sum_fastqs=$(("${R1_fastq_counter} + "${R2_fastq_counter}))
if [[ "${sum_fastqs}" != "${total_fastqs}" ]]
then
  echo "Expected ${total_fastqs} FastQs, but only found ${sum_fastqs}!"
  echo ""
  echo "Check original-fastq-checksums.md5 file for list of FastQs processed."
  echo ""
  exit
else
  echo "Great!"
  printf "%-20s %s\n" "Expected:" "${total_fastqs}"
  printf "%-20s %s\n" "Processed:" "${sum_fastqs}"
  echo ""
fi



###### Load associative array ######

# Set sample counter for array verification
sample_counter=0

for fastq in *"${fastq_pattern}"
do
  # Generate MD5 checksums for original set of FastQs
  echo "Generating MD5 checksums for ${fastq}..."
  md5sum "${fastq}" | tee --append concatenated-fastq-checksums.md5
  echo ""

  # Increment counter
  ((sample_counter+=1))

  # Remove path
  sample_name="${fastq##*/}"

  # Get sample name from second "-"-delimited field
  sample_name=$(echo "${sample_name}" | awk -F "-" '{print $2}')

  # Get sample name from second "-"-delimited field
  # Redundant command, but used to delineate juvenile OA treatment conditions
  # in if statements below.
  juvenile_treatment="${sample_name}"

  # Get sample name from the deoduck pool samples
  gonad_pool=$(echo "${sample_name}" | awk 'BEGIN {OFS="_"; FS="_"} {print $1, $2, $3}')



  # Set treatment condition for each sample
  # Primarily used for setting read group (RG) during BAM creation
  if
    [[ "${sample_name}" == "gonad" ]] \
    || [[ "${gonad_pool}" == "Geo_Pool_F" ]] \
    || [[ "${gonad_pool}" == "Geo_Pool_M" ]]
  then
    treatment="gonad"
  elif
    [[ "${sample_name}" == "juvenile_ambient" ]] \
    || [[ "${sample_name}" == "juvenile_OA" ]]
  then
    treatment="juvenile"
  else
    treatment="${sample_name}"  
  fi

  # Append to associative array
  samples_associative_array+=(["${sample_name}"]="${treatment}")

  # Set geoduck male/female gonads
  if
    [[ "${gonad_pool}" == "Geo_Pool_F" ]]
  then
    treatment="gonad-female"
  elif
    [[ "${gonad_pool}" == "Geo_Pool_M" ]]
  then
    treatment="gonad-male"
  fi

  # Append to associative array
  samples_associative_array+=(["${gonad_pool}"]="${treatment}")
  
  # Set juvenile treatments
  if
    [[ "${juvenile_treatment}" == "juvenile_ambient" ]]
  then
    treatment="${juvenile_treatment}"
  elif
    [[ "${juvenile_treatment}" == "juvenile_OA" ]]
  then
    treatment="${juvenile_treatment}"
  fi

  # Append to associative array
  samples_associative_array+=(["${juvenile_treatment}"]="${treatment}")
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


############# BEGIN HISAT2 ALIGNMENTS ###############

# Run Hisat2 on each FastQ file
echo ""
echo "Beginning Hisat2 alignments..."
echo ""

for sample in "${!samples_associative_array[@]}"
do

  ## Inititalize arrays
  fastq_array_R1=()
  fastq_array_R2=()

  # Create array of fastq R1 files
  # and generate MD5 checksums file.
  for fastq in "${sample}"*"${R1_fastq_naming_pattern}"
  do
    fastq_array_R1+=("${fastq}")
    echo "Generating checksum for ${fastq}..."
    md5sum "${fastq}" | tee --append input_fastqs_checksums.md5
    echo "Checksum for ${fastq} completed."
    echo ""
  done

  # Create array of fastq R2 files
  # and generate MD5 checksums
  for fastq in "${sample}"*"${R2_fastq_naming_pattern}"
  do
    fastq_array_R2+=("${fastq}")
    echo "Generating checksum for ${fastq}..."
    md5sum "${fastq}" | tee --append input_fastqs_checksums.md5
    echo "Checksum for ${fastq} completed."
    echo ""
  done

  # Create comma-separated lists of FastQs for Hisat2
  printf -v joined_R1 '%s,' "${fastq_array_R1[@]}"
  fastq_list_R1=$(echo "${joined_R1%,}")

  printf -v joined_R2 '%s,' "${fastq_array_R2[@]}"
  fastq_list_R2=$(echo "${joined_R2%,}")

  # Create and switch to dedicated sample directory
  echo "Creating and moving into ${sample} directory."
  mkdir "${sample}" && cd "$_"
  echo ""

  # Hisat2 alignments
  # Sets read group info (RG) using samples array

  echo "Beginning Hisat2 alignment of ${sample}."
  "${programs_array[hisat2]}" \
  -x "${genome_index_name}" \
  -1 "${fastq_list_R1}" \
  -2 "${fastq_list_R2}" \
  -S "${sample}".sam \
  --rg-id "${sample}" \
  --rg "SM:""${samples_associative_array[$sample]}" \
  2> "${sample}"_hisat2.err
  echo ""
  echo "Hisat2 alignment of ${sample} completed."
  echo ""

  # Sort SAM files, convert to BAM, and index
  echo "Sorting ${sample}.sam and converting to ${sample}.sorted.bam..."
  ${programs_array[samtools_view]} \
  -@ "${threads}" \
  -Su "${sample}".sam \
  | ${programs_array[samtools_sort]} - \
  -@ "${threads}" \
  -o "${sample}".sorted.bam
  echo "Sorting and conversion completed."
  echo ""

  # Index BAM
  echo "Creating index of ${sample}.sorted.bam..."
  ${programs_array[samtools_index]} "${sample}".sorted.bam
  echo "Indexing completed."
  echo ""


  # Run stringtie on alignments
  # Uses "-B" option to output tables intended for use in Ballgown
  # Uses "-e" option; recommended when using "-B" option.
  # Limits analysis to only reads alignments matching reference.
  echo "Beginning StingTie on ${sample}.sorted.bam..."
  "${programs_array[stringtie]}" "${sample}".sorted.bam \
  -p "${threads}" \
  -o "${sample}".gtf \
  -G "${genome_gff}" \
  -C "${sample}.cov_refs.gtf" \
  -B \
  -e
  echo "StingTie completed for ${sample}.sorted.bam."
  echo ""

# Add GTFs to list file, only if non-empty
# Identifies GTF files that only have header
  gtf_lines=$(wc -l < "${sample}".gtf )
  if [ "${gtf_lines}" -gt 2 ]; then
    echo "Adding ${sample}.gtf to ${gtf_list}."
    echo "$(pwd)/${sample}.gtf" >> ../"${gtf_list}"
    echo "Added ${sample}.gtf to ${gtf_list}."
    echo ""
  fi

  # Delete unneeded SAM files
  echo "Removing unneeded SAM files..."
  rm ./*.sam
  echo ""

  # Generate checksums
  for file in *
  do
    echo "Generating MD5 checksums..."
    md5sum "${file}" | tee --append "${sample}"-checksums.md5
    echo ""
  done
  echo "Finished generating checksums."
  echo ""

  # Move up to orig. working directory
  echo "Returning to previous directory..."
  cd ../
  echo "Now in $(pwd)."
  echo ""

done

# Merge all BAMs to singular BAM for use in transcriptome assembly later
## Create list of sorted BAMs for merging
echo "Looking for sorted BAMs..."
find . -name "*sorted.bam" > sorted_bams.list
echo "All BAMs added to sorted_bams.list."
echo ""

## Merge sorted BAMs
echo "Merging all BAMs..."
${programs_array[samtools_merge]} \
-b sorted_bams.list \
${merged_bam} \
--threads ${threads}
echo "Finished merging BAMs."
echo "Merged into ${merged_bam}."
echo ""

## Index merged BAM
echo "Indexing ${merged_bam}..."
${programs_array[samtools_index]} ${merged_bam}
echo "Indexing completed."
echo ""



# Create singular transcript file, using GTF list file
echo "Merging StringTie GTF files..."
"${programs_array[stringtie]}" --merge \
"${gtf_list}" \
-p "${threads}" \
-G "${genome_gff}" \
-o "${genome_index_name}".stringtie.gtf
echo "Merge completed."
echo "Merged into ${genome_index_name}.stringtie.gtf."


# Generate checksums
echo "Generating MD5 checksums."
find . -type f -maxdepth 1 -exec md5sum {} + >> checksums.md5
echo "MD5 checksums completed."


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
