#!/bin/bash
## Job Name
#SBATCH --job-name=202001029_ssal_RNAseq_fastp_trimming
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-00:00:00
## Memory per node
#SBATCH --mem=200G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/202001029_ssal_RNAseq_fastp_trimming


### S.salar RNAseq trimming using fastp, and MultiQC.

### Expects input FastQ files to be in format: Pool26_16_P_31_1.fastq.gz



###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=27

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5
raw_reads_dir=/gscratch/srlab/sam/data/S_salar/RNAseq/
fastq_checksums=raw_fastq_checksums.md5

# Paths to programs
fastp=/gscratch/srlab/programs/fastp-0.20.0/fastp
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc

## Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()
programs_array=()
R1_names_array=()
R2_names_array=()

# Programs array
programs_array=("${fastp}" "${multiqc}")

###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Sync raw FastQ files to working directory
rsync --archive --verbose \
"${raw_reads_dir}"*.gz .

# Create arrays of fastq R1 files and sample names
for fastq in *_1.fastq.gz
do
  fastq_array_R1+=("${fastq}")
	R1_names_array+=($(echo "${R1_fastq}" | awk -F"." '{print $1}'))
done

# Create array of fastq R2 files
for fastq in *_2.fastq.gz
do
  fastq_array_R2+=("${fastq}")
	R2_names_array+=($(echo "${R2_fastq}" | awk -F"." '{print $1}'))
done

# Create list of fastq files used in analysis
# Create MD5 checksum for reference
for fastq in *.gz
do
  echo "${fastq}" >> fastq.list.txt
	md5sum >> ${fastq_checksums}
done

# Run fastp on files
# Adds JSON report output for downstream usage by MultiQC
for index in "${!fastq_array_R1[@]}"
do
	timestamp=$(date +%Y%m%d%M%S)
  R1_sample_name=$(echo "${R1_names_array[index]}")
	R2_sample_name=$(echo "${R2_names_array[index]}")
	${fastp} \
	--in1 "${fastq_array_R1[index]}" \
	--in2 "${fastq_array_R2[index]}" \
	--detect_adapter_for_pe \
	--thread ${threads} \
	--html "${R1_sample_name}".fastp-trim."${timestamp}".report.html \
	--json "${R1_sample_name}".fastp-trim."${timestamp}".report.json \
	--out1 "${R1_sample_name}".fastp-trim."${timestamp}".fq.gz \
	--out2 "${R2_sample_name}".fastp-trim."${timestamp}".fq.gz

	# Generate md5 checksums for newly trimmed files
	{
		md5sum "${R1_sample_name}".fastp-trim."${timestamp}".fq.gz
		md5sum "${R2_sample_name}".fastp-trim."${timestamp}".fq.gz
	} >> "${trimmed_checksums}"
	# Remove original FastQ files
	rm "${fastq_array_R1[index]}" "${fastq_array_R2[index]}"
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
