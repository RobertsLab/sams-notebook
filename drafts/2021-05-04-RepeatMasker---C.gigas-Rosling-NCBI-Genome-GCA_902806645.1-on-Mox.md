---
layout: post
title: RepeatMasker - C.gigas Rosling NCBI Genome GCA_902806645.1 on Mox
date: '2021-05-04 11:33'
tags: 
  - GCA_902806645.1
  - mox
  - repeatmasker
  - Crassostrea gigas
  - Pacific oyster
categories: 
  - Miscellaneous
---
Decided to [tackle this GitHub Issue about creating a transposable elements IGV track with the new Roslin _C.gigas_ genome](https://github.com/RobertsLab/resources/issues/1141), since it had been sitting for a while and I have code sitting around that's ready to roll for this type of thing.

Downloaded the NCBI [_Crassostrea gigas_ (Pacific oyster)](http://en.wikipedia.org/wiki/Pacific_oyster) genome assembly [GCA_902806645.1](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/902/806/645/GCA_902806645.1_cgigas_uk_roslin_v1/GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna.gz) and verified the MD5 checksum (not shown).

NOTE: The above listed NCBI assembly is from the "GenBank" assembly. There is another version, [GCF_902806645.1](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/902/806/645/GCF_902806645.1_cgigas_uk_roslin_v1/GCF_902806645.1_cgigas_uk_roslin_v1_genomic.fna.gz), from NCBI RefSeq. As far as I can tell, the only difference between the two is the sequence IDs; numbers of sequences and their lengths are the same.

Analysis was performed using [RepeatMasker](https://www.repeatmasker.org/) with two different species settings for comparison, if someone is interested.

- "all"

- "[_Crassostrea gigas_ (Pacific oyster)](http://en.wikipedia.org/wiki/Pacific_oyster)"

The analysis was run on Mox.

SBATCH script (GitHub):

- [20210504_cgig_repeatmasker_roslin-GCA_902806645.1.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210504_cgig_repeatmasker_roslin-GCA_902806645.1.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210504_cgig_repeatmasker_roslin-GCA_902806645.1
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=6-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210504_cgig_repeatmasker_roslin-GCA_902806645.1

# Script to run RepeatMasker 4.1.0 on "Roslin" C.gigas NCBI genome assembly GCA_902806645.1


###################################################################################
# These variables need to be set by user

# Set working directory
wd=$(pwd)

# Set number of CPUs to use
threads=40

# Input/output files
source_genome_fasta=/gscratch/srlab/sam/data/C_gigas/genomes/GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna
genome_fasta=GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna

# Programs
## Minimap2
repeat_masker=/gscratch/srlab/programs/RepeatMasker-4.1.0/RepeatMasker

# Species array (used for RepeatMasker species setting)
species=("all" "crassostrea gigas")

# Programs associative array
declare -A programs_array
programs_array=(
[repeat_masker]=${repeat_masker} \
)



###################################################################################

# Exit script if any command fails
set -e


# Generate checksum for "new" FastA
md5sum ${source_genome_fasta} > genome_fasta.md5

for species in "${species[@]}"
do

  # Check species name and create appropriate directory naem
  if [ "${species}" = "crassostrea gigas" ]; then

    mkdir "repeatmasker-species_C.gigas_roslin-GCA_902806645.1" && cd $_
    rsync -av ${source_genome_fasta} .

    else
    mkdir "repeatmasker-species_all_roslin-GCA_902806645.1" && cd $_
    rsync -av ${source_genome_fasta} .

  fi

  # Run RepeatMasker
  # Uses all species
  # Generates GFF output
  # 'excln' calculates repeat densities excluding runs of X/N >20bp
  ${programs_array[repeat_masker]} \
  ${genome_fasta} \
  -species "${species}" \
  -parallel ${threads} \
  -gff \
  -excln
  
  # Remove the genome FastA file
  rm ${genome_fasta}

  cd ${wd}

done

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
```

---

#### RESULTS

Output folder:

- []()

