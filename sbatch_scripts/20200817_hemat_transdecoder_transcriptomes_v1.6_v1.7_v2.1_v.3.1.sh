#!/bin/bash
## Job Name
#SBATCH --job-name=hemat_transdecoder_transcriptomes_v1.6_v1.7_v2.1_v.3.1
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=14-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200817_hemat_transdecoder_transcriptomes_v1.6_v1.7_v2.1_v.3.1

# Script to run TransDecoder on Hematodinium transcriptomes:
# v1.6, v1.7, v2.1, v3.1

###################################################################################
# These variables need to be set by user

# Capture date. E.g. format is: 20190820
timestamp=$(date +"%Y%m%d")

transcriptomes_dir=/gscratch/srlab/sam/data/Hematodinium/transcriptomes

# Paths to program directories
blast_dir="/gscratch/srlab/programs/ncbi-blast-2.8.1+/bin"
hmmer_dir="/gscratch/srlab/programs/hmmer-3.2.1/src"
transdecoder_dir="/gscratch/srlab/programs/TransDecoder-v5.5.0"

# Paths to Trinotate databases
pfam_db="/gscratch/srlab/programs/Trinotate-v3.1.1/admin/Pfam-A.hmm"
sp_db="/gscratch/srlab/programs/Trinotate-v3.1.1/admin/uniprot_sprot.pep"

# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
declare -A transcriptomes_gene_maps_array
transcriptomes_gene_maps_array=(
["${transcriptomes_dir}/hemat_transcriptome_v1.6.fasta"]="${transcriptomes_dir}/hemat_transcriptome_v1.6.fasta.gene_trans_map" \
["${transcriptomes_dir}/hemat_transcriptome_v1.7.fasta"]="${transcriptomes_dir}/hemat_transcriptome_v1.7.fasta.gene_trans_map" \
["${transcriptomes_dir}/hemat_transcriptome_v2.1.fasta"]="${transcriptomes_dir}/hemat_transcriptome_v2.1.fasta.gene_trans_map" \
["${transcriptomes_dir}/hemat_transcriptome_v3.1.fasta"]="${transcriptomes_dir}/hemat_transcriptome_v3.1.fasta.gene_trans_map"
)


declare -A programs_array
programs_array=(
[blastp]="${blast_dir}/blastp" \
[hmmscan]="${hmmer_dir}/hmmscan" \
[transdecoder_lORFs]="${transdecoder_dir}/TransDecoder.LongOrfs" \
[transdecoder_predict]="${transdecoder_dir}/TransDecoder.Predict"
)

threads=28

###################################################################################

# Exit script if a command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017


for transcriptome in "${!transcriptomes_gene_maps_array[@]}"
do

  # Remove path from transcriptome using parameter substitution
  transcriptome_name="${transcriptome##*/}"

  # Set a prefix that utilizes timestamp and name of transcriptome
  prefix="${timestamp}_${transcriptome_name}"

  # Make output directory and change to directory
  mkdir --parents "${prefix}.transdecoder" && cd "$_"

  # Paths to input/output files

  blastp_out_dir="${prefix}.blastp_out"
  pfam_out_dir="${prefix}.pfam_out"

  # Make output directories
  mkdir "${blastp_out_dir}"
  mkdir "${pfam_out_dir}"

  blastp_out="${blastp_out_dir}/${prefix}.blastp.outfmt6"
  pfam_out="${pfam_out_dir}/${prefix}.pfam.domtblout"
  lORFs_pep="${prefix}.longest_orfs.pep"



  # Extract long open reading frames
  "${programs_array[transdecoder_lORFs]}" \
  --gene_trans_map "${transcriptomes_gene_maps_array[$transcriptome]}" \
  -t "${transcriptome}"

  # Run blastp on long ORFs
  "${programs_array[blastp]}" \
  -query "${lORFs_pep}" \
  -db "${sp_db}" \
  -max_target_seqs 1 \
  -outfmt 6 \
  -evalue 1e-5 \
  -num_threads ${threads} \
  > "${blastp_out}"

  # Run pfam search
  "${programs_array[hmmscan]}" \
  --cpu ${threads} \
  --domtblout "${pfam_out}" \
  "${pfam_db}" \
  "${lORFs_pep}"

  # Run Transdecoder with blastp and Pfam results
  "${programs_array[transdecoder_predict]}" \
  -t "${transcriptome}" \
  --retain_pfam_hits "${pfam_out}" \
  --retain_blastp_hits "${blastp_out}"

  # Capture FastA MD5 checksum for future reference
  md5sum "${transcriptome}" > "${prefix}".checksum.md5

  # Move back up to main directory
  cd ..

done


# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log

# Capture program options
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${program}: "
	echo ""
	${programs_array[$program]} -h
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true
done
