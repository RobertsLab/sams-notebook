---
layout: post
title: RNAseq Alignments - P.generosa Alignments and Alternative Transcript Identification Using Hisat2 and StringTie on Mox
date: '2022-09-14 07:14'
tags: 
  - Panopea generosa
  - geoduck
  - mox
  - hisat2
  - StringTie
  - alignment
  - RNAseq
categories: 
  - Miscellaneous
---
As part of [identifying long non-coding RNA (lncRNA) in Pacific geoduck](https://github.com/RobertsLab/resources/issues/1434)(GitHub Issue), one of the first things that I wanted to do was to gather all of our geoduck RNAseq data and align it to our geoduck genome. In addition to the alignments, some of the examples I've been following have also utilized expression levels as one aspect of the lncRNA selection criteria, so I figured I'd get this info as well.

[Trimmed RNAseq data from 20220908](https://robertslab.github.io/sams-notebook/2022/09/08/FastQ-Trimming-Geoduck-RNAseq-Data-Using-fastp-on-Mox.html) was aligned to our [_Panopea generosa_ (Pacific geoduck)](http://en.wikipedia.org/wiki/Geoduck) genome assembly, [Panopea-generosa-v1.0.fa](https://gannet.fish.washington.edu/Atumefaciens/20191105_swoose_pgen_v074_renaming/Panopea-generosa-v1.0.fa) (FastA; 914MB), using [`HISAT2`](https://daehwankimlab.github.io/hisat2/). Alternative transcripts and expression values were determined using [`StringTie`](https://ccb.jhu.edu/software/stringtie/). These were run on Mox.

Here's a summary of the process:

1. Generate necessary [`HISAT2`](https://daehwankimlab.github.io/hisat2/) reference files (e.g. splic sites, exons, genome indexes).

2. Concatenate FastQ files based on tissue/age and/or OA treatment.

3. Run [`HISAT2`](https://daehwankimlab.github.io/hisat2/) on concatenated FastQs.

4. Run [`StringTie`](https://ccb.jhu.edu/software/stringtie/) on grouped samples, with output formatted for import into Ballgown.

The SBATCH script below is very long. Skip to [RESULTS section](#results) if you want.


SBATCH script (GitHub):

- [20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=21-00:00:00
## Memory per node
#SBATCH --mem=200G
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
threads=40

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
total_samples=8

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
  sample_type=$(echo "${sample_name}" | awk -F "." '{print $1}')

  # Parse out tissue/sample types
  juvenile_treatment=$(echo "${sample_type}" | awk -F [-_] '{print $3}')
  tissue=$(echo "${sample_type}" | awk -F "-" '{print $2}')
  trueseq_tissue=$(echo "${sample_type}" | awk -F [-_] '{print $7}')


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
    [[ "${trueseq_tissue}" == "NR019" ]]
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
    [[ "${trueseq_tissue}" == "NR005" ]]
  then
    cat "${fastq}" >> concatenated-juvenile_OA-"${R1_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-juvenile_OA-${R1_fastq_naming_pattern}"
    echo ""
  elif
    [[ "${tissue}" == "larvae" ]] \
    || [[ "${trueseq_tissue}" == "NR021" ]]
  then
    cat "${fastq}" >> concatenated-larvae-"${R1_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-larvae-${R1_fastq_naming_pattern}"
    echo ""
  # Handles Geo_Pool samples
  else
    echo "Rsyincing ${fastq} to current directory"
    echo "because it does not need concatenation."
    echo ""
    rsync -av "${fastq}" .
    echo ""
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
  sample_type=$(echo "${sample_name}" | awk -F "." '{print $1}')

  # Parse out tissue/sample types
  juvenile_treatment=$(echo "${sample_type}" | awk -F [-_] '{print $3}')
  tissue=$(echo "${sample_type}" | awk -F "-" '{print $2}')
  trueseq_tissue=$(echo "${sample_type}" | awk -F [-_] '{print $7}')


  # Concatenate reads from multiple runs
  if
    [[ "${tissue}" == "ctenidia" ]] \
    || [[ "${trueseq_tissue}" == "NR012" ]]
  then
    cat "${fastq}" >> concatenated-ctenidia-"${R2_fastq_naming_pattern}"

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
    [[ "${trueseq_tissue}" == "NR019" ]]
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
    [[ "${trueseq_tissue}" == "NR005" ]]
  then
    cat "${fastq}" >> concatenated-juvenile_OA-"${R2_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-juvenile_OA-${R2_fastq_naming_pattern}"
    echo ""
  elif
    [[ "${tissue}" == "larvae" ]] \
    || [[ "${trueseq_tissue}" == "NR021" ]]
  then
    cat "${fastq}" >> concatenated-larvae-"${R2_fastq_naming_pattern}"
    echo "Concatenated ${fastq} to concatenated-larvae-${R2_fastq_naming_pattern}"
    echo ""
  # Handles Geo_Pool samples
  else
    rsync -av "${fastq}" .
  fi

done

# Check FastQ array sizes to confirm they have all expected samples
# Exit if mismatch

echo "Confirming expected number of FastQs processed..."
sum_fastqs=$((${R1_fastq_counter} + ${R2_fastq_counter}))
if [[ "${sum_fastqs}" != "${total_fastqs}" ]]
then
  echo "Expected ${total_fastqs} FastQs, but only found ${sum_fastqs}!"
  echo ""
  echo "Check original-fastq-checksums.md5 file for list of FastQs processed."
  echo ""
  exit 1
else
  echo "Great!"
  printf "%-20s %s\n" "Expected:" "${total_fastqs}"
  printf "%-20s %s\n" "Processed:" "${sum_fastqs}"
  echo ""
fi



###### Load associative array ######

for fastq in *"${fastq_pattern}"
do
  # Generate MD5 checksums for original set of FastQs
  echo "Generating MD5 checksums for ${fastq}..."
  md5sum "${fastq}" | tee --append concatenated-fastq-checksums.md5
  echo ""

  echo ""
  echo "Processing $fastq for associative array..."

  # Remove path
  sample_name="${fastq##*/}"

  # Get sample name from second "-"-delimited field
  sample_type=$(echo "${sample_name}" | awk -F "-" '{print $2}')
  echo "Sample type before eval: ${sample_type}"

  # Get sample name from second "-"-delimited field
  # Redundant command, but used to delineate juvenile OA treatment conditions
  # in if statements below.
  juvenile_treatment="${sample_type}"
  echo "Juvenile treatment before eval: ${juvenile_treatment}"

  # Get sample name from the deoduck pool samples
  gonad_pool=$(echo "${sample_name}" | awk 'BEGIN {OFS="_"; FS="_"} {print $1, $2, $3}')
  echo "Gonad pool before eval: ${gonad_pool}."


  # Set treatment condition for each sample
  # Primarily used for setting read group (RG) during BAM creation
  if
    [[ "${sample_type}" == "gonad" ]] \
    || [[ "${gonad_pool}" == "Geo_Pool_F" ]] \
    || [[ "${gonad_pool}" == "Geo_Pool_M" ]]
  then
    echo "Sample type is: $sample_type"
    treatment="gonad"
    echo "Treatment is: $treatment"
    echo ""
    if
      [[ "${sample_type}" == "gonad" ]]
    then
        if [[ ! -n ${samples_associative_array[${sample_type}]} ]]
        then
            # Append to associative array
            samples_associative_array+=(["${sample_type}"]="${treatment}")
            echo "Checking array:"
            echo ${samples_associative_array[@]}
        fi
    elif
        [[ "${gonad_pool}" == "Geo_Pool_F" ]] \
        || [[ "${gonad_pool}" == "Geo_Pool_M" ]]
    then
        if [[ ! -n ${samples_associative_array[${gonad_pool}]} ]]
        then
            # Append to associative array
            samples_associative_array+=(["${gonad_pool}"]="${treatment}")
            echo "Checking array:"
            echo ${samples_associative_array[@]}
        fi
    fi
  elif
    [[ "${sample_type}" == "juvenile_ambient" ]] \
    || [[ "${sample_type}" == "juvenile_OA" ]]
  then
    echo "Sample type is: $sample_type"
    treatment="juvenile"
    echo "Treatment is: $treatment"
    echo ""
        if [[ ! -n ${samples_associative_array[${sample_type}]} ]]
        then
            # Append to associative array
            samples_associative_array+=(["${sample_type}"]="${treatment}")
            echo "Checking array:"
            echo ${samples_associative_array[@]}
        fi
  elif
    [[ "${sample_type}" == "ctenidia" ]] \
    || [[ "${sample_type}" == "heart" ]] \
    || [[ "${sample_type}" == "larvae" ]]
  then
    echo "Sample type is: $sample_type"
    treatment="${sample_type}"
    echo "Treatment is: $treatment"
    echo ""
        if [[ ! -n ${samples_associative_array[${sample_type}]} ]]
        then
            # Append to associative array
            samples_associative_array+=(["${sample_type}"]="${treatment}")
            echo "Checking array:"
            echo ${samples_associative_array[@]}
        fi
  fi
done

# Check array size to confirm it has all expected samples
# Exit if mismatch
echo ""
echo "Checking samples_associative_array to confirm expected number of samples..."
echo ""
if [[ "${#samples_associative_array[@]}" != "${total_samples}" ]]
  then
    echo "samples_associative_array doesn't have all ${total_samples} samples."
    echo "Array has ${#samples_associative_array[@]} samples."
    echo "Please review array contents to begin troubleshooting."
    echo ""
    echo "samples_associative_array contents:"
    echo ""
    for item in "${!samples_associative_array[@]}"
    do
      printf "%s\t%s\n" "${item}" "${samples_associative_array[${item}]}"
    done
    echo ""

    exit 1
  else
    echo ""
    echo "Associative array has expected number of samples: ${#samples_associative_array[@]}/${total_samples}."
    echo ""

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

  # Create and switch to dedicated sample directory
  echo "Creating and moving into ${sample} directory."
  mkdir "${sample}" && cd "$_"
  echo ""

  # Create array of fastq R1 files
  # and generate MD5 checksums file.

  # Identify corresponding FastQ file
  # Pipe to sed replace leading "./" with "../" to manage relative FastQ path
  fastq=$(find .. -name "*${sample}*R1*.gz")

  fastq_array_R1+=("${fastq}")
  echo "Generating checksum for ${fastq}..."
  md5sum "${fastq}" | tee --append input_fastqs_checksums.md5
  echo "Checksum for ${fastq} completed."
  echo ""


  # Create array of fastq R2 files
  # and generate MD5 checksums

  # Identify corresponding FastQ file
  # Pipe to sed replace leading "./" with "../" to manage relative FastQ path
  fastq=$(find .. -name "*${sample}*R2*.gz")

  fastq_array_R2+=("${fastq}")
  echo "Generating checksum for ${fastq}..."
  md5sum "${fastq}" | tee --append input_fastqs_checksums.md5
  echo "Checksum for ${fastq} completed."
  echo ""


  # Create comma-separated lists of FastQs for Hisat2
  printf -v joined_R1 '%s,' "${fastq_array_R1[@]}"
  fastq_list_R1=$(echo "${joined_R1%,}")

  printf -v joined_R2 '%s,' "${fastq_array_R2[@]}"
  fastq_list_R2=$(echo "${joined_R2%,}")


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
```


---

#### RESULTS

Runtime was 1 day and 17.5hrs:

![Screencap of Mox job runtime emails, showing successful completion after 1 day and 17.5 hrs](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms-runtime.png?raw=true)

Output folder:

- [20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms/](https://gannet.fish.washington.edu/Atumefaciens/20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms/)

Due to the large number of files, please just browse the directory linked above. A [directory tree](#output-directory-tree) is posted below for guidance. Sub-directories have been created, and subsequent tables, for direct import into Ballgown, if desired/needed.

See the various MD5 checksum files to see which files were utilized for each step.

#### OUTPUT DIRECTORY TREE

```shell

├── 20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms.sh
├── 20220914-pgen-stringtie-Panopea-generosa-v1.0-sorted_bams-merged.bam
├── 20220914-pgen-stringtie-Panopea-generosa-v1.0-sorted_bams-merged.bam.bai
├── checksums.md5
├── concatenated-ctenidia-R1.fastp-trim.20220908.fq.gz
├── concatenated-ctenidia-R2.fastp-trim.20220908.fq.gz
├── concatenated-fastq-checksums.md5
├── concatenated-gonad-R1.fastp-trim.20220908.fq.gz
├── concatenated-gonad-R2.fastp-trim.20220908.fq.gz
├── concatenated-heart-R1.fastp-trim.20220908.fq.gz
├── concatenated-heart-R2.fastp-trim.20220908.fq.gz
├── concatenated-juvenile_ambient-R1.fastp-trim.20220908.fq.gz
├── concatenated-juvenile_ambient-R2.fastp-trim.20220908.fq.gz
├── concatenated-juvenile_OA-R1.fastp-trim.20220908.fq.gz
├── concatenated-juvenile_OA-R2.fastp-trim.20220908.fq.gz
├── concatenated-larvae-R1.fastp-trim.20220908.fq.gz
├── concatenated-larvae-R2.fastp-trim.20220908.fq.gz
├── ctenidia
│   ├── ctenidia-checksums.md5
│   ├── ctenidia.cov_refs.gtf
│   ├── ctenidia.gtf
│   ├── ctenidia_hisat2.err
│   ├── ctenidia.sorted.bam
│   ├── ctenidia.sorted.bam.bai
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── input_fastqs_checksums.md5
│   └── t_data.ctab
├── Geo_Pool_F
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── Geo_Pool_F-checksums.md5
│   ├── Geo_Pool_F.cov_refs.gtf
│   ├── Geo_Pool_F.gtf
│   ├── Geo_Pool_F_hisat2.err
│   ├── Geo_Pool_F.sorted.bam
│   ├── Geo_Pool_F.sorted.bam.bai
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── input_fastqs_checksums.md5
│   └── t_data.ctab
├── Geo_Pool_F_GGCTAC_L006_R1_001.fastp-trim.20220908.fq.gz
├── Geo_Pool_F_GGCTAC_L006_R2_001.fastp-trim.20220908.fq.gz
├── Geo_Pool_M
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── Geo_Pool_M-checksums.md5
│   ├── Geo_Pool_M.cov_refs.gtf
│   ├── Geo_Pool_M.gtf
│   ├── Geo_Pool_M_hisat2.err
│   ├── Geo_Pool_M.sorted.bam
│   ├── Geo_Pool_M.sorted.bam.bai
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── input_fastqs_checksums.md5
│   └── t_data.ctab
├── Geo_Pool_M_CTTGTA_L006_R1_001.fastp-trim.20220908.fq.gz
├── Geo_Pool_M_CTTGTA_L006_R2_001.fastp-trim.20220908.fq.gz
├── gonad
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── gonad-checksums.md5
│   ├── gonad.cov_refs.gtf
│   ├── gonad.gtf
│   ├── gonad_hisat2.err
│   ├── gonad.sorted.bam
│   ├── gonad.sorted.bam.bai
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── input_fastqs_checksums.md5
│   └── t_data.ctab
├── gtf_list.txt
├── heart
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── heart-checksums.md5
│   ├── heart.cov_refs.gtf
│   ├── heart.gtf
│   ├── heart_hisat2.err
│   ├── heart.sorted.bam
│   ├── heart.sorted.bam.bai
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── input_fastqs_checksums.md5
│   └── t_data.ctab
├── hisat2_build.err
├── juvenile_ambient
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── input_fastqs_checksums.md5
│   ├── juvenile_ambient-checksums.md5
│   ├── juvenile_ambient.cov_refs.gtf
│   ├── juvenile_ambient.gtf
│   ├── juvenile_ambient_hisat2.err
│   ├── juvenile_ambient.sorted.bam
│   ├── juvenile_ambient.sorted.bam.bai
│   └── t_data.ctab
├── juvenile_OA
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── input_fastqs_checksums.md5
│   ├── juvenile_OA-checksums.md5
│   ├── juvenile_OA.cov_refs.gtf
│   ├── juvenile_OA.gtf
│   ├── juvenile_OA_hisat2.err
│   ├── juvenile_OA.sorted.bam
│   ├── juvenile_OA.sorted.bam.bai
│   └── t_data.ctab
├── larvae
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── input_fastqs_checksums.md5
│   ├── larvae-checksums.md5
│   ├── larvae.cov_refs.gtf
│   ├── larvae.gtf
│   ├── larvae_hisat2.err
│   ├── larvae.sorted.bam
│   ├── larvae.sorted.bam.bai
│   └── t_data.ctab
├── original-fastq-checksums.md5
├── Panopea-generosa-v1.0.1.ht2
├── Panopea-generosa-v1.0.2.ht2
├── Panopea-generosa-v1.0.3.ht2
├── Panopea-generosa-v1.0.4.ht2
├── Panopea-generosa-v1.0.5.ht2
├── Panopea-generosa-v1.0.6.ht2
├── Panopea-generosa-v1.0.7.ht2
├── Panopea-generosa-v1.0.8.ht2
├── Panopea-generosa-v1.0_hisat2_exons.tab
├── Panopea-generosa-v1.0_hisat2_splice_sites.tab
├── Panopea-generosa-v1.0.stringtie.gtf
├── program_options.log
├── slurm-3898886.out
├── sorted_bams.list
└── system_path.log
```