#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_nanoplot_fastqc_multiqc_nanopore-data
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200909_cbai_nanoplot_fastqc_multiqc_nanopore-data




###################################################################################
# These variables need to be set by user

# Load Miniconda Mox module for Anaconda module availability
module load contrib/Miniconda3/3.0

# Activate the NanoPlot Anaconda environment
conda activate /gscratch/srlab/programs/miniconda3/envs/nanoplot/

# Set number of CPUs to use
threads=28

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5

# Paths to programs
nanoplot=/gscratch/srlab/programs/miniconda3/envs/nanoplot/bin/NanoPlot
fastqc=/gscratch/srlab/programs/fastqc_v0.11.8/fastqc
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc


###################################################################################


# Exit script if any command fails
set -e



# Capture date
timestamp=$(date +%Y%m%d)

# Inititalize array
programs_array=()


# Programs array
programs_array=("${nanoplot}" "${multiqc}" "${fastqc}")

raw_reads_dir_array=(
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL58500_04bb4d86_20102558-2729" \
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL58500_94244ffd_20102558-2729" \
"/gscratch/srlab/sam/data/C_bairdi/DNAseq/ont_FAL86873_d8db260e_cbai_6129_403_26"
)

for directory in "${!raw_reads_dir_array[@]}"
do
  ## Inititalize arrays
  fastq_array_R1=()
  fastq_array_R2=()
  R1_names_array=()
  R2_names_array=()

  # Create array of fastq R1 files
  for fastq in ${raw_reads_dir_array[directory]}/*R1*.gz
  do
    fastq_array_R1+=("${fastq}")
  done

  # Create array of fastq R2 files
  for fastq in ${raw_reads_dir_array[directory]}/*R2*.gz
  do
    fastq_array_R2+=("${fastq}")
  done


  # Create array of sample names
  ## Uses awk to parse out sample name from filename
  for R1_fastq in ${raw_reads_dir_array[directory]}/*R1*.gz
  do
    R1_fastq=${R1_fastq##*/}
    R1_names_array+=($(echo "${R1_fastq}" | awk -F"." '{print $1}'))
  done

  # Create array of sample names
  ## Uses awk to parse out sample name from filename
  for R2_fastq in ${raw_reads_dir_array[directory]}/*R2*.gz
  do
    R2_fastq=${R2_fastq##*/}
    R2_names_array+=($(echo "${R2_fastq}" | awk awk -F"." '{print $1, $2}'))
  done

  # Create list of fastq files used in analysis
  for fastq in ${raw_reads_dir_array[directory]}/*.gz
  do
    echo "${fastq}" >> fastq.list.txt
  done

  # Run fastp on files
  # Trim 10bp from 5' from each read
  for fastq in "${!fastq_array_R1[@]}"
  do
    R1_sample_name=$(echo "${R1_names_array[fastq]}")
  	R2_sample_name=$(echo "${R2_names_array[fastq]}")
  	${fastp} \
  	--in1 "${fastq_array_R1[fastq]}" \
  	--in2 "${fastq_array_R2[fastq]}" \
  	--detect_adapter_for_pe \
    --trim_front1 10 \
    --trim_front2 10 \
  	--thread ${threads} \
  	--html "${R1_sample_name}".fastp-trim."${timestamp}".report.html \
  	--json "${R1_sample_name}".fastp-trim."${timestamp}".report.json \
  	--out1 "${R1_sample_name}".fastp-trim."${timestamp}".fq.gz \
  	--out2 "${R2_sample_name}".fastp-trim."${timestamp}".fq.gz

  	# Run FastQC
  	${fastqc} --threads ${threads} \
  	"${R1_sample_name}".fastp-trim."${timestamp}".fq.gz \
  	"${R2_sample_name}".fastp-trim."${timestamp}".fq.gz

  done
done



# Run MultiQC
${multiqc} .

# Capture program options
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${programs_array[program]}: "
	echo ""
	${programs_array[program]} -h
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true
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
