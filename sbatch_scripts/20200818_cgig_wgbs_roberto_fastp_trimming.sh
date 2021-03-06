#!/bin/bash
## Job Name
#SBATCH --job-name=cgigas_fastp_trimming_roberto_wgbs
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200818_cgig_wgbs_roberto_fastp_trimming

### Roberto's C.gigas WGBS trimming using fastp.


###################################################################################
# These variables need to be set by user

# Set number of CPUs to use
threads=28

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5
raw_reads_dir=/gscratch/srlab/sam/data/C_gigas/wgbs/

# Paths to programs
fastp=/gscratch/srlab/programs/fastp-0.20.0/fastp
fastqc=/gscratch/srlab/programs/fastqc_v0.11.8/fastqc
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc


###################################################################################


# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Capture date
timestamp=$(date +%Y%m%d)

## Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()
programs_array=()
R1_names_array=()
R2_names_array=()

# Programs array
programs_array=("${fastp}" "${multiqc}" "${fastqc}")


# Sync raw FastQ files to working directory
rsync --archive --verbose \
"${raw_reads_dir}"[035]*.fastq.gz .


# Create array of fastq R1 files
for fastq in *R1*.gz
do
  fastq_array_R1+=("${fastq}")
done

# Create array of fastq R2 files
for fastq in *R2*.gz
do
  fastq_array_R2+=("${fastq}")
done


# Create array of sample names
## Uses awk to parse out sample name from filename
for R1_fastq in *R1*.gz
do
  R1_names_array+=($(echo "${R1_fastq}" | awk 'BEGIN {OFS="_";FS="_"} {print $1, $2}'))
done

# Create array of sample names
## Uses awk to parse out sample name from filename
for R2_fastq in *R2*.gz
do
  R2_names_array+=($(echo "${R2_fastq}" | awk 'BEGIN {OFS="_";FS="_"} {print $1, $2}'))
done

# Create list of fastq files used in analysis
for fastq in *.gz
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

	# Generate md5 checksums for newly trimmed files
	{
		md5sum "${R1_sample_name}".fastp-trim."${timestamp}".fq.gz
		md5sum "${R2_sample_name}".fastp-trim."${timestamp}".fq.gz
	} >> "${trimmed_checksums}"

	# Run FastQC
	${fastqc} --threads ${threads} \
	"${R1_sample_name}".fastp-trim."${timestamp}".fq.gz \
	"${R2_sample_name}".fastp-trim."${timestamp}".fq.gz

	# Remove original FastQ files
	rm "${fastq_array_R1[fastq]}" "${fastq_array_R2[fastq]}"
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
