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
#SBATCH --mem=120G
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


#programs
blat="/gscratch/srlab/programs/blat-v36x5"
detonate="/gscratch/srlab/programs/detonate-1.11/ref-eval/ref-eval"


# Determine length of transcriptomes array
transcriptomes_array_length=${#transcriptomes_array[@]}

# Loop through each comparison
for (( i=0; i < ${transcriptomes_array_length}; i++ ))
do
  for (( j=$((i+1)); j < ${transcriptomes_array_length}; j++ ))
  do
    transcriptome1="${transcriptomes_array[$i]}"
    transcriptome2="${transcriptomes_array[*]:$j:1}"
    comparison1="${transcriptome1}-vs-${transcriptome2}"
    comparison2="${transcriptome2}-vs-${transcriptome1}"

    # Run blat
    ${blat} -minIdentity=80 "${transcriptome2}" "${transcriptome1}" "${comparison1}".psl
    ${blat} -minIdentity=80 "${transcriptome1}" "${transcriptome2}" "${comparison2}".psl

    # Run ref-eval, unweighted scores only
    ${detonate} \
    --scores=nucl,pair,contg \
    --weighted=no \
    --A-seqs "${transcriptome1}" \
    --B-seqs "${transcriptome2}" \
    --A-to-B "${comparison1}".psl \
    --B-to-A "${comparison2}".psl \
    | tee "${comparison1}.scores.txt"
  done
done
