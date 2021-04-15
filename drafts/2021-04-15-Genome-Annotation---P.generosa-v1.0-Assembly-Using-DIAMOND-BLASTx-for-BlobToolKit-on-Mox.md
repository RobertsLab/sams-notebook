---
layout: post
title: Genome Annotation - P.generosa v1.0 Assembly Using DIAMOND BLASTx for BlobToolKit on Mox
date: '2021-04-15 10:17'
tags: 
  - Panopea generosa
  - Pacific geoduck
  - DIAMOND
  - BLASTx
  - mox
categories: 
  - Miscellaneous
---
To continue towards getting our [_Panopea generosa_ (Pacific geoduck)](http://en.wikipedia.org/wiki/Geoduck) genome assembly (v1.0) analyzed with [BlobToolKit](https://blobtoolkit.genomehubs.org/), per [this GitHub Issue](https://github.com/RobertsLab/resources/issues/1118), I've decided to run each aspect of the pipeline manually, as I [continue to have issues utilizing the automatic pipeline](https://github.com/blobtoolkit/insdc-pipeline/issues/9). As such, I've run [`DIAMOND`](https://github.com/bbuchfink/diamond) BLASTx according to the [BlobToolKit "Getting Started" guide](https://blobtoolkit.genomehubs.org/blobtools2/blobtools2-tutorials/getting-started-with-blobtools2/) on Mox.

IMPORTANT: This is BLAST'ed against a customized UniProt database, per the [BlobToolKit instructions here.](https://blobtoolkit.genomehubs.org/install/). For posterity, here're the instuctions provided on the website:

```shell
mkdir -p uniprot
wget -q -O uniprot/reference_proteomes.tar.gz \
 ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/$(curl \
     -vs ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/ 2>&1 | \
     awk '/tar.gz/ {print $9}')
cd uniprot
tar xf reference_proteomes.tar.gz

touch reference_proteomes.fasta.gz
find . -mindepth 2 | grep "fasta.gz" | grep -v 'DNA' | grep -v 'additional' | xargs cat >> reference_proteomes.fasta.gz

echo "accession\taccession.version\ttaxid\tgi" > reference_proteomes.taxid_map
zcat */*/*.idmapping.gz | grep "NCBI_TaxID" | awk '{print $1 "\t" $1 "\t" $3 "\t" 0}' >> reference_proteomes.taxid_map

diamond makedb -p 16 --in reference_proteomes.fasta.gz --taxonmap reference_proteomes.taxid_map --taxonnodes ../taxdump/nodes.dmp -d reference_proteomes.dmnd
cd -
```

SBATCH script (GitHub):

- [20210415_pgen_diamond_blastx_Panopea-generosa-v1.0.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210415_pgen_diamond_blastx_Panopea-generosa-v1.0.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210415_pgen_diamond_blastx_Panopea-generosa-v1.0
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210415_pgen_diamond_blastx_Panopea-generosa-v1.0

### DIAMOND BLASTx of Panopea-generosa-v1.0 against customized UniProt database
### for import into BlobToolKit.
### Output is customized for input into BlobToolKit

###################################################################################
# These variables need to be set by user

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# SegFault fix?
export THREADS_DAEMON_MODEL=1


# Programs array
declare -A programs_array
programs_array=(
[diamond]="/gscratch/srlab/programs/diamond-0.9.29/diamond"
)

# DIAMOND UniProt database
dmnd=/gscratch/srlab/blastdbs/20210401_uniprot_btk/reference_proteomes.dmnd


# Genome (FastA)
fasta=/gscratch/srlab/sam/data/P_generosa/genomes/Panopea-generosa-v1.0.fa

###################################################################################

# Strip leading path and extensions
no_path=$(echo "${fasta##*/}")
no_ext=$(echo "${no_path%.*}")

# Run DIAMOND with blastx
# Customized output format for import into BlobToolKit
${programs_array[diamond]} blastx \
--db ${dmnd} \
--query "${fasta}" \
--out "${no_ext}".blastx.btk.outfmt6 \
--outfmt 6 qseqid staxids bitscore qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore \
--sensitive \
--evalue 1e-25 \
--max-target-seqs 1 \
--block-size 15.0 \
--index-chunks 4

# Generate checksums for future reference
echo ""
echo "Generating checksum for ${fasta}."
md5sum "${fasta}">> fastq.checksums.md5
echo "Completed checksum for ${fasta}."
echo ""

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
```


---

#### RESULTS

Output folder:

- []()

