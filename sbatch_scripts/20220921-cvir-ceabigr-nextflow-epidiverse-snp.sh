#!/bin/bash
## Job Name
#SBATCH --job-name=20220921-cvir-ceabigr-nextflow-epidiverse-snp
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20220921-cvir-ceabigr-nextflow-epidiverse-snp



###################################################################################
# These variables need to be set by user

## Directory with BAM(s)
bams_dir="/gscratch/scrubbed/samwhite/outputs/20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms/"

## Location of EpiDiverse/snp pipeline directory
epi_snp="/gscratch/srlab/programs/epidiverse-pipelines/snp"

## FastA file is required to end with .fa
## Requires FastA index file to be present in same directory as FastA
genome_fasta="/gscratch/srlab/sam/data/P_generosa/genomes/Panopea-generosa-v1.0.fa"

## Location of Nextflow
nextflow="/gscratch/srlab/programs/nextflow-21.10.6-all"

## Specify desired/needed version of Nextflow
nextflow_version="20.07.1"


###################################################################################

## Run EpiDiverse/snp
NXF_VER=${nextflow_version} \
${nextflow} run \
${epi_snp} \
--input ${bams_dir} \
--reference ${genome_fasta}

###################################################################################
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