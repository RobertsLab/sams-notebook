#!/bin/bash
## Job Name
#SBATCH --job-name=202202308_cvir_trinity-gg_adult-oa-gonad_assembly-1.0
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/202202308_cvir_trinity-gg_adult-oa-gonad_assembly-1.0

### Genome-guided (NCBI RefSeq GCF_002022765.2) de novo transcriptome assembly of C.virginica adult OA gonda RNAseq.
### See input_fastqs.md5 file for list of input files used for assembly.

### Expects input FastQs to be in following format: *R[12].fastp-trim.20bp-5prime.20220224.fq.gz 


###################################################################################
# These variables need to be set by user

## Assign Variables

# These variables need to be set by user

# RNAseq FastQs directory
reads_dir=/gscratch/srlab/sam/data/C_virginica/RNAseq

# Inititalize arrays
# Leave empty!!
R1_array=()
R2_array=()

# Variables for R1/R2 lists
# Leave empty!!!
R1_list=""
R2_list=""

# Create array of fastq R1 files
# Set filename pattern
R1_array=("${reads_dir}"/*R1.fastp-trim.20bp-5prime.20220224.fq.gz)

# Create array of fastq R2 files
# Set filename pattern
R2_array=("${reads_dir}"/*R2.fastp-trim.20bp-5prime.20220224.fq.gz)

# Transcriptomes directory
transcriptomes_dir=/gscratch/srlab/sam/data/C_virginica/transcriptomes

# CPU threads
threads=40

# Recommended maximum memory is 100GB, per Trinity developer
max_mem=100G

# BAM file for genome guided assembly
sorted_bam=/gscratch/scrubbed/samwhite/outputs/20220225_cvir_stringtie_GCF_002022765.2_isoforms/20220225_cvir_stringtie_GCF_002022765-sorted-bams-merged.bam

# Max intron size
max_intron=10000

# Name output files
fasta_name="cvir_GG-GCF_002022765.2_adult-gonad_transcriptome_v1.0.fasta"
assembly_stats="${fasta_name}_assembly_stats.txt"

# Paths to programs
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"
trinity_dir="/gscratch/srlab/programs/trinityrnaseq-v2.12.0"
trinity=${trinity_dir}/Trinity


# Programs associative array
declare -A programs_array
programs_array=(
[samtools_faidx]="${samtools} faidx" \
[samtools_index]="${samtools} index" \
[samtools_sort]="${samtools} sort" \
[samtools_view]="${samtools} view" \
[trinity]="${trinity}" \


)

###################################################################################

# Exit script if a command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017



# Create list of fastq files used in analysis
## Uses parameter substitution to strip leading path from filename
for fastq in "${!R1_array[@]}"
do
  {
    md5sum "${R1_array[${fastq}]}"
    md5sum "${R2_array[${fastq}]}"
  } >> input_fastqs.md5
done

# Create comma-separated lists of FastQ reads
R1_list=$(echo "${R1_array[@]}" | tr " " ",")
R2_list=$(echo "${R2_array[@]}" | tr " " ",")


# Run Trinity
## Running as "stranded" (--SS_lib_type)
${programs_array[trinity]} \
--genome_guided_bam ${sorted_bam} \
--genome_guided_max_intron ${max_intron} \
--seqType fq \
--SS_lib_type RF \
--max_memory ${max_mem} \
--CPU ${threads} \
--left "${R1_list}" \
--right "${R2_list}"

# Rename generic assembly FastA
find . -name "Trinity*.fasta" -exec mv {} trinity_out_dir/"${fasta_name}" \;

# Assembly stats
${trinity_dir}/util/TrinityStats.pl trinity_out_dir/"${fasta_name}" \
> ${assembly_stats}

# Create gene map files
${trinity_dir}/util/support_scripts/get_Trinity_gene_to_trans_map.pl \
trinity_out_dir/"${fasta_name}" \
> "${fasta_name}".gene_trans_map

# Create sequence lengths file (used for differential gene expression)
${trinity_dir}/util/misc/fasta_seq_length.pl \
trinity_out_dir/"${fasta_name}" \
> "${fasta_name}".seq_lens

# Move FastA to working directory
mv trinity_out_dir/"${fasta_name}" .

# Create FastA index
${programs_array[samtools_faidx]} \
"${fasta_name}"

# Copy files to transcriptome directory
rsync -av \
"${fasta_name}"* \
"${transcriptomes_dir}"

# Cleanup
rm -rf trinity_out_dir/

# Generate MD5 checksums
for file in *
do
  echo ""
  echo "Generating MD5 checksums for ${file}:"
  md5sum "${file}" | tee --append checksums.md5
  echo ""
done


#######################################################################################################

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
