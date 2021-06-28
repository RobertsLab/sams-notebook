---
layout: post
title: Genome Assembly - Olurida_v090 with BGI Illumina and PacBio Hybrid Using Wengan on Mox
date: '2021-05-20 07:38'
tags: 
  - wengan
  - mox
  - Ostrea lurida
  - Olympia oyster
  - BGI
  - PacBio
  - Olurida_v090
  - genome assembly
  - assembly
categories: 
  - Olympia Oyster Genome Assembly
---
[I was recently tasked with adding annotations for our _Ostrea lurida_ genome assembly](https://github.com/RobertsLab/resources/issues/1159) to NCBI. As it turns out, adding just annotation files can't be done since the [genome was initially submitted to ENA](https://robertslab.github.io/sams-notebook/2020/07/08/ENA-Submission-Ostrea-lurida-draft-genome-Olurida_v081.fa.html). Additionally, updating the existing ENA submission with annotations is not possible, as it requires a revocation of the existing genome assembly; requiring a brand new submission. With that being the case, I figured I'd just make a new genome submission with the annotations to NCBI. Unfortunately, there were a number of issues with our genome assembly that were going to require a fair amount of work to resolve. The primary concern was that most of the sequences are considered "low quality" by NCBI (too many and too long stretches of Ns in the sequences). Revising the assembly to make it compatible with the NCBI requirements was going to be too much, so that was abandoned.

So, I decided to look into a low-effort means to try to get a better assembly using a Singularity container running [Wengan](https://github.com/adigenova/wengan) on Mox. It performs assembling and polishing, and is geared towards handling both short- and long-read data. Used all of our BGI Illumina short-read data, as well as all of our PacBio long-read data (see the `fastq_checksums.md5` file in the RESULTS to get a list of all input files.)

I'll refer to the assembly produced here as `Olurida_v090`.


SBATCH script (GitHub):

- [20210520_olur_wegan_genome-assembly.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210520_olur_wegan_genome-assembly.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210520_olur_wegan_genome-assembly
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210520_olur_wegan_genome-assembly

# Script to attempt hybrid genome assembly of O.lurida Illumina and PacBio data using Wengan
# Container built according to instructions here:
# https://github.com/adigenova/wengan


###################################################################################
# These variables need to be set by user

# Set number of CPUs to use
threads=28

# Input/output files
fastq_checksums=fastq_checksums.md5
trimmed_reads_dir=/gscratch/scrubbed/samwhite/outputs/20210518_olur_fastp_bgi
pacbio_reads_dir=/gscratch/srlab/sam/data/O_lurida/DNAseq

# Set genome size in Mbp
genome_size=1900


# Programs associative array
declare -A programs_array
programs_array=()


###################################################################################

# Exit script if any command fails
set -e

# Load Singularity module
module load singularity

# Seeting for Singularity container
export TMPDIR=/tmp

#location of wengan in the container
WENGAN=/wengan/wengan-v0.2-bin-Linux/wengan.pl

# Container name
CONTAINER=wengan_v0.2.sif


# Copy container
rsync -avp /gscratch/srlab/programs/singularity_containers/$CONTAINER .


# Concatenate all R1 reads
for fastq in "${trimmed_reads_dir}"/*_1*.fq.gz
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
for fastq in "${trimmed_reads_dir}"/*_2*.fq.gz
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

# Concatenate all PacBio reads
for fastq in "${pacbio_reads_dir}"/*.fastq.gz
do
  echo ""
  echo "Generating checksum for ${fastq}"
  md5sum "${fastq}" >> ${fastq_checksums}
  echo "Checksum generated for ${fastq}."

  echo ""
  echo "Concatenating ${fastq} to pacbio.clr.fastq.gz"
  cat "${fastq}" >> pacbio.clr.fastq.gz
  echo "Finished concatenating ${fastq} to pacbio.clr.fastq.gz"
done


#run WenganM with singularity exec
singularity exec $CONTAINER perl ${WENGAN} \
 -x pacraw \
 -a M \
 -s reads_1.fastq.gz,reads_2.fastq.gz \
 -l pacbio.clr.fastq.gz \
 -p Olur_v090 \
 -t ${threads} \
 -g ${genome_size}

 # Remove concatenated reads files
 rm *.fastq.gz

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

Runtime was was just under 9hrs:

![Wengan Oly genome assembly on Mox runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210520_olur_wegan_genome-assembly_runtime.png?raw=true)

Output folder:

- [20210520_olur_wegan_genome-assembly/](https://gannet.fish.washington.edu/Atumefaciens/20210520_olur_wegan_genome-assembly/)

  - #### Assembly (FastA):

    - [Olur_v090.SPolished.asm.wengan.fasta (172MB)](https://gannet.fish.washington.edu/Atumefaciens/20210520_olur_wegan_genome-assembly/Olur_v090.SPolished.asm.wengan.fasta)

    - [Olur_v090.SPolished.asm.wengan.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20210520_olur_wegan_genome-assembly/Olur_v090.SPolished.asm.wengan.fasta.fai)

  - #### BED file:

    - [Olur_v090.SPolished.asm.wengan.bed (29MB)](https://gannet.fish.washington.edu/Atumefaciens/20210520_olur_wegan_genome-assembly/Olur_v090.SPolished.asm.wengan.bed)

  - #### Input FastQ checksums:

    - [fastq_checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20210520_olur_wegan_genome-assembly/fastq_checksums.md5)

  - #### Wengan Singularity container:

    - [wengan_v0.2.sif (227MB)](https://gannet.fish.washington.edu/Atumefaciens/20210520_olur_wegan_genome-assembly/wengan_v0.2.sif)


The assembly reulted in 19,009 contigs.

Next up, compare this assembly to our other existing assemblies.