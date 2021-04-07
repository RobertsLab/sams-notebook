#!/bin/bash
## Job Name
#SBATCH --job-name=20210406_pgen_blobtools_Panopea-generosa-v1.0
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=30-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210406_pgen_blobtools_Panopea-generosa-v1.0


### Script to run the Blobtools2 Pipeline
### on trimmed 10x Genomics/HiC FastQs from 20210401.
### Using to identify sequencing contaminants in Panopea-generosa-v1.0 genome assembly
### Generates a Snakemake config file
### Outputs Blobtools2 JSON files for use in the Blobtools2 viewer

### Utilizes NCBI taxonomy dump and customized UniProt database for DIAMOND BLASTx

### Requires Anaconda to be in system $PATH!

###################################################################################
# These variables need to be set by user

# Pipeline options
## BLASTn evalue
evalue="1e-25"

## NCBI Tax ID and genus/species
ncbi_tax_id=1049056
species="Panopea generosa"

## NCBI Taxonomy Root ID to begin from
root=1

# Set number of CPUs to use
threads=28

# Input/output files
assembly_name=Panopea_generosa_v1
orig_fasta=/gscratch/srlab/sam/data/P_generosa/genomes/Panopea-generosa-v1.0.fa
genome_fasta=/gscratch/srlab/sam/data/P_generosa/genomes/Panopea-generosa-v1.0.fasta
fastq_checksums=fastq_checksums.md5
trimmed_reads_dir=/gscratch/scrubbed/samwhite/outputs/20210401_pgen_fastp_10x-genomics
config="${genome_fasta##*/}_btk.yaml"

# Programs
## Blobtools2 directory
blobtools2=/gscratch/srlab/programs/blobtoolkit/blobtools2

## BTK pipeline directory
btk_pipeline=/gscratch/srlab/programs/blobtoolkit/insdc-pipeline

## Name of conda snakemake environment
snakemake_env_name=snakemake_env

## Conda environment directory
conda_dir=/gscratch/srlab/programs/anaconda3/envs/snakemake_env


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
programs_array=()


###################################################################################

# Exit script if any command fails
set -e

# Set working directory
wd=$(pwd)

# Load Anaconda
# Uknown why this is needed, but Anaconda will not run if this line is not included.
. "/gscratch/srlab/programs/anaconda3/etc/profile.d/conda.sh"

# Rename orginal FastA to comply with BTK naming requirements
rsync -av ${orig_fasta} ${genome_fasta}

# Generate checksum for "new" FastA
md5sum ${genome_fasta} > genome_fasta.md5

# Concatenate all R1 reads
for fastq in "${trimmed_reads_dir}"/*R1*.fq.gz
do
  echo ""
  echo "Generating checksum for ${fastq}"
  md5sum "${fastq}" >> ${fastq_checksums}
  echo "Checksum generated for ${fastq}."

  echo ""
  echo "Concatenating ${fastq} to reads_1.fastq.gz"
  cat "${fastq}" >> reads_1.fastq.gz
  echo "Finished concatenating ${fastq} to reads_1.fastq.gz"
done

# Concatenate all R2 reads
for fastq in "${trimmed_reads_dir}"/*R2*.fq.gz
do
  echo ""
  echo "Generating checksum for ${fastq}"
  md5sum "${fastq}" >> ${fastq_checksums}
  echo "Checksum generated for ${fastq}."

  echo ""
  echo "Concatenating ${fastq} to reads_2.fastq.gz"
  cat "${fastq}" >> reads_2.fastq.gz
  echo "Finished concatenating ${fastq} to reads_2.fastq.gz"
done

# Count scaffolds in assembly
scaffold_count=$(grep -c ">" ${genome_fasta})

# Count nucleotides in assembly
genome_nucleotides_count=$(grep -v ">" ${genome_fasta} | wc | awk '{print $3-$1}')

# Create BTK config YAML
{
  printf "%s\n" "assembly:"
  printf "%2s%s\n" "" "accession: draft" "" "level: scaffold" "" "scaffold-count: ${genome_fasta}" "" "span: ${genome_nucleotides_count}"
  printf "%2s%s\n" "" "prefix: ${assembly_name}"
  printf "%s\n" "busco:"
  printf "%2s%s\n" "" "lineages:"
  printf "%4s%s\n" "" "- eukaryota_odb9" "" "- metazoa_odb9"
  printf "%2s%s\n" "" "lineage_dir: ${busco_dbs}"
  printf "%s\n" "reads:"
  printf "%2s%s\n" "" "paired:"
  printf "%4s%s\n" "" "-"
  printf "%6s%s\n" "" "- reads" "" "- ILLUMINA"
  printf "%s\n" "settings:"
  printf "%2s%s\n" "" "blobtools2_path: ${blobtools2}"
  printf "%2s%s\n" "" "taxonomy: ${btk_ncbi_tax_dir}"
  printf "%2s%s\n" "" "tmp: /tmp"
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


# Run snakemake, btk pipeline
cd ${btk_pipeline}
conda activate ${snakemake_env_name}

snakemake -p \
--use-conda \
--conda-prefix ${conda_dir} \
--directory ${wd}/ \
--configfile ${wd}/${config} \
--stats ${assembly_name}.snakemake.stats \
-j ${threads} \
--resources btk=1

# Change back to working directory
cd ${wd}

###################################################################################

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

echo "Finished logging system PATH"