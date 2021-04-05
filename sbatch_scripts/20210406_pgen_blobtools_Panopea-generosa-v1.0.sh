#!/bin/bash
## Job Name
#SBATCH --job-name=20210401_pgen_fastp_10x-genomics
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210401_pgen_fastp_10x-genomics


### Fastp 10x Genomics data used for P.generosa genome assembly by Phase Genomics.
### In preparation for use in BlobToolKit

### Expects input filenames to be in format: *.fastq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

# Pipeline options

evalue="1e-25"
ncbi_tax_id=1049056
species="Panopea generosa"
root=1

# Set number of CPUs to use
threads=40

# Input/output files
genome_fasta=/gscratch/srlab/sam/data/P_generosa/genomes/Panopea-generosa-v1.0.fa
fastq_checksums=fastq_checksums.md5
trimmed_reads_dir=/gscratch/scrubbed/samwhite/outputs/20210401_pgen_fastp_10x-genomics/
config="${genome_fasta##*/}_btk.yaml"

# Programs
blobtools2=/gscratch/srlab/programs/blobtoolkit/blobtools2

# Databases

## BUSCO lineage database directory
busco_dbs=/gscratch/srlab/sam/data/databases/BUSCO

## Blobtools NCBI taxonomy database directory
btk_ncbi_tax_dir=/gscratch/srlab/blastdbs/20210401_ncbi_taxonomy

## NCBI nt database dir
ncbi_db=/gscratch/srlab/blastdbs/20210401_ncbi_nt
ncbi_db_name="nt"

## Uniprot DIAMOND database dir
uniprot_db=/gscratch/srlab/blastdbs/20210401_uniprot_btk
uniprot_db_name=reference_proteomes

# Programs associative array
declare -A programs_array
programs_array=(
[blobltools2]="${blobtools2}" \
[multiqc]="${multiqc}"
)


###################################################################################

# Exit script if any command fails
set -e

# Concatenate all R1 reads
for fastq in ${trimmed_reads_dir}*R1*.fq.gz
do
  echo ""
  echo "Generating checksum for ${fastq}"
  md5sum ${fastq} >> ${fastq_checksums}
  echo "Checksum generated for ${fastq}."

  echo ""
  echo "Concatenating $[fastq} to reads_R1.fq.gz"
  cat ${fastq} >> reads_R1.fq.gz
  echo "Finished concatenating ${fastq} to reads_R1.fq.gz"
done

# Concatenate all R2 reads
for fastq in ${trimmed_reads_dir}*R2*.fq.gz
do
  echo ""
  echo "Generating checksum for ${fastq}"
  md5sum ${fastq} >> ${fastq_checksums}
  echo "Checksum generated for ${fastq}."

  echo ""
  echo "Concatenating $[fastq} to reads_R2.fq.gz"
  cat ${fastq} >> reads_R2.fq.gz
  echo "Finished concatenating ${fastq} to reads_R2.fq.gz"
done


# Create BTK config YAML

{
  printf "%s\n" "assembly:"
  printf "%2s%s\n" "" "accession: draft"
  printf "%2s%s\n" "" "level: scaffold"
  printf "%2s%s\n" "" "prefix: Panopea-generosa-v1.0"
  printf "%s\n" "busco:"
  printf "%2s%s\n" "" "lineages:"
  printf "%4s%s\n" "" "- eukaryota_odb9" "" "- metazoa_odb9"
  printf "%2s%s\n" "" "lineage_dir: ${busco_dbs}"
  printf "%s\n" "reads:"
  printf "%2s%s\n" "paired:"
  printf "%4s%s\n" "" "-"
  printf "%6s%s\n" "" "- reads" "" "- ILLUMINA"
  printf "%s\n" "settings:"
  printf "%2s%s\n" "" "blobtools2_path: ${blobtools2}"
  printf "%2s%s\n" "" "taxonomy: ${btk_ncbi_tax_dir}"
  printf "%2s%s\n" "" "/tmp"
  printf "%2s%s\n" "" "blast_chunk: 100000"
  printf "%2s%s\n" "" "blast_max_chunks: 10"
  printf "%2s%s\n" "" "blast_overlap: 500"
  printf "%2s%s\n" "" "chunk: 1000000"
  printf "%s\n" "similarity:"
  printf "%2s%s\n" "" "defaults:"
  printf "%4s%s\n" "" "evalue: ${evalue}" "" "max_target_seqs: 10" "" "root: ${root}" "" "mask_ids: []"
  printf "%2s%s\n" "" "databases:"
  printf "%4s%s\n" "" "-"
  printf "%6s%s\n" "" "local: ${ncbi_db}" "" "name: ${ncbi_db_name}" "" "source: ncbi" "" "tools: blast" "" "type: nucl"
  printf "%4s%s\n" "" "-"
  printf "%6s%s\n" "" "local: ${uniprot_db}" "" "max_target_seqs: 1" "" "name: ${uniprot_db_name}" "" "source: uniprot" "" "tools: diamond" "" "type: prot"
  printf "%2s%s\n" "" "taxrule: bestsumorder"
  printf "%s\n" "taxon:"
  printf "%2s%s\n" "" "taxid: ${ncbi_tax_id}" "" "name: ${species}"
  printf "%s\n" "keep_intermediates: true"
} >> ${config}


###################################################################################

# Capture program options
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

# Document programs in PATH (primarily for program version ID)
{
  date
  echo ""
  echo "System PATH for $SLURM_JOB_ID"
  echo ""
  printf "%0.s-" {1..10}
  echo "${PATH}" | tr : \\n
} >> system_path.log

echo "Finished logging system PATH"