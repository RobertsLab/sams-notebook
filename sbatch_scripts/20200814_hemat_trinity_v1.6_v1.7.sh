#!/bin/bash
## Job Name
#SBATCH --job-name=hemat_trinity_v1.6_v1.7
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=15-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200814_hemat_trinity_v1.6_v1.7


###################################################################################
# These variables need to be set by user

# Assign Variables
script_path=/gscratch/scrubbed/samwhite/20200814_hemat_trinity_v1.6_v1.7.sh
reads_dir=/gscratch/srlab/sam/data/C_bairdi/RNAseq
transcriptomes_dir=/gscratch/srlab/sam/data/Hematodinium/RNAseq
threads=28
max_mem=$(grep "#SBATCH --mem=" ${script_path} | awk -F [=] '{print $2}')

# Paths to programs
trinity_dir="/gscratch/srlab/programs/trinityrnaseq-v2.9.0"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"


# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
transcriptomes_array=(
"${transcriptomes_dir}"/hemat_transcriptome_v1.6.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v1.7.fasta
)




# Programs array
declare -A programs_array
programs_array=(
[samtools_faidx]="${samtools} faidx" \
[trinity]="${trinity_dir}/Trinity" \
[trinity_stats]="${trinity_dir}/util/TrinityStats.pl" \
[trinity_gene_trans_map]="${trinity_dir}/util/support_scripts/get_Trinity_gene_to_trans_map.pl" \
[trinity_fasta_seq_length]="${trinity_dir}/util/misc/fasta_seq_length.pl"
)



###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Set working directory
wd="/gscratch/scrubbed/samwhite/outputs/20200814_hemat_trinity_v1.6_v1.7"

# Loop through each transcriptome
for transcriptome in "${!transcriptomes_array[@]}"
do

  ## Inititalize arrays
  R1_array=()
  R2_array=()
  reads_array=()

  # Variables
  R1_list=""
  R2_list=""
  trinity_out_dir=""

  transcriptome_name="${transcriptomes_array[$transcriptome]##*/}"
  assembly_stats="${transcriptome_name}_assembly_stats.txt"
  trinity_out_dir="${transcriptome_name}_trinity_out_dir"


  if [[ "${transcriptome_name}" == "hemat_transcriptome_v1.6.fasta" ]]; then

    reads_array=("${reads_dir}"/*megan*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/*megan*R1.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/*megan*R2.fq)

  elif [[ "${transcriptome_name}" == "hemat_transcriptome_v1.7.fasta" ]]; then

    reads_array=("${reads_dir}"/20200[145][13][189]*megan*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/20200[145][13][189]*megan*R1.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/20200[145][13][189]*megan*R2.fq)

  fi

  # Create list of fastq files used in analysis
  ## Uses parameter substitution to strip leading path from filename
  printf "%s\n" "${reads_array[@]##*/}" >> "${transcriptome_name}".fastq.list.txt

  # Create comma-separated lists of FastQ reads
  R1_list=$(echo "${R1_array[@]}" | tr " " ",")
  R2_list=$(echo "${R2_array[@]}" | tr " " ",")


  if [[ "${transcriptome_name}" == "hemat_transcriptome_v1.6.fasta" ]]; then

    # Run Trinity without stranded RNAseq option
    ${programs_array[trinity]} \
    --seqType fq \
    --max_memory "${max_mem}" \
    --CPU ${threads} \
    --output "${trinity_out_dir}" \
    --left "${R1_list}" \
    --right "${R2_list}"

  else

    # Run Trinity with stranded RNAseq option
    ${programs_array[trinity]} \
    --seqType fq \
    --max_memory "${max_mem}" \
    --CPU ${threads} \
    --output "${trinity_out_dir}" \
    --SS_lib_type RF \
    --left "${R1_list}" \
    --right "${R2_list}"

  fi

  # Rename generic assembly FastA
  mv "${trinity_out_dir}"/Trinity.fasta "${trinity_out_dir}"/"${transcriptome_name}"

  # Assembly stats
  ${programs_array[trinity_stats]} "${trinity_out_dir}"/"${transcriptome_name}" \
  > "${assembly_stats}"

  # Create gene map files
  ${programs_array[trinity_gene_trans_map]} \
  "${trinity_out_dir}"/"${transcriptome_name}" \
  > "${trinity_out_dir}"/"${transcriptome_name}".gene_trans_map

  # Create sequence lengths file (used for differential gene expression)
  ${programs_array[trinity_fasta_seq_length]} \
  "${trinity_out_dir}"/"${transcriptome_name}" \
  > "${trinity_out_dir}"/"${transcriptome_name}".seq_lens

  # Create FastA index
  ${programs_array[samtools_faidx]} \
  "${trinity_out_dir}"/"${transcriptome_name}"

  # Copy files to transcriptome directory
  rsync -av \
  "${trinity_out_dir}"/"${transcriptome_name}"* \
  ${transcriptomes_dir}

  # Capture FastA checksums for verification
  cd "${trinity_out_dir}"/
  echo "Generating checksum for ${transcriptome_name}"
  md5sum "${transcriptome_name}" > "${transcriptome_name}".checksum.md5
  echo "Finished generating checksum for ${transcriptome_name}"
  echo ""

  cd ${wd}


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
	${programs_array[$program]} --help
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true
done
