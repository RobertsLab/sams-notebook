#!/bin/bash
## Job Name
#SBATCH --job-name=20230526-pmea-repeatmasker-Pocillopora_meandrina_HIv1.assembly
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=05-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230526-pmea-repeatmasker-Pocillopora_meandrina_HIv1.assembly


## Identify repeats with repeatmasker using Pocillopora_meandrina_HIv1.assembly

## Genome FastA from here: http://cyanophora.rutgers.edu/Pocillopora_meandrina/

###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=28

# Species to use for RepeatMasker
species="all"

# Paths to programs
repeatmasker="/gscratch/srlab/programs/RepeatMasker-4.1.0/repeatmasker"

# Input files/directories
genome_index_dir="/gscratch/srlab/sam/data/P_meandrina/genomes"
genome_fasta="${genome_index_dir}/Pocillopora_meandrina_HIv1.assembly.fasta"

# Programs associative array
declare -A programs_array
programs_array=(
[repeatmasker]="${repeatmasker}"
)

###################################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python3 module availability
module load intel-python3_2017

# SegFault fix?
export THREADS_DAEMON_MODEL=1

# #### Run RepeatMasker with _all_ species setting and following options:
# 
# -species "all" : Sets species to all
# 
# -par ${cpus} : Use n CPU threads
# 
# -gff : Create GFF output file (in addition to default files)
# 
# -excln : Adjusts output table calculations to exclude sequence runs of >=25 Ns. Useful for draft genome assemblies.

"${programs_array[repeatmasker]}" \
${genome_fasta} \
-species ${species} \
-par ${threads} \
-gff \
-excln \
-dir .

# Generate checksums
echo ""
echo "Generating checksum for input FastA"
echo "${genome_fasta}..."

md5sum "${genome_fasta}" | tee --append checksums.md5

echo ""

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

    # Handle NCBI BLASTx/repeatmasker menu
    elif [[ "${program}" == "blastx" ]] \
    || [[ "${program}" == "repeatmasker" ]]; then
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
echo "Logging system PATH..."

{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log

echo "Finished logging system $PATH."
echo ""

echo "Script complete!"
