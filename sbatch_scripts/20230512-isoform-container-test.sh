#!/bin/bash
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
total_samples=1

# Set number of CPUs to use
threads=40

# Set lncRNA minimum length
min_lncRNA_length=200

# Average read length
read_length=130

# Index name for Hisat2 use
# Needs to match index name used in previous Hisat2 indexing step
genome_index_name="Pver_genome_assembly_v1.0"

# Set input FastQ patterns
R1_fastq_pattern='*_R1*fq.gz'
R2_fastq_pattern='*_R2*fq.gz'

# Location of Hisat2 index files
# Must keep variable name formatting, as it's used by HiSat2
HISAT2_INDEXES=$(pwd)
export HISAT2_INDEXES

# Paths to programs
cpc2="CPC2.py"
prepDE="prepDE.py"

# Input files/directories
genome_index_dir="/gscratch/coenv/samwhite/data/P_verrucosa/genomes"
genome_fasta="${genome_index_dir}/Pver_genome_assembly_v1.0.fasta"
genome_gff="${genome_index_dir}/Pver_genome_assembly_v1.0-valid.gff3"
gffcompare_dir="gffcompare"
gffcompare_gtf="${gffcompare_dir}/${genome_index_name}-gffcmp.annotated.gtf"
fastq_dir="/gscratch/coenv/samwhite/data/P_verrucosa/RNAseq/"
index_tarball="Pver_genome_assembly_v1.0-hisat2-indices.tar.gz"

# Output files/directories
gtf_list="gtf_list.txt"
merged_bam="20230512-pver-stringtie-Pver_genome_assembly_v1.0-sorted_bams-merged.bam"
lncRNAs_gtf=20230512-pver-lncRNA.gtf
lncRNA_candidates=putative-lncRNA.gtf
lncRNA_candidates_bed=putative-lncRNA.bed
lncRNA_candidates_fasta=putatutive-lncRNA.fasta
lncRNA_ids=lncRNA-IDs.txt
lncRNA_stringtie_gtf=pgen-lncRNA-stringtie.gtf
cpc2_table=cpc2_output_table

# Declare associative array of sample names and metadata
declare -A samples_associative_array=()

# Programs associative array
declare -A programs_array
programs_array=(
[bedtools_getfasta]="bedtools getfasta" \
[cpc2]="${cpc2}" \
[gffcompare]="gffcompare" \
[hisat2]="hisat2" \
[prepDE]="${prepDE}" \
[samtools_index]="samtools index" \
[samtools_merge]="samtools merge" \
[samtools_sort]="samtools sort" \
[samtools_view]="samtools view" \
[stringtie]="stringtie"
)

# Set working directory
top_dir=$(pwd)

# tee test
/usr/bin/which tee

# Test existence of container programs location
cd /gscratch/srlab/programs
ls -l

# See if which can find hisat2
# which should be in system $PATH in container.
/usr/bin/which hisat2

# See if array is populated
echo "testing array:"

"${programs_array[hisat2]}" -h

####################################################################################################
#
## Exit script if any command fails
#set -e
#
## SegFault fix?
#export THREADS_DAEMON_MODEL=1
#
### Load associative array
### Only need to use one set of reads to capture sample name
#
## Set sample counter for array verification
#sample_counter=0
#
## Load array
## DO NOT QUOTE ${R1_fastq_pattern} - WILL NOT POPULATE ARRAY!
#for fastq in "${fastq_dir}"${R1_fastq_pattern}
#do
#  # Increment counter
#  ((sample_counter+=1))
#
#  # Remove path
#  sample_name="${fastq##*/}"
#
#  # Get sample name from first _-delimited field
#  sample_name=$(echo "${sample_name}" | awk -F "_" '{print $1}')
#  
#  # Set treatment condition for each sample
#  # Used for setting read group (@RG) in SAM files
#  if [[ "${sample_name}" == "C17" ]] || \
#[[ "${sample_name}" == "C18" ]] || \
#[[ "${sample_name}" == "C19" ]] || \
#[[ "${sample_name}" == "C20" ]] || \
#[[ "${sample_name}" == "C21" ]] || \
#[[ "${sample_name}" == "C22" ]] || \
#[[ "${sample_name}" == "C23" ]] || \
#[[ "${sample_name}" == "C24" ]] || \
#[[ "${sample_name}" == "C25" ]] || \
#[[ "${sample_name}" == "C26" ]] || \
#[[ "${sample_name}" == "C27" ]] || \
#[[ "${sample_name}" == "C28" ]] || \
#[[ "${sample_name}" == "C29" ]] || \
#[[ "${sample_name}" == "C30" ]] || \
#[[ "${sample_name}" == "C31" ]] || \
#[[ "${sample_name}" == "C32" ]];
#  then
#    treatment="control"
#  else
#    treatment="enriched"
#  fi
#
#  # Append to associative array
#  samples_associative_array+=(["${sample_name}"]="${treatment}")
#
#done
#
## Check array size to confirm it has all expected samples
## Exit if mismatch
#if [[ "${#samples_associative_array[@]}" != "${sample_counter}" ]] \
#|| [[ "${#samples_associative_array[@]}" != "${total_samples}" ]]
#  then
#    echo "samples_associative_array doesn't have all ${total_samples} samples."
#    echo ""
#    echo "samples_associative_array contents:"
#    echo ""
#    for item in "${!samples_associative_array[@]}"
#    do
#      printf "%s\t%s\n" "${item}" "${samples_associative_array[${item}]}"
#    done
#
#    exit
#fi
#
## Copy Hisat2 genome index files
#echo ""
#echo "Transferring HiSat2 index file now."
#echo ""
#rsync -v "${genome_index_dir}/${index_tarball}" .
#echo ""
#
## Unpack Hisat2 index files
#echo ""
#echo "Unpacking Hisat2 index tarball: ${index_tarball}..."
#echo ""
#tar -xzvf ${index_tarball}
#echo "Finished unpacking ${index_tarball}"
#echo ""
#
##### BEGIN HISAT2 ALIGNMENTS ####
#echo "Beginning HiSat2 alignments and initial StringTie analysis..."
#echo ""
#for sample in "${!samples_associative_array[@]}"
#do
#
#  ## Inititalize arrays
#  fastq_array_R1=()
#  fastq_array_R2=()
#
#  # Create array of fastq R1 files
#  # and generated MD5 checksums file.
#  
#
#  # DO NOT QUOTE ${fastq_pattern} 
#  for fastq in "${fastq_dir}"${R1_fastq_pattern}
#  do
#
#    # Remove path
#    sample_name="${fastq##*/}"
#
#    # Get sample name from first _-delimited field
#    sample_name=$(echo "${sample_name}" | awk -F "_" '{print $1}')
#
#    # Check sample names for match
#    if [[ "${sample_name}" == "${sample}" ]]
#    then
#      echo "Now working on ${sample} Read 1 FastQs."
#
#      fastq_array_R1+=("${fastq}")
#
#      echo "Generating checksum for ${fastq}..."
#
#      md5sum "${fastq}" >> input_fastqs_checksums.md5
#
#      echo "Checksum for ${fastq} completed."
#      echo ""
#    fi
#
#  done
#
#  # Create array of fastq R2 files
#  # DO NOT QUOTE ${fastq_pattern} 
#  for fastq in "${fastq_dir}"${R2_fastq_pattern}
#  do
#    # Remove path
#    sample_name="${fastq##*/}"
#
#    # Get sample name from first _-delimited field
#    sample_name=$(echo "${sample_name}" | awk -F "_" '{print $1}')
#
#    # Check sample names for match
#    if [[ "${sample_name}" == "${sample}" ]]
#    then
#      echo "Now working on ${sample} Read 2 FastQs."
#
#      fastq_array_R2+=("${fastq}")
#
#      echo "Generating checksum for ${fastq}..."
#
#      md5sum "${fastq}" >> input_fastqs_checksums.md5
#      
#      echo "Checksum for ${fastq} completed."
#      echo ""
#    fi
#  done
#
#  echo "Checksums for ${sample} Read 1 and 2 completed."
#
#  # Create comma-separated lists of FastQs for Hisat2
#  printf -v joined_R1 '%s,' "${fastq_array_R1[@]}"
#  fastq_list_R1=$(echo "${joined_R1%,}")
#
#  printf -v joined_R2 '%s,' "${fastq_array_R2[@]}"
#  fastq_list_R2=$(echo "${joined_R2%,}")
#
#  # Create and switch to dedicated sample directory
#  echo ""
#  echo "Creating ${sample} directory."
#  mkdir "${sample}" && cd "$_"
#  echo "Now in ${sample} directory."
#
#  # HiSat2 alignments
#  # Sets read group info (RG) using samples array
#  # Directs standard error (which contains the HiSat2 stats)
#  # to a file and to the screen, so if there's an actual error,
#  # it will be caught in SLURM output file.
#  echo ""
#  echo "Running HiSat2 for sample ${sample}."
#  "${programs_array[hisat2]}" \
#  -x "${genome_index_name}" \
#  -1 "${fastq_list_R1}" \
#  -2 "${fastq_list_R2}" \
#  -S "${sample}".sam \
#  --rg-id "${sample}" \
#  --rg "SM:""${samples_associative_array[$sample]}" \
#  --threads "${threads}" \
#  2> "${sample}-hisat2_stats.txt"
#  echo ""
#  echo "Hisat2 for  ${fastq_list_R1} and ${fastq_list_R2} complete."
#  echo ""
#
#  # Sort SAM files and convert to BAM
#  echo ""
#  echo "Sorting ${sample}.sam and creating sorted BAM."
#  echo ""
#  ${programs_array[samtools_view]} \
#  -@ "${threads}" \
#  -Su "${sample}".sam \
#  | ${programs_array[samtools_sort]} - \
#  -@ "${threads}" \
#  -o "${sample}".sorted.bam
#  echo "Created ${sample}.sorted.bam"
#  echo ""
#
#
#  # Index BAM
#  echo ""
#  echo "Indexing ${sample}.sorted.bam..."
#  ${programs_array[samtools_index]} "${sample}".sorted.bam
#  echo ""
#  echo "Indexing complete for ${sample}.sorted.bam."
#  echo ""
#
#  echo ""
#  echo "HiSat2 completed for sample ${sample}."
#  echo ""
#
##### END HISAT2 ALIGNMENTS ####
#
##### BEGIN STRINGTIE ####
#
#  # Run stringtie on alignments
#  echo "Beginning StringTie analysis on ${sample}.sorted.bam."
#  "${programs_array[stringtie]}" "${sample}".sorted.bam \
#  -p "${threads}" \
#  -o "${sample}".gtf \
#  -G "${genome_gff}" \
#  -C "${sample}.cov_refs.gtf"
#  
#  echo "StringTie analysis finished for ${sample}.sorted.bam."
#  echo ""
##### END STRINGTIE ####
#
## Add GTFs to list file, only if non-empty
## Identifies GTF files that only have header
#  echo ""
#  echo "Adding ${sample}.gtf to ../${gtf_list}."
#
#  gtf_lines=$(wc -l < "${sample}".gtf )
#
#  if [ "${gtf_lines}" -gt 2 ]; then
#    echo "$(pwd)/${sample}.gtf" >> ../"${gtf_list}"
#  fi
#
#  echo ""
#
#  # Delete unneeded SAM files
#  echo "Removing SAM files."
#  echo ""
#  rm ./*.sam
#
#  echo "Finished HiSat2 alignments and StringTie analysis for ${sample} FastQs."
#  echo ""
#
#  # Move up to orig. working directory
#  echo "Moving to original working directory."
#  echo ""
#
#  cd ../
#
#  echo "Now in $(pwd)."
#  echo ""
#
#done
#
#echo "Finished all HiSat2 alignments and StringTie analysis."
#echo ""
#
#
##### BEGIN MERGING BAMs ####
#
## Merge all BAMs to singular BAM for use in transcriptome assembly later
### Create list of sorted BAMs for merging
#echo ""
#echo "Creating list file of sorted BAMs..."
#
#find . -name "*sorted.bam" > sorted_bams.list
#
#echo "List of BAMs created: sorted_bams.list"
#echo ""
#
### Merge sorted BAMs
#echo "Merging all BAM files..."
#echo ""
#
#${programs_array[samtools_merge]} \
#-b sorted_bams.list \
#${merged_bam} \
#--threads ${threads}
#
#echo ""
#echo "Finished creating ${merged_bam}."
#
##### END MERGING BAMs ####
#
##### BEGIN INDEXING MERGED BAM ####
#
### Index merged BAM
#echo ""
#echo "Indexing ${merged_bam}..."
#echo ""
#
#${programs_array[samtools_index]} ${merged_bam}
#
#echo "Finished indexing ${merged_bam}."
#echo ""
#
##### END INDEXING MERGED BAM ####
#
##### BEGIN MERGE STRINGTIE GTFs ####
#
## Create singular transcript file, using GTF list file
#echo "Merging GTFs..."
#echo ""
#
#"${programs_array[stringtie]}" --merge \
#"${gtf_list}" \
#-p "${threads}" \
#-G "${genome_gff}" \
#-o "${genome_index_name}.stringtie.gtf"
#
#echo ""
#echo "Finished merging GTFs into ${genome_index_name}.stringtie.gtf"
#echo ""
##### END MERGE STRINGTIE GTFs ####
#
#
##### BEGIN ESTIMATE TRANSCRIPT ABUNDANCE STRINGTIE GTFs ####
#
#echo "Beginning StringTie transcript abundance estimates..."
#echo ""
#for sample in "${!samples_associative_array[@]}"
#do
#
#  
#  # Switch to dedicated sample directory
#  echo ""
#  echo "Switching to ${sample} directory."
#  cd "${sample}"
#  echo "Now in ${PWD}."
#
##### BEGIN STRINGTIE ####
#
#  # Run stringtie on alignments
#  # Uses merged Stringtie GTF
#  # `-B` option enables abundance estimates with Ballgown table outputs
#  echo "Beginning StringTie analysis on ${sample}.sorted.bam."
#  "${programs_array[stringtie]}" "${sample}".sorted.bam \
#  -p "${threads}" \
#  -o "${sample}-abundance.gtf" \
#  -G ../"${genome_index_name}.stringtie.gtf" \
#  -C "${sample}-abundance.cov_refs.gtf" \
#  -B
#  
#  echo "StringTie analysis finished for ${sample}.sorted.bam."
#  echo ""
#
##### END STRINGTIE ####
#
#
#  echo "Finished StringTie abundance estimates for ${sample} FastQs."
#  echo ""
#
#  # Generate checksums
#  for file in *
#  do
#    echo ""
#    echo "Generating checksum for ${file}..."
#    echo ""
#
#    md5sum "${file}" | tee --append checksums.md5
#
#    echo "Checksum generated."
#    echo ""
#  done
#
#  # Move up to orig. working directory
#  echo "Moving to original working directory."
#  echo ""
#
#  cd ../
#
#  echo "Now in ${PWD}."
#  echo ""
#
#done
#
#echo "Finished all StringTie abundance estimates."
#echo ""
#
##### END ESTIMATE TRANSCRIPT ABUNDANCE STRINGTIE GTFs ####
#
#
## Delete unneccessary index files
#echo ""
#echo "Removing HiSat2 *.ht2 genome index files..."
#echo ""
#
#rm "${genome_index_name}"*.ht2
#
#echo "All genome index files removed."
#echo ""
#
##### BEGIN GFFCOMPARE ####
#echo ""
#echo "Beginning gffcompare..."
#echo ""
#
## Make ggfcompare output directory and
## change into that directory
#mkdir --parents gffcompare && cd "$_"
#
## Run gffcompare
#"${programs_array[gffcompare]}" \
#-r "${genome_gff}" \
#-o "${genome_index_name}-gffcmp" \
#../"${genome_index_name}.stringtie.gtf"
#
#echo ""
#echo "Finished gffcompare"
#echo ""
#
## Generate checksums
#for file in *
#do
#  echo ""
#  echo "Generating checksum for ${file}..."
#  echo ""
#
#  md5sum "${file}" | tee --append checksums.md5
#
#  echo "Checksum generated."
#done
#
## Move to previous directory
#echo "Moving to previous directory..."
#echo ""
#
#cd -
#
#echo "Now in $(pwd)."
#echo ""
#
##### END GFFCOMPARE ####
#
#
##### BEGIN lncRNA ANALYSIS ####
#echo ""
#echo "Beginning lncRNA analysis..."
#echo ""
#
## Make lncRNA output directory and
## change into that directory
#mkdir --parents lncRNA && cd "$_"
#echo "Now in ${PWD}."
#echo ""
#
## Parse out transcripts >= 200bp and no overlap with reference transcripts
## string class_code “u” indicates no overlap
#echo "Now parsing transcripts from ${gffcompare_gtf} with "
#echo "gffcompare class code = 'u' and lengths >=${min_lncRNA_length}bp."
#echo ""
#
#awk '$3 == "transcript" {print}' "../${gffcompare_gtf}" \
#| grep 'class_code "u"' \
#| awk -v min_lncRNA_length="${min_lncRNA_length}" '$5 - $4 >= min_lncRNA_length {print}' \
#> "${lncRNA_candidates}"
#
#echo "Finished parsing ${gffcompare_gtf}."
#echo "Outputs in ${lncRNA_candidates}."
#echo ""
#
## Convert GTF to BED
## This is needed so the subsequent bedtools getfasta step will have a unique name for each transcript.
## Otherwise, the generated names generate duplicates because they're based off of the scaffold name and the start/stop sites.
## As such, when there are multiple transcripts identified for the same locations, they end up with the same names.
#
#echo "Converting ${lncRNA_candidates} to BED format."
#echo ""
#while read -r line
#do
#  stringtie_transcript=$(echo "${line}" | awk -F "\"" '{print $2}')
#
#  chr=$(echo "${line}" | awk '{print $1}')
#
#  start=$(echo "${line}" | awk '{print $4}')
#    
#  end=$(echo "${line}" | awk '{print $5}')
#
#  score="0"
#    
#  strand=$(echo "${line}" | awk '{print $7}')
#
#  printf "%s\t%s\t%s\t%s\t%s\t%s\n" "${chr}" "${start}" "${end}" "${stringtie_transcript}" "${score}" "${strand}"
#
#done < "${lncRNA_candidates}" > "${lncRNA_candidates_bed}"
#
#echo "Finished converting ${lncRNA_candidates} to ${lncRNA_candidates_bed}."
#echo ""
#
#
## Extract FastA sequences from candidate lncRNAs
## Use bedtools to extract lncRNA sequences as FastA.
## `-name`` option to use FastA sequence ID and coordinates as the names of the output sequences
#
#echo "Extracting FastA sequences from putative lncRNAs."
#echo ""
#
#${programs_array[bedtools_getfasta]} \
#-fi "${genome_fasta}" \
#-bed "${lncRNA_candidates_bed}" \
#-fo "${lncRNA_candidates_fasta}" \
#-name
#
#echo "Created ${lncRNA_candidates_fasta}."
#echo ""
#
## Run CPC2 to identify non-coding RNAs
#echo "Runing CPC2 to identify non-coding RNAs."
#echo ""
#
#"${programs_array[cpc2]}" \
#-i "${lncRNA_candidates_fasta}" \
#-o "${cpc2_table}"
#
#
## Capture noncoding IDs
## The label column, which is column 8 ($8), will be used to pull out all lncRNA IDs.
#echo ""
#echo "Capturing transcript IDs characterized as noncoding by CPC2."
#echo ""
#
#awk '$8 == "noncoding" {print $1}' "${cpc2_table}.txt" |
#awk -F":" '{print $1}' \
#> "${lncRNA_ids}"
#
#echo "CPC2 noncoding transcript IDswritten to ${lncRNA_ids}."
#echo ""
#
## Extract lncRNAs from GTF
#echo "Creating canonical lncRNAs GTF using ${lncRNA_ids} and ${lncRNA_candidates}."
#echo ""
#
#grep \
#--fixed-strings \
#--file="${lncRNA_ids}" \
#"${lncRNA_candidates}" \
#> "${lncRNAs_gtf}"
#
#echo "Canonical lncRNAs written to:"
#echo "${lncRNAs_gtf}"
#echo ""
#
#
#echo "Beginning lncRNA expression determination..."
#echo ""
#
#for sample in "${!samples_associative_array[@]}"
#do
#  
#  # Make and switch to dedicated sample directory
#  echo ""
#  echo "Switching to ${sample} directory."
#  mkdir "${sample}" && cd "$_"
#  echo "Now in ${PWD} directory."
#  echo ""
#  
#  # Stringtie lncRNA expression analysis
#  echo "Determining lncRNA expression for ${sample} using Stringtie..."
#  "${programs_array[stringtie]}" \
#    -G "../${lncRNAs_gtf}" \
#    -e "${top_dir}/${sample}/${sample}.sorted.bam" \
#    -B \
#    -o "${sample}-${lncRNA_stringtie_gtf}" \
#    -p "${threads}"
#
#  echo "Finished Stringtie lncRNA expression analysis for ${sample}."
#  echo ""
#
#  # Generate checksums
#  echo "Generating checksums for files in $(PWD)."
#
#  for file in *
#  do
#    echo ""
#    echo "Generating checksum for ${file}..."
#    echo ""
#
#    md5sum "${file}" | tee --append checksums.md5
#
#    echo "Checksum generated."
#  done
#
#  # Move to previous directory
#  echo "Moving to previous directory..."
#  echo ""
#
#  cd -
#
#  echo "Now in $(PWD)."
#  echo ""
#
#done
#
## Create count matrix
#echo ""
#echo "Creating count matrix for lncRNAs."
#echo ""
#
#"${programs_array[prepDE]}" \
#-l "${read_length}"
#
#echo "lncRNA Count matrices complete."
#echo ""
#
## Generate checksums
#echo "Generating checksums for files in $(PWD)."
#
#for file in *
#do
#  echo ""
#  echo "Generating checksum for ${file}..."
#  echo ""
#
#  md5sum "${file}" | tee --append checksums.md5
#
#  echo "Checksum generated."
#done
#
#### END lncRNA ANALYSIS ####
#
#cd "${top_dir}"
#
## Generate checksums
#echo "Generating checksums for files in $(PWD)."
#
#for file in *
#do
#  echo ""
#  echo "Generating checksum for ${file}..."
#  echo ""
#
#  md5sum "${file}" | tee --append checksums.md5
#
#  echo "Checksum generated."
#done
#
## Remove genome index tarball
#echo ""
#echo "Removing ${index_tarball}."
#
#rm "${index_tarball}"
#
#echo "${index_tarball} has been deleted."
#echo ""
#
########################################################################################################
#
## Capture program options
#if [[ "${#programs_array[@]}" -gt 0 ]]; then
#  echo "Logging program options..."
#  for program in "${!programs_array[@]}"
#  do
#    {
#    echo "Program options for ${program}: "
#    echo ""
#    # Handle samtools help menus
#    if [[ "${program}" == "samtools_index" ]] \
#    || [[ "${program}" == "samtools_sort" ]] \
#    || [[ "${program}" == "samtools_view" ]]
#    then
#      ${programs_array[$program]}
#
#    # Handle DIAMOND BLAST menu
#    elif [[ "${program}" == "diamond" ]]; then
#      ${programs_array[$program]} help
#
#    # Handle NCBI BLASTx menu
#    elif [[ "${program}" == "blastx" ]]; then
#      ${programs_array[$program]} -help
#    fi
#    ${programs_array[$program]} -h
#    echo ""
#    echo ""
#    echo "----------------------------------------------"
#    echo ""
#    echo ""
#  } &>> program_options.log || true
#
#    # If MultiQC is in programs_array, copy the config file to this directory.
#    if [[ "${program}" == "multiqc" ]]; then
#      cp --preserve ~/.multiqc_config.yaml multiqc_config.yaml
#    fi
#  done
#  echo "Finished logging programs options."
#  echo ""
#fi
#
#
## Document programs in PATH (primarily for program version ID)
#echo "Logging system $PATH..."
#
#{
#date
#echo ""
#echo "System PATH for $SLURM_JOB_ID"
#echo ""
#printf "%0.s-" {1..10}
#echo "${PATH}" | tr : \\n
#} >> system_path.log
#
#echo "Finished logging system $PATH."
#echo ""
#
#echo "Script complete!"
