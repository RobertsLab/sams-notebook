---
layout: post
title: Trimming and QC - E5 Coral sRNA-seq Data fro A.pulchra P.evermanni and P.meandrina Using  FastQC flexbar and MultiQC on Mox
date: '2023-06-20 07:09'
tags: 
  - flexbar
  - E5
  - trimming
  - FastQC
  - MultiQC
  - mox
  - coral
categories: 
  - E5
---
After [downloading](https://robertslab.github.io/sams-notebook/2023/05/16/Data-Received-Coral-RNA-seq-Data-from-Azenta-Project-30-789513166.html) and then [reorganizing the E5 coral RNA-seq data from Azenta project 30-789513166](https://robertslab.github.io/sams-notebook/2023/05/17/Data-Management-E5-Coral-RNA-seq-and-sRNA-seq-Reorganizing-and-Renaming.html), _and_ after [testing some trimming options for sRNA-seq data](https://robertslab.github.io/sams-notebook/2023/05/24/Trimming-and-QC-E5-Coral-sRNA-seq-Trimming-Parameter-Tests-and-Comparisons.html) (notebook), I opted to use the trimming software [`flexbar`](https://github.com/seqan/flexbar). I ran FastQC for initial quality checks, followed by trimming with [`flexbar`](https://github.com/seqan/flexbar), and then final QC with FastQC/MultiQC. This was performed on all three species in the data sets: _A.pulchra_, _P.evermanni_, and _P.meandrina_. All aspects were run on Mox. Final trimming length was set to 35bp.

Skip to [RESULTS](#results).

SLURM Script (GitHub):

- [20230620-E5_coral-fastqc-flexbar-multiqc-sRNAseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20230620-E5_coral-fastqc-flexbar-multiqc-sRNAseq.sh)

```bash
#!/bin/bash
## Job Name
#SBATCH --job-name=20230620-E5_coral-fastqc-flexbar-multiqc-sRNAseq
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230620-E5_coral-fastqc-flexbar-multiqc-sRNAseq

### FastQC and flexbar trimming of E5 coral species sRNA-seq data from 202230515.

### flexbar expects input FastQ files to be in format: sRNA-ACR-178-S1-TP2_R1_001.fastq.gz

### Adapter trimming and read length trimming is based off of NEB nebnext-small-rna-library-prep-set-for-illumina kit.


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set FastQ filename patterns
fastq_pattern='*.fastq.gz'
R1_fastq_pattern='*_R1_*.fastq.gz'
R2_fastq_pattern='*_R2_*.fastq.gz'

# Set number of CPUs to use
threads=40

# Set maximum read length
max_read_length=50

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5
fastq_checksums=input_fastq_checksums.md5
NEB_adapters_fasta=NEB-adapters.fasta

## NEB nebnext-small-rna-library-prep-set-for-illumina adapters
first_adapter="AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC"
second_adapter="GATCGTCGGACTGTAGAACTCTGAACGTGTAGATCTCGGTGGTCGCCGTATCATT"



# Data directories
reads_dir=/gscratch/srlab/sam/data

# Species array (must match directory name usage)
species_array=("A_pulchra" "P_evermanni" "P_meandrina")

## Inititalize arrays
raw_fastqs_array=()
R1_names_array=()
R2_names_array=()
fastq_array_R1=()
fastq_array_R2=()

# Paths to programs
fastqc=/gscratch/srlab/programs/fastqc_v0.11.9/fastqc
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc

# Programs associative array
declare -A programs_array
programs_array=(
[fastqc]="${fastqc}" \
[multiqc]="${multiqc}" \
[flexbar]="flexbar"
)


###################################################################################

# Exit script if any command fails
set -e

# Load Anaconda
# Uknown why this is needed, but Anaconda will not run if this line is not included.
. "/gscratch/srlab/programs/anaconda3/etc/profile.d/conda.sh"

# Activate flexbar environment
conda activate flexbar-3.5.0

# Capture date
timestamp=$(date +%Y%m%d)

# Create adapters FastA for use with flexbar trimming
echo "Creating adapters FastA."
echo ""
adapter_count=0

for adapter in "${first_adapter}" "${second_adapter}"
do
  adapter_count=$((adapter_count + 1))
  printf ">%s\n%s\n" "adapter_${adapter_count}" "${adapter}"
done >> "${NEB_adapters_fasta}"

echo "Adapters FastA:"
echo ""
cat "${NEB_adapters_fasta}"
echo ""


# Set working directory
working_dir=$(pwd)

for species in "${species_array[@]}"
do
    ## Inititalize arrays
    raw_fastqs_array=()
    R1_names_array=()
    R2_names_array=()
    fastq_array_R1=()
    fastq_array_R2=()
    trimmed_fastq_array=()


    echo "Creating ${species} directory and subdirectories..." 

    mkdir --parents "${species}/raw_fastqc" "${species}/trimmed"

    # Change to raw_fastq directory
    cd "${species}/raw_fastqc"


    # FastQC output directory
    output_dir=$(pwd)

    echo "Now in ${PWD}."

    # Sync raw FastQ files to working directory
    echo ""
    echo "Transferring files via rsync..."

    rsync --archive --verbose \
    ${reads_dir}/${species}/sRNAseq/${fastq_pattern} .

    echo ""
    echo "File transfer complete."
    echo ""

    ### Run FastQC ###

    ### NOTE: Do NOT quote raw_fastqc_list
    # Create array of trimmed FastQs
    raw_fastqs_array=(${fastq_pattern})

    # Pass array contents to new variable as space-delimited list
    raw_fastqc_list=$(echo "${raw_fastqs_array[*]}")

    echo "Beginning FastQC on raw reads..."
    echo ""

    # Run FastQC
    ${programs_array[fastqc]} \
    --threads ${threads} \
    --outdir ${output_dir} \
    ${raw_fastqc_list}

    echo "FastQC on raw reads complete!"
    echo ""

    ### END FASTQC ###

    ### RUN MULTIQC ###
    echo "Beginning MultiQC on raw FastQC..."
    echo ""

    ${multiqc} .

    echo ""
    echo "MultiQC on raw FastQ complete."
    echo ""

    ### END MULTIQC ###

    # Create arrays of fastq R1 files and sample names
    # Do NOT quote R1_fastq_pattern variable
    for fastq in ${R1_fastq_pattern}
    do
      fastq_array_R1+=("${fastq}")

      # Use parameter substitution to remove all text up to and including last "." from
      # right side of string.
      R1_names_array+=("${fastq%%.*}")
    done

    # Create array of fastq R2 files
    # Do NOT quote R2_fastq_pattern variable
    for fastq in ${R2_fastq_pattern}
    do
      fastq_array_R2+=("${fastq}")

      # Use parameter substitution to remove all text up to and including last "." from
      # right side of string.
      R2_names_array+=("${fastq%%.*}")
    done


    # Create MD5 checksums for raw FastQs
    for fastq in ${fastq_pattern}
    do
        echo "Generating checksum for ${fastq}"
        md5sum "${fastq}" | tee --append ${fastq_checksums}
        echo ""
    done


    ### RUN FLEXBAR ###
    # Uses parameter substitution (e.g. ${R1_sample_name%%_*})to rm the _R[12]
    # Uses NEB adapter file
    # --adapter-pair-overlap ON: Recommended by NEB sRNA kit
    # --qtrim-threshold 25: Minimum quality
    # --qtrim-format i1.8: Sets sequencer as illumina
    # --post-trim-length: Trim reads from 3' end to max length
    # --target: Sets file naming patterns
    # --zip-output GZ: Sets type of compression. GZ = gzip

    # Run flexbar on files
    echo "Beginning flexbar trimming."
    echo ""

    for index in "${!fastq_array_R1[@]}"
    do
      R1_sample_name="${R1_names_array[index]}"
      R2_sample_name="${R2_names_array[index]}"

      # Begin flexbar trimming
      flexbar \
      --reads ${fastq_array_R1[index]} \
      --reads2 ${fastq_array_R2[index]}  \
      --adapters ../../${NEB_adapters_fasta} \
      --adapter-pair-overlap ON \
      --qtrim-format i1.8 \
      --qtrim-threshold 25 \
      --post-trim-length ${max_read_length} \
      --threads ${threads} \
      --target "../trimmed/${R1_sample_name%%_*}.flexbar_trim.${timestamp}" \
      --zip-output GZ
        
        # Move to trimmed directory
        # This is done so checksums file doesn't include excess path
        cd ../trimmed/

        echo "Moving to ${PWD}."
        echo ""

        # Generate md5 checksums for newly trimmed files
        {
            md5sum "${R1_sample_name%%_*}.flexbar_trim.${timestamp}_1.fastq.gz"
            md5sum "${R2_sample_name%%_*}.flexbar_trim.${timestamp}_2.fastq.gz"
        } >> "${trimmed_checksums}"


        # Go back to raw reads directory
        cd ../raw_fastqc

        echo "Moving to ${PWD}"
        echo ""
        
        # Remove original FastQ files
        echo ""
        echo " Removing ${fastq_array_R1[index]} and ${fastq_array_R2[index]}."
        
        rm "${fastq_array_R1[index]}" "${fastq_array_R2[index]}"
    done

    echo ""
    echo "flexbar trimming complete."
    echo ""

    ### END FLEXBAR ###


    ### RUN FASTQC ON TRIMMED READS ###

    ### NOTE: Do NOT quote ${trimmed_fastqc_list}

    # Moved to trimmed reads directory
    cd ../trimmed

    echo "Moving to ${PWD}"
    echo ""

    # FastQC output directory
    output_dir=$(pwd)

    # Create array of trimmed FastQs
    trimmed_fastq_array=(*flexbar_trim*.fastq.gz)

    # Pass array contents to new variable as space-delimited list
    trimmed_fastqc_list=$(echo "${trimmed_fastq_array[*]}")

    # Run FastQC
    echo "Beginning FastQC on trimmed reads..."
    echo ""
    ${programs_array[fastqc]} \
    --threads ${threads} \
    --outdir ${output_dir} \
    ${trimmed_fastqc_list}

    echo ""
    echo "FastQC on trimmed reads complete!"
    echo ""

    ### END FASTQC ###

    ### RUN MULTIQC ###
    echo "Beginning MultiQC on trimmed reads data..."
    echo ""

    ${multiqc} .

    echo ""
    echo "MultiQC on trimmed reads data complete."
    echo ""

    ### END MULTIQC ###

    cd "${working_dir}"

done

####################################################################

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

    # Handle fastp menu
    elif [[ "${program}" == "[`fastp`](https://github.com/OpenGene/fastp)" ]]; then
      ${programs_array[$program]} --help
    else
    ${programs_array[$program]} -h
    fi
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

Output folder:

- []()

