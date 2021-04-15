---
layout: post
title: Genome Annotation - P.generosa v1.0 Assembly Using BLASTn for BlobToolKit on Mox
date: '2021-04-15 10:15'
tags: 
  - Panopea generosa
  - Pacific geoduck
  - BLASTn
  - mox
categories: 
  - Miscellaneous
---
To continue towards getting our [_Panopea generosa_ (Pacific geoduck)](http://en.wikipedia.org/wiki/Geoduck) genome assembly (v1.0) analyzed with [BlobToolKit](https://blobtoolkit.genomehubs.org/), per [this GitHub Issue](https://github.com/RobertsLab/resources/issues/1118), I've decided to run each aspect of the pipeline manually, as I [continue to have issues utilizing the automatic pipeline](https://github.com/blobtoolkit/insdc-pipeline/issues/9). As such, I've run [`BLASTn`](https://www.ncbi.nlm.nih.gov/books/NBK279690/) according to the [BlobToolKit "Getting Started" guide](https://blobtoolkit.genomehubs.org/blobtools2/blobtools2-tutorials/getting-started-with-blobtools2/) on Mox.

SBATCH script (GitHub):

- [20210415_pgen_blastn-nt_Panopea-generosa-v1.0.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210415_pgen_blastn-nt_Panopea-generosa-v1.0.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210415_pgen_blastn-nt_Panopea-generosa-v1.0
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210415_pgen_blastn-nt_Panopea-generosa-v1.0


### BLASTn of P.generosa genome assembly Panopea-generosa-v1.0.fa
### against NCBI nt database.
### In preparation for use in BlobTools2


###################################################################################
# These variables need to be set by user

# Set number of CPUs to use
threads=40

# Input/output files
fasta="/gscratch/srlab/sam/data/P_generosa/genomes/Panopea-generosa-v1.0.fa"
blast_db="/gscratch/srlab/blastdbs/20210401_ncbi_nt/nt"

# Programs
blastn="/gscratch/srlab/programs/ncbi-blast-2.10.1+/bin/blastn"


# Programs associative array
declare -A programs_array
programs_array=(
[blastn]="${blastn}"
)


###################################################################################

# Exit script if any command fails
set -e


# Run BLASTn with custom format/settings for use in blobtools2
${programs_array[blastn]} \
-db ${blast_db} \
-query ${fasta} \
-outfmt "6 qseqid staxids bitscore std" \
-max_target_seqs 10 \
-max_hsps 1 \
-evalue 1e-25 \
-num_threads ${threads} \
-out Panopea-generosa-v1.0_blobtools2_blast.out


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
  elif [[ "${program}" == "blastx" ]] \
  || [[ "${program}" == "blastn" ]]; then
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
```


---

#### RESULTS

Output folder:

- []()

