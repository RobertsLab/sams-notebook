#!/bin/bash
## Job Name
#SBATCH --job-name=20230628-E5_coral-ShortStack-sRNAseq
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq

### E5 sRNA-seq alignments using trimmed reads from 20230620 with ShortStack.

### Expects FastQ read directory paths to be formatted like:

# /gscratch/srlab/sam/data/P_meandrina/sRNAseq/trimmed

### Uses trimmed reads from 20230620. Expect FastQ filename format like:

# *flexbar_trim.20230621_[12]*.fastq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set FastQ filename patterns
fastq_pattern='**flexbar_trim.20230621*.fastq.gz'

# Set number of CPUs to use
threads=40


# Input/output files
fastq_checksums=input_fastq_checksums.md5
sRNA_FastA="/gscratch/srlab/sam/data/miRBase/20230628-miRBase-mature.fa"

# Data directories
reads_dir=/gscratch/srlab/sam/data

## Inititalize arrays
trimmed_fastq_array=()



# Species array (must match directory name usage)
species_array=("A_pulchra" "P_meandrina")

# Programs associative array
declare -A programs_array
programs_array=(
    [ShortStack]="ShortStack"
    )

# Genomes associative array
declare -A genomes_array
genomes_array=(
    [A_pulchra]="/gscratch/srlab/sam/data/A_millepora/genomes/GCF_013753865.1_Amil_v2.1_genomic.fna" \
    [P_meandrina]="/gscratch/srlab/sam/data/P_meandrina/genomes/Pocillopora_meandrina_HIv1.assembly.fasta"
    )


###################################################################################

# Exit script if any command fails
set -e

# Load Anaconda
# Uknown why this is needed, but Anaconda will not run if this line is not included.
. "/gscratch/srlab/programs/anaconda3/etc/profile.d/conda.sh"

# Activate flexbar environment
conda activate ShortStack4_env


# Set working directory
working_dir=$(pwd)

for species in "${species_array[@]}"
do
    ## Inititalize arrays
    trimmed_fastq_array=()


    echo "Creating ${species} directory ..." 

    mkdir --parents "${species}"

    # Change to species directory
    cd "${species}"


    # ShortStack output directory
    output_dir=$(pwd)

    echo "Now in ${PWD}."

    # Sync raw FastQ files to working directory
    echo ""
    echo "Transferring files via rsync..."

    rsync --archive --verbose \
    ${reads_dir}/${species}/sRNAseq/trimmed/${fastq_pattern} .

    echo ""
    echo "File transfer complete."
    echo ""

    ### Run ShortStack ###

    ### NOTE: Do NOT quote trimmed_fastq_list
    # Create array of trimmed FastQs
    trimmed_fastq_array=(${fastq_pattern})

    # Pass array contents to new variable as space-delimited list
    trimmed_fastq_list=$(echo "${trimmed_fastq_array[*]}")

    echo "Beginning ShortStack on ${species} sRNAseq using genome FastA:"
    echo "${genomes_array[${species}]}"
    echo ""

    ## Run ShortStack ##
    ${programs_array[ShortStack]} \
    --genomefile "${genomes_array[${species}]}" \
    --readfile ${trimmed_fastq_list} \
    --known_miRNAs ${sRNA_FastA} \
    --dn_mirna \
    --threads ${threads} \
    --outdir ${output_dir}/ShortStack_out

    echo "ShortStack on ${species} complete!"
    echo ""


    ######## Create MD5 checksums for raw FastQs ########

    for fastq in ${fastq_pattern}
    do
        echo "Generating checksum for ${fastq}"
        md5sum "${fastq}" | tee --append ${fastq_checksums}
        echo ""
    done

    ######## END MD5 CHECKSUMS ########

    ######## REMOVE INPUT FASTQS ########
    echo "Removing input FastQs."
    echo ""
    rm ${fastq_pattern}
    echo "Input FastQs removed."
    echo""

    echo "Now moving back to ${working_dir}."
    cd "${working_dir}"
    echo ""

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
    elif [[ "${program}" == "fastp" ]]; then
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
