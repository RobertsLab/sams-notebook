#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_detonate_transcriptome_comparisons
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200529_cbai_detonate_transcriptome_comparisons


###################################################################################
# These variables need to be set by user

# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
transcriptomes_array=(
cbai_transcriptome_v1.0.fa \
cbai_transcriptome_v1.5.fa \
cbai_transcriptome_v1.6.fa \
cbai_transcriptome_v1.7.fa \
cbai_transcriptome_v2.0.fa \
cbai_transcriptome_v3.0.fa \
20200526.P_trituberculatus.Trinity.fa \
GFFJ01.1.fa \
GBXE01.1.fa
)


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log


threads=28

#programs
pblat="/gscratch/srlab/programs/pblat-2.1/pblat"
detonate="/gscratch/srlab/programs/detonate-1.11/ref-eval/ref-eval"


# Determine length of transcriptomes array
transcriptomes_array_length=${#transcriptomes_array[@]}

# Loop through each comparison
for (( i=0; i < transcriptomes_array_length; i++ ))
do
  transcriptome1="${transcriptomes_array[$i]}"

  # Capture FastA checksums for verification
  echo "Generating checksum for ${transcriptome1}"
  md5sum "${transcriptome1}" >> fasta.checksums.md5
  echo "Finished generating checksum for ${transcriptome1}"
  echo ""

  for (( j=0; j < transcriptomes_array_length; j++ ))
  do
    # Don't run comparison of the same transcriptome
    if [[ "${transcriptomes_array[$j]}" != "${transcriptomes_array[$i]}" ]]; then
      transcriptome2="${transcriptomes_array[$j]}"
      comparison1="${transcriptome1}-vs-${transcriptome2}"
      comparison2="${transcriptome2}-vs-${transcriptome1}"

      # Check if pblat output files are not present
      if [[ ! -f "${comparison1}.psl" ]] && [[  -f "${comparison2}".psl ]]; then
        # Run pblat
        echo "Starting pblat: ${comparison1}"
        ${pblat} -minIdentity=80 -threads=${threads} "${transcriptome2}" "${transcriptome1}" "${comparison1}".psl
        echo "Finished pblat: ${comparison1}"
        echo ""

        echo "Starting pblat: ${comparison2}"
        ${pblat} -minIdentity=80 -threads=${threads} "${transcriptome1}" "${transcriptome2}" "${comparison2}".psl
        echo "Finished pblat: ${comparison2}"
        echo ""
      fi

      # Check if DETONATE output file exists
      if [[ ! -f "${comparison1}.scores.txt" ]]; then
        # Run ref-eval, unweighted scores only
        echo "Running DETONATE with ${transcriptome1} and ${transcriptome2}."
        ${detonate} \
        --scores=nucl,pair,contig \
        --weighted=no \
        --A-seqs "${transcriptome1}" \
        --B-seqs "${transcriptome2}" \
        --A-to-B "${comparison1}".psl \
        --B-to-A "${comparison2}".psl \
        | tee "${comparison1}.scores.txt"
        echo "Finished DETONATE with ${transcriptome1} and ${transcriptome2}."
        echo ""
      fi
    fi


  done
done
