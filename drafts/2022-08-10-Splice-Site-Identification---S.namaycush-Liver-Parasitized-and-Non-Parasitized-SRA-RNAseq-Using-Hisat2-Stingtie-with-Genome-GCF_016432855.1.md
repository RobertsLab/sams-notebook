---
layout: post
title: Splice Site Identification - S.namaycush Liver Parasitized and Non-Parasitized SRA RNAseq Using Hisat2-Stingtie with Genome GCF_016432855.1
date: '2022-08-10 16:45'
tags: 
  - hisat2
  - lake trout
  - siscowet
  - lean
  - Salvelinus namaycush
  - stringtie
  - splice
  - RNAseq
  - SRA
  - GCF_016432855.1
categories: 
  - Miscellaneous
---
After previously [downloading/trimming/QCing _S.namaycush_ SRA liver RNAseq data on 20220706](https://robertslab.github.io/sams-notebook/2022/07/06/SRA-Data-S.namaycush-SRA-BioProject-PRJNA674328-Download-and-QC.html), Steven asked that I [run through Hisat2 for splice site identification](https://github.com/RobertsLab/resources/issues/1505) (GitHub Issue).

To do so, I downloaded the following NCBI files to Mox:

- FastA: https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/016/432/855/GCF_016432855.1_SaNama_1.0/GCF_016432855.1_SaNama_1.0_genomic.fna.gz

- GFF: https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/016/432/855/GCF_016432855.1_SaNama_1.0/GCF_016432855.1_SaNama_1.0_genomic.gff.gz

- GTF: https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/016/432/855/GCF_016432855.1_SaNama_1.0/GCF_016432855.1_SaNama_1.0_genomic.gtf.gz

I also reviewd the metadata for [BioProject PRJNA316738](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA316738) and downloaded the metadata for the project:

- Metadata website: https://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRP072750&o=acc_s%3Aa

- Metadata file (CSV): [SraRunTable.txt](https://gannet.fish.washington.edu/Atumefaciens/20220810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms/SraRunTable.txt)

Upon reviewing the metadata, it became clear that each SRA run was part of a set of three sequencing runs for each sample (see the "Library Name" column in the [SraRunTable.txt](https://gannet.fish.washington.edu/Atumefaciens/20220810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms/SraRunTable.txt)). I used this information to concatenate corresponding FastQs and for setting a read group (RG) in the resulting BAM files for the two subspecies (lean and siscowet), as well as indicate non-parasitized and parasitized. Although, each set of three library sets are part of one of four BioSamples:

| BioSample    | Ecotype                |
|--------------|------------------------|
| SAMN04590682 | Lean parasitized       |
| SAMN04590683 | Lean nonparasitized    |
| SAMN04590684 | Siscowet parasitized   |
| SAMN04590685 | Sicowet nonparasitized |

It's possible I should've set up FastQ concatenation and the BAM RG fields using this information, but this can be dealt with downstream, if desired.

Anyway, an overview of the proccess:

1. Create [`HISAT2`](https://daehwankimlab.github.io/hisat2/) genome index.

2. Identify genome exons and splice sites using [`HISAT2`](https://daehwankimlab.github.io/hisat2/).

3. Align trimmed, concatenated RNAseq reads (single-end) to genome using [`HISAT2`](https://daehwankimlab.github.io/hisat2/).

4. Use [`StringTie`](https://ccb.jhu.edu/software/stringtie/) to idenify alternative isoforms and create output files ready for import to [Ballgown](https://github.com/alyssafrazee/ballgown).


Analysis was run on Mox.


SBATCH script (GitHub):

- [20220810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20220810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms.sh)


```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20220810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20220810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms


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
exons="snam-GCF_016432855.1_hisat2_exons.tab"
fastq_dir="/gscratch/srlab/sam/data/S_namaycush/RNAseq/"
genome_dir="/gscratch/srlab/sam/data/S_namaycush/genomes"
genome_index_dir="/gscratch/srlab/sam/data/S_namaycush/genomes"
genome_fasta="${genome_dir}/GCF_016432855.1_SaNama_1.0_genomic.fna"
genome_gff="${genome_index_dir}/GCF_016432855.1_SaNama_1.0_genomic.gff"
gtf_list="gtf_list.txt"
merged_bam="20220810-snam-stringtie-GCF_016432855.1-sorted_bams-merged.bam"
splice_sites="snam-GCF_016432855.1_hisat2_splice_sites.tab"
transcripts_gtf="${genome_dir}/GCF_016432855.1_SaNama_1.0_genomic.gtf"

# Set FastQ naming pattern
fastq_pattern=".fastq.trimmed.20220707.fq.gz"

# Declare associative array of sample names and metadata
declare -A samples_associative_array=()

# Set total number of samples (NOT number of FastQ files)
total_samples=24

# Set total of original FastQ files
total_fastqs=72

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
md5sum ./* >> checksums.md5

# Copy Hisat2 index files to my data directory for later use with StringTie
rsync -av "${genome_index_name}"*.ht2 "${genome_dir}"

###### Load associative array ######

# Set sample counter for array verification
fastq_counter=0

# Load array
for fastq in "${fastq_dir}"*"${fastq_pattern}"
do

  # Generate MD5 checksums for original set of FastQs
  md5sum "${fastq}" >> original-fastq-checksums.md5

  # Increment counter
  ((fastq_counter+=1))

  # Remove path
  sample_name="${fastq##*/}"

  # Get sample name from first "."-delimited field
  sample_name=$(echo "${sample_name}" | awk -F "." '{print $1}')

  # Concatenate reads from multiple runs
  if
    [[ "${sample_name}" == "SRR3321200" ]] \
    || [[ "${sample_name}" == "SRR3321217" ]] \
    || [[ "${sample_name}" == "SRR3321243" ]]
  then
    cat "${fastq}" >> NPLL32.SRR3321200-SRR3321217-SRR3321243"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321201" ]] \
    || [[ "${sample_name}" == "SRR3321218" ]] \
    || [[ "${sample_name}" == "SRR3321244" ]]
  then
    cat "${fastq}" >> NPLL34.SRR3321201-SRR3321218-SRR3321244"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321212" ]] \
    || [[ "${sample_name}" == "SRR3321219" ]] \
    || [[ "${sample_name}" == "SRR3321246" ]]
  then
    cat "${fastq}" >> NPLL44.SRR3321212-SRR3321219-SRR3321246"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321223" ]] \
    || [[ "${sample_name}" == "SRR3321220" ]] \
    || [[ "${sample_name}" == "SRR3321247" ]]
  then
    cat "${fastq}" >> NPLL46.SRR3321223-SRR3321220-SRR3321247"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321234" ]] \
    || [[ "${sample_name}" == "SRR3321221" ]] \
    || [[ "${sample_name}" == "SRR3321248" ]]
  then
    cat "${fastq}" >> NPLL56.SRR3321234-SRR3321221-SRR3321248"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321245" ]] \
    || [[ "${sample_name}" == "SRR3321222" ]] \
    || [[ "${sample_name}" == "SRR3321249" ]]
  then
    cat "${fastq}" >> NPLL61.SRR3321245-SRR3321222-SRR3321249"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321256" ]] \
    || [[ "${sample_name}" == "SRR3321224" ]] \
    || [[ "${sample_name}" == "SRR3321250" ]]
  then
    cat "${fastq}" >> NPSL15.SRR3321256-SRR3321224-SRR3321250"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321267" ]] \
    || [[ "${sample_name}" == "SRR3321225" ]] \
    || [[ "${sample_name}" == "SRR3321251" ]]
  then
    cat "${fastq}" >> NPSL24.SRR3321267-SRR3321225-SRR3321251"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321270" ]] \
    || [[ "${sample_name}" == "SRR3321226" ]] \
    || [[ "${sample_name}" == "SRR3321252" ]]
  then
    cat "${fastq}" >> NPSL29.SRR3321270-SRR3321226-SRR3321252"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321271" ]] \
    || [[ "${sample_name}" == "SRR3321227" ]] \
    || [[ "${sample_name}" == "SRR3321253" ]]
  then
    cat "${fastq}" >> NPSL36.SRR3321271-SRR3321227-SRR3321253"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321202" ]] \
    || [[ "${sample_name}" == "SRR3321228" ]] \
    || [[ "${sample_name}" == "SRR3321254" ]]
  then
    cat "${fastq}" >> NPSL50.SRR3321202-SRR3321228-SRR3321254"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321203" ]] \
    || [[ "${sample_name}" == "SRR3321229" ]] \
    || [[ "${sample_name}" == "SRR3321255" ]]
  then
    cat "${fastq}" >> NPSL58.SRR3321203-SRR3321229-SRR3321255"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321204" ]] \
    || [[ "${sample_name}" == "SRR3321230" ]] \
    || [[ "${sample_name}" == "SRR3321257" ]]
  then
    cat "${fastq}" >> PLL20.SRR3321204-SRR3321230-SRR3321257"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321205" ]] \
    || [[ "${sample_name}" == "SRR3321231" ]] \
    || [[ "${sample_name}" == "SRR3321258" ]]
  then
    cat "${fastq}" >> PLL31.SRR3321205-SRR3321231-SRR3321258"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321206" ]] \
    || [[ "${sample_name}" == "SRR3321232" ]] \
    || [[ "${sample_name}" == "SRR3321259" ]]
  then
    cat "${fastq}" >> PLL43.SRR3321206-SRR3321232-SRR3321259"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321207" ]] \
    || [[ "${sample_name}" == "SRR3321233" ]] \
    || [[ "${sample_name}" == "SRR3321260" ]]
  then
    cat "${fastq}" >> PLL55.SRR3321207-SRR3321233-SRR3321260"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321208" ]] \
    || [[ "${sample_name}" == "SRR3321235" ]] \
    || [[ "${sample_name}" == "SRR3321261" ]]
  then
    cat "${fastq}" >> PLL59.SRR3321208-SRR3321235-SRR3321261"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321209" ]] \
    || [[ "${sample_name}" == "SRR3321236" ]] \
    || [[ "${sample_name}" == "SRR3321262" ]]
  then
    cat "${fastq}" >> PLL62.SRR3321209-SRR3321236-SRR3321262"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321210" ]] \
    || [[ "${sample_name}" == "SRR3321237" ]] \
    || [[ "${sample_name}" == "SRR3321263" ]]
  then
    cat "${fastq}" >> PSL13.SRR3321210-SRR3321237-SRR3321263"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321211" ]] \
    || [[ "${sample_name}" == "SRR3321238" ]] \
    || [[ "${sample_name}" == "SRR3321264" ]]
  then
    cat "${fastq}" >> PSL16.SRR3321211-SRR3321238-SRR3321264"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321213" ]] \
    || [[ "${sample_name}" == "SRR3321239" ]] \
    || [[ "${sample_name}" == "SRR3321265" ]]
  then
    cat "${fastq}" >> PSL35.SRR3321213-SRR3321239-SRR3321265"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321214" ]] \
    || [[ "${sample_name}" == "SRR3321240" ]] \
    || [[ "${sample_name}" == "SRR3321266" ]]
  then
    cat "${fastq}" >> PSL49.SRR3321214-SRR3321240-SRR3321266"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321215" ]] \
    || [[ "${sample_name}" == "SRR3321241" ]] \
    || [[ "${sample_name}" == "SRR3321268" ]]
  then
    cat "${fastq}" >> PSL53.SRR3321215-SRR3321241-SRR3321268"${fastq_pattern}"
  elif
    [[ "${sample_name}" == "SRR3321216" ]] \
    || [[ "${sample_name}" == "SRR3321242" ]] \
    || [[ "${sample_name}" == "SRR3321269" ]]
  then
    cat "${fastq}" >> PSL63.SRR3321216-SRR3321242-SRR3321269"${fastq_pattern}"
  fi

done

# Check array size to confirm it has all expected samples
# Exit if mismatch
if [[ "${fastq_counter}" != "${total_fastqs}" ]]
then
  echo "Expected ${total_fastqs} FastQs, but only found ${fastq_counter}!"
  echo ""
  echo "Check original-fastq-checksums.md5 file for list of FastQs processed."
  echo ""
  exit
fi

###### Load associative array ######

# Set sample counter for array verification
sample_counter=0

for fastq in *"${fastq_pattern}"
do
  # Generate MD5 checksums for original set of FastQs
  md5sum "${fastq}" >> concatenated-fastq-checksums.md5

  # Increment counter
  ((sample_counter+=1))

  # Remove path
  sample_name="${fastq##*/}"

  # Get sample name from first "."-delimited field
  sample_name=$(echo "${sample_name}" | awk -F "." '{print $1}')


  # Set treatment condition for each sample
  # Primarily used for setting read group (RG) during BAM creation
  if
    [[ "${sample_name}" == "NPLL32" ]] \
    || [[ "${sample_name}" == "NPLL34" ]] \
    || [[ "${sample_name}" == "NPLL44" ]] \
    || [[ "${sample_name}" == "NPLL46" ]] \
    || [[ "${sample_name}" == "NPLL56" ]] \
    || [[ "${sample_name}" == "NPLL61" ]]
  then
    treatment="lean-non_parasitized"
  elif
    [[ "${sample_name}" == "NPSL15" ]] \
    || [[ "${sample_name}" == "NPSL24" ]] \
    || [[ "${sample_name}" == "NPSL29" ]] \
    || [[ "${sample_name}" == "NPSL36" ]] \
    || [[ "${sample_name}" == "NPSL50" ]] \
    || [[ "${sample_name}" == "NPSL58" ]]
  then
    treatment="siscowet-non_parasitized"
  elif
    [[ "${sample_name}" == "PLL20" ]] \
    || [[ "${sample_name}" == "PLL31" ]] \
    || [[ "${sample_name}" == "PLL43" ]] \
    || [[ "${sample_name}" == "PLL55" ]] \
    || [[ "${sample_name}" == "PLL59" ]] \
    || [[ "${sample_name}" == "PLL62" ]]
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
  # Identify corresponding FastQ file
  # Pipe to sed replace leading "./" with "../" to manage relative FastQ path
  fastq=$(find . -name "${sample}*${fastq_pattern}" | sed 's/.\//..\//')

  # Create and switch to dedicated sample directory
  mkdir "${sample}" && cd "$_"

  # Hisat2 alignments
  # Sets read group info (RG) using samples array
  # Uses -U for single-end reads
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
    md5sum "${file}" >> "${sample}"-checksums.md5
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


# Generate checksums
find . -type f -maxdepth 1 -exec md5sum {} + >> checksums.md5


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

Runtime was almost exactly 7hrs:

![Screencap of Mox job runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20220810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms_runtime.png?raw=true)

Output folder:

- [20220810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms/](https://gannet.fish.washington.edu/Atumefaciens/20220810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms/)

  #### Merged BAM file

    - [20220810-snam-stringtie-GCF_016432855.1-sorted_bams-merged.bam](https://gannet.fish.washington.edu/Atumefaciens/20220810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms/20220810-snam-stringtie-GCF_016432855.1-sorted_bams-merged.bam) (20G)

      - MD5: `6911d3fc9f725a09a09a4c584b68ddfa`

  #### Merged BAM index file (useful for IGV)

    - [20220810-snam-stringtie-GCF_016432855.1-sorted_bams-merged.bam.bai](https://gannet.fish.washington.edu/Atumefaciens/20220810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms/20220810-snam-stringtie-GCF_016432855.1-sorted_bams-merged.bam.bai) (3.3M)

      - MD5: `368e45c560e61f812522a00c71a89eee`

  #### StringTie GTF

    - [snam-GCF_016432855.1.stringtie.gtf](https://gannet.fish.washington.edu/Atumefaciens/20220810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms/snam-GCF_016432855.1.stringtie.gtf) (125M)

      - MD5: `7396cc52190b6c6408c0f3bbc82e9ed6`

Individual library alignments can be found in their respective subdirectories, along with their BAM, BAM index, GTF, and Ballgown tables (`*.ctab`). See the directory tree below for a better overview.

---

Directory tree:

```shell
├── 20220810-snam-hisat2-GCF_016432855.1_index-align-stringtie_isoforms.sh
├── 20220810-snam-stringtie-GCF_016432855.1-sorted_bams-merged.bam
├── 20220810-snam-stringtie-GCF_016432855.1-sorted_bams-merged.bam.bai
├── checksums.md5
├── concatenated-fastq-checksums.md5
├── gtf_list.txt
├── hisat2_build.err
├── NPLL32
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── NPLL32-checksums.md5
│   ├── NPLL32.cov_refs.gtf
│   ├── NPLL32.gtf
│   ├── NPLL32_hisat2.err
│   ├── NPLL32.sorted.bam
│   ├── NPLL32.sorted.bam.bai
│   └── t_data.ctab
├── NPLL32.SRR3321200-SRR3321217-SRR3321243.fastq.trimmed.20220707.fq.gz
├── NPLL34
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── NPLL34-checksums.md5
│   ├── NPLL34.cov_refs.gtf
│   ├── NPLL34.gtf
│   ├── NPLL34_hisat2.err
│   ├── NPLL34.sorted.bam
│   ├── NPLL34.sorted.bam.bai
│   └── t_data.ctab
├── NPLL34.SRR3321201-SRR3321218-SRR3321244.fastq.trimmed.20220707.fq.gz
├── NPLL44
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── NPLL44-checksums.md5
│   ├── NPLL44.cov_refs.gtf
│   ├── NPLL44.gtf
│   ├── NPLL44_hisat2.err
│   ├── NPLL44.sorted.bam
│   ├── NPLL44.sorted.bam.bai
│   └── t_data.ctab
├── NPLL44.SRR3321212-SRR3321219-SRR3321246.fastq.trimmed.20220707.fq.gz
├── NPLL46
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── NPLL46-checksums.md5
│   ├── NPLL46.cov_refs.gtf
│   ├── NPLL46.gtf
│   ├── NPLL46_hisat2.err
│   ├── NPLL46.sorted.bam
│   ├── NPLL46.sorted.bam.bai
│   └── t_data.ctab
├── NPLL46.SRR3321223-SRR3321220-SRR3321247.fastq.trimmed.20220707.fq.gz
├── NPLL56
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── NPLL56-checksums.md5
│   ├── NPLL56.cov_refs.gtf
│   ├── NPLL56.gtf
│   ├── NPLL56_hisat2.err
│   ├── NPLL56.sorted.bam
│   ├── NPLL56.sorted.bam.bai
│   └── t_data.ctab
├── NPLL56.SRR3321234-SRR3321221-SRR3321248.fastq.trimmed.20220707.fq.gz
├── NPLL61
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── NPLL61-checksums.md5
│   ├── NPLL61.cov_refs.gtf
│   ├── NPLL61.gtf
│   ├── NPLL61_hisat2.err
│   ├── NPLL61.sorted.bam
│   ├── NPLL61.sorted.bam.bai
│   └── t_data.ctab
├── NPLL61.SRR3321245-SRR3321222-SRR3321249.fastq.trimmed.20220707.fq.gz
├── NPSL15
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── NPSL15-checksums.md5
│   ├── NPSL15.cov_refs.gtf
│   ├── NPSL15.gtf
│   ├── NPSL15_hisat2.err
│   ├── NPSL15.sorted.bam
│   ├── NPSL15.sorted.bam.bai
│   └── t_data.ctab
├── NPSL15.SRR3321256-SRR3321224-SRR3321250.fastq.trimmed.20220707.fq.gz
├── NPSL24
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── NPSL24-checksums.md5
│   ├── NPSL24.cov_refs.gtf
│   ├── NPSL24.gtf
│   ├── NPSL24_hisat2.err
│   ├── NPSL24.sorted.bam
│   ├── NPSL24.sorted.bam.bai
│   └── t_data.ctab
├── NPSL24.SRR3321267-SRR3321225-SRR3321251.fastq.trimmed.20220707.fq.gz
├── NPSL29
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── NPSL29-checksums.md5
│   ├── NPSL29.cov_refs.gtf
│   ├── NPSL29.gtf
│   ├── NPSL29_hisat2.err
│   ├── NPSL29.sorted.bam
│   ├── NPSL29.sorted.bam.bai
│   └── t_data.ctab
├── NPSL29.SRR3321270-SRR3321226-SRR3321252.fastq.trimmed.20220707.fq.gz
├── NPSL36
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── NPSL36-checksums.md5
│   ├── NPSL36.cov_refs.gtf
│   ├── NPSL36.gtf
│   ├── NPSL36_hisat2.err
│   ├── NPSL36.sorted.bam
│   ├── NPSL36.sorted.bam.bai
│   └── t_data.ctab
├── NPSL36.SRR3321271-SRR3321227-SRR3321253.fastq.trimmed.20220707.fq.gz
├── NPSL50
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── NPSL50-checksums.md5
│   ├── NPSL50.cov_refs.gtf
│   ├── NPSL50.gtf
│   ├── NPSL50_hisat2.err
│   ├── NPSL50.sorted.bam
│   ├── NPSL50.sorted.bam.bai
│   └── t_data.ctab
├── NPSL50.SRR3321202-SRR3321228-SRR3321254.fastq.trimmed.20220707.fq.gz
├── NPSL58
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── NPSL58-checksums.md5
│   ├── NPSL58.cov_refs.gtf
│   ├── NPSL58.gtf
│   ├── NPSL58_hisat2.err
│   ├── NPSL58.sorted.bam
│   ├── NPSL58.sorted.bam.bai
│   └── t_data.ctab
├── NPSL58.SRR3321203-SRR3321229-SRR3321255.fastq.trimmed.20220707.fq.gz
├── original-fastq-checksums.md5
├── PLL20
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── PLL20-checksums.md5
│   ├── PLL20.cov_refs.gtf
│   ├── PLL20.gtf
│   ├── PLL20_hisat2.err
│   ├── PLL20.sorted.bam
│   ├── PLL20.sorted.bam.bai
│   └── t_data.ctab
├── PLL20.SRR3321204-SRR3321230-SRR3321257.fastq.trimmed.20220707.fq.gz
├── PLL31
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── PLL31-checksums.md5
│   ├── PLL31.cov_refs.gtf
│   ├── PLL31.gtf
│   ├── PLL31_hisat2.err
│   ├── PLL31.sorted.bam
│   ├── PLL31.sorted.bam.bai
│   └── t_data.ctab
├── PLL31.SRR3321205-SRR3321231-SRR3321258.fastq.trimmed.20220707.fq.gz
├── PLL43
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── PLL43-checksums.md5
│   ├── PLL43.cov_refs.gtf
│   ├── PLL43.gtf
│   ├── PLL43_hisat2.err
│   ├── PLL43.sorted.bam
│   ├── PLL43.sorted.bam.bai
│   └── t_data.ctab
├── PLL43.SRR3321206-SRR3321232-SRR3321259.fastq.trimmed.20220707.fq.gz
├── PLL55
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── PLL55-checksums.md5
│   ├── PLL55.cov_refs.gtf
│   ├── PLL55.gtf
│   ├── PLL55_hisat2.err
│   ├── PLL55.sorted.bam
│   ├── PLL55.sorted.bam.bai
│   └── t_data.ctab
├── PLL55.SRR3321207-SRR3321233-SRR3321260.fastq.trimmed.20220707.fq.gz
├── PLL59
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── PLL59-checksums.md5
│   ├── PLL59.cov_refs.gtf
│   ├── PLL59.gtf
│   ├── PLL59_hisat2.err
│   ├── PLL59.sorted.bam
│   ├── PLL59.sorted.bam.bai
│   └── t_data.ctab
├── PLL59.SRR3321208-SRR3321235-SRR3321261.fastq.trimmed.20220707.fq.gz
├── PLL62
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── PLL62-checksums.md5
│   ├── PLL62.cov_refs.gtf
│   ├── PLL62.gtf
│   ├── PLL62_hisat2.err
│   ├── PLL62.sorted.bam
│   ├── PLL62.sorted.bam.bai
│   └── t_data.ctab
├── PLL62.SRR3321209-SRR3321236-SRR3321262.fastq.trimmed.20220707.fq.gz
├── program_options.log
├── PSL13
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── PSL13-checksums.md5
│   ├── PSL13.cov_refs.gtf
│   ├── PSL13.gtf
│   ├── PSL13_hisat2.err
│   ├── PSL13.sorted.bam
│   ├── PSL13.sorted.bam.bai
│   └── t_data.ctab
├── PSL13.SRR3321210-SRR3321237-SRR3321263.fastq.trimmed.20220707.fq.gz
├── PSL16
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── PSL16-checksums.md5
│   ├── PSL16.cov_refs.gtf
│   ├── PSL16.gtf
│   ├── PSL16_hisat2.err
│   ├── PSL16.sorted.bam
│   ├── PSL16.sorted.bam.bai
│   └── t_data.ctab
├── PSL16.SRR3321211-SRR3321238-SRR3321264.fastq.trimmed.20220707.fq.gz
├── PSL35
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── PSL35-checksums.md5
│   ├── PSL35.cov_refs.gtf
│   ├── PSL35.gtf
│   ├── PSL35_hisat2.err
│   ├── PSL35.sorted.bam
│   ├── PSL35.sorted.bam.bai
│   └── t_data.ctab
├── PSL35.SRR3321213-SRR3321239-SRR3321265.fastq.trimmed.20220707.fq.gz
├── PSL49
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── PSL49-checksums.md5
│   ├── PSL49.cov_refs.gtf
│   ├── PSL49.gtf
│   ├── PSL49_hisat2.err
│   ├── PSL49.sorted.bam
│   ├── PSL49.sorted.bam.bai
│   └── t_data.ctab
├── PSL49.SRR3321214-SRR3321240-SRR3321266.fastq.trimmed.20220707.fq.gz
├── PSL53
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── PSL53-checksums.md5
│   ├── PSL53.cov_refs.gtf
│   ├── PSL53.gtf
│   ├── PSL53_hisat2.err
│   ├── PSL53.sorted.bam
│   ├── PSL53.sorted.bam.bai
│   └── t_data.ctab
├── PSL53.SRR3321215-SRR3321241-SRR3321268.fastq.trimmed.20220707.fq.gz
├── PSL63
│   ├── e2t.ctab
│   ├── e_data.ctab
│   ├── i2t.ctab
│   ├── i_data.ctab
│   ├── PSL63-checksums.md5
│   ├── PSL63.cov_refs.gtf
│   ├── PSL63.gtf
│   ├── PSL63_hisat2.err
│   ├── PSL63.sorted.bam
│   ├── PSL63.sorted.bam.bai
│   └── t_data.ctab
├── PSL63.SRR3321216-SRR3321242-SRR3321269.fastq.trimmed.20220707.fq.gz
├── slurm-3459606.out
├── snam-GCF_016432855.1.1.ht2
├── snam-GCF_016432855.1.2.ht2
├── snam-GCF_016432855.1.3.ht2
├── snam-GCF_016432855.1.4.ht2
├── snam-GCF_016432855.1.5.ht2
├── snam-GCF_016432855.1.6.ht2
├── snam-GCF_016432855.1.7.ht2
├── snam-GCF_016432855.1.8.ht2
├── snam-GCF_016432855.1_hisat2_exons.tab
├── snam-GCF_016432855.1_hisat2_splice_sites.tab
├── snam-GCF_016432855.1.stringtie.gtf
├── sorted_bams.list
├── SraRunTable.txt
└── system_path.log
```