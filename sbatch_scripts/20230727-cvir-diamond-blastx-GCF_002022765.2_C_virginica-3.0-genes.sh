#!/bin/bash
## Job Name
#SBATCH --job-name=20230727-cvir-diamond-blastx-GCF_002022765.2_C_virginica-3.0-genes
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230727-cvir-diamond-blastx-GCF_002022765.2_C_virginica-3.0-genes

### DIAMOND BLASTx of C.virginica GCF_002022765.2_C_virginica-3.0-genes.fasta.
### For use in CEABIGR transcript annotation.


###################################################################################
# These variables need to be set by user

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# SegFault fix?
export THREADS_DAEMON_MODEL=1


# Programs array
declare -A programs_array
programs_array=(
[diamond]="/gscratch/srlab/programs/diamond-v2.1.1/diamond"
)

# DIAMOND UniProt database
dmnd_db="/gscratch/srlab/blastdbs/20230727-uniprot-swissprot-reviewed/uniprot_sprot.dmnd"


# Genome (FastA)
fasta="/gscratch/srlab/sam/data/C_virginica/genomes/GCF_002022765.2_C_virginica-3.0-genes.fasta"

###################################################################################

# Strip leading pat and extensions
no_path=$(echo "${fasta##*/}")

# Strip extension
no_ext=$(echo "${no_path%.*}")

# Run DIAMOND with blastx
${programs_array[diamond]} blastx \
--db ${dmnd_db} \
--query "${fasta}" \
--out "${no_ext}".blastx.outfmt6 \
--outfmt 6 \
--sensitive \
--evalue 1e-25 \
--max-target-seqs 1 \
--block-size 15.0 \
--index-chunks 4

# Generate checksums for future reference
for file in *
do
  echo ""
  echo "Generating checksum for ${file}."
  echo ""

  md5sum "${file}" | tee --append checksums.md5
  
  echo ""
done

echo "Generating checksum for ${fasta}."
echo ""

md5sum "${fasta}" | tee --append checksums.md5


###################################################################################

# Disable exit on error
set +e

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