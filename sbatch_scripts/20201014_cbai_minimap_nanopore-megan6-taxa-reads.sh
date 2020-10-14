#!/bin/bash
## Job Name
#SBATCH --job-name=20201014__cbai_minimap_nanopore-megan6-taxa-reads
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=15-00:00:00
## Memory per node
#SBATCH --mem=12G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201014__cbai_minimap_nanopore-megan6-taxa-reads


###################################################################################
# These variables need to be set by user

## Assign Variables

# CPU threads to use
threads=27

# Genome FastA path
genome_fasta=/gscratch/srlab/sam/data/C_bairdi/genomes/cbai_genome_v1.01.fasta


# Paths to programs
minimap2="/gscratch/srlab/programs/minimap2-2.17_x64-linux/minimap2"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"



# Programs array
declare -A programs_array
programs_array=(
[minimap2]="${minimap2}" \
[samtools_sort]="${samtools} sort" \
[samtools_view]="${samtools} view"
)



###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Capture date
timestamp=$(date +%Y%m%d)

# Loop through each FastQ
for fastq in *.fq
do

  # Parse out sample name
  sample=$(echo "${fastq}" | awk -F"_" '{print $2}')

  # Caputure taxa
  taxa=$(echo "${fastq}" | awk -F"_" '{print $3}')

  # Capture filename prefix
  prefix="${timestamp}_${sample}_${taxa}"

  # Run Minimap2 with Oxford NanoPore Technologies (ONT) option
  # Using SAM output format (-a option)
  ${programs_array[$minimap2]} \
  -ax map-ont \
  ${genome_fasta} \
  ${fastq} \
  | ${programs_array[$samtools_view]} -u --threads ${threads} \
  | ${programs_array[$samtools_sort]} --threads ${threads} \
  > "${prefix}".sorted.bam


  # Capture FastA checksums for verification ()
  echo "Generating checksum for ${fastq}"
  md5sum "${fastq}" > fastq_checksums.md5
  echo "Finished generating checksum for ${fastq}"
  echo ""


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
## Note: Trinity util/support scripts don't have options/help menus
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
