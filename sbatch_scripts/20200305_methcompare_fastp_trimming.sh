#!/bin/bash
## Job Name
#SBATCH --job-name=pgen_fastp_trimming_EPI
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200305_methcompare_fastp_trimming


### WGBS and RRBS trimming using fastp.


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

# Set number of CPUs to use
threads=27

# Paths to programs
fastp=/gscratch/srlab/programs/fastp-0.20.0/fastp

# Programs array
programs_array=(fastp)


# Capture program options
for program in "${!programs_array[@]}"


# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5

# Inititalize arrays
# These were provided by Hollie Putnam
# See https://github.com/hputnam/Meth_Compare/blob/master/Meth_Compare_Pipeline.md
rrbs_array=(Meth4 Meth5 Meth6 Meth13 Meth14 Meth15)
wgbs_array=(Meth1 Meth2 Meth3  Meth7 Meth8 Meth9 Meth10 Meth11 Meth12 Meth16 Meth17 Meth18)

# Assign file suffixes to variables
read1="_R1_001.fastq.gz"
read2="_R2_001.fastq.gz"

# Create list of fastq files used in analysis
for fastq in *.gz
do
  echo "${fastq}" >> fastq.list.txt
done

# Run fastp on RRBS files
for index in "${!rrbs_array[@]}"
do
	timestamp=$(date +%Y%m%d%M%S)
	${fastp} \
	--in1 "${rrbs_array[index]}${read1}" \
	--in2 "${rrbs_array[index]}${read2}" \
	--detect_adapter_for_pe \
	--thread ${threads} \
	--html "${rrbs_array[index]}".fastp-trim."${timestamp}".report.html \
	--json "${rrbs_array[index]}".fastp-trim."${timestamp}".report.json \
	--out1 "${rrbs_array[index]}".fastp-trim."${timestamp}${read1}" \
	--out2 "${rrbs_array[index]}".fastp-trim."${timestamp}${read2}"

	# Generate md5 checksums for newly trimmed files
	{
		md5sum "${rrbs_array[index]}".fastp-trim."${timestamp}${read1}"
		md5sum "${rrbs_array[index]}".fastp-trim."${timestamp}${read2}"
	} >> "${trimmed_checksums}"

done

# Run fastp on RRBS files
for index in "${!wgbs_array[@]}"
do
	timestamp=$(date +%Y%m%d%M%S)
	${fastp} \
	--in1 "${wgbs_array[index]}" \
	--in2 "${wgbs_array[index]}" \
	--detect_adapter_for_pe \
	--thread ${threads} \
	--html "${wgbs_array[index]}".fastp-trim."${timestamp}".report.html \
	--json "${wgbs_array[index]}".fastp-trim."${timestamp}".report.json \
	--out1 "${wgbs_array[index]}".fastp-trim."${timestamp}${read1}" \
	--out2 "${wgbs_array[index]}".fastp-trim."${timestamp}${read2}"

	# Generate md5 checksums for newly trimmed files
	{
		md5sum "${wgbs_array[index]}".fastp-trim."${timestamp}${read1}"
		md5sum "${wgbs_array[index]}".fastp-trim."${timestamp}${read2}"
	} >> "${trimmed_checksums}"

done
