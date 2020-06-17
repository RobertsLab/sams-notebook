---
layout: post
title: Metagenome Assemblies - P.generosa Water Samples Trimmed HiSeqX Data Using Megahit on Mox to Compare pH Treatments
date: '2019-04-15 12:19'
tags:
  - metagenomics
  - metagenome
  - Panopea generosa
  - geoduck
  - megahit
  - mox
categories:
  - Miscellaneous
---

A report involving our work on the geoduck water metagenomics is due later this week and our in-depth analysis for this project using [Anvi'o](http://merenlab.org/software/anvio/) is likely to require at least another week to complete. Even though we have a [broad overview of the metagenomic taxa present in these water samples](https://robertslab.github.io/sams-notebook/2019/03/25/Metagenomics-Taxonomic-Diversity-from-Geoduck-Water-with-BLASTn-and-Krona-Plots.html), we don't have data in a format for comparing across samples/treatments. So, I initiated our simplified pipeline (MEGAHIT > MetaGeneMark > BLASTn > KronaTools) for examining our metagenomic data of the two treatments:

- pH=7.1

- pH=8.2

Here's how the sample names breakdown:

| Sample | Develomental Stage (days post-fertilization) | pH Treatment |
|--------|-------------------------|--------------|
| MG1    | 13                      | 8.2          |
| MG2    | 17                      | 8.2          |
| MG3    | 6                       | 7.1          |
| MG5    | 10                      | 8.2          |
| MG6    | 13                      | 7.1          |
| MG7    | 17                      | 7.1          |

I ran [MEGAHIT](https://github.com/voutcn/megahit) on the [trimmed HiSeqX data](https://robertslab.github.io/sams-notebook/2018/12/11/FastQC-and-Trimming-Metagenomics-(Geoduck)-HiSeqX-Reads-from-20180809.html), but concatenated the corresponding pH treatment FastQ files to create a single assembly for each pH treatment.

SBATCH script (GitHub):

- [20190415_metagenomics_pgen_megahit.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20190415_metagenomics_pgen_megahit.sh)


```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=megahit
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=25-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --workdir=/gscratch/scrubbed/samwhite/outputs/20190415_metagenomics_pgen_megahit

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Load Open MPI module for parallel, multi-node processing

module load icc_19-ompi_3.1.2

# SegFault fix?
export THREADS_DAEMON_MODEL=1

# Document programs in PATH (primarily for program version ID)

date >> system_path.log
echo "" >> system_path.log
echo "System PATH for $SLURM_JOB_ID" >> system_path.log
echo "" >> system_path.log
printf "%0.s-" {1..10} >> system_path.log
echo ${PATH} | tr : \\n >> system_path.log


# variables
wd=$(pwd)
fastq_dir=/gscratch/srlab/sam/data/metagenomics/P_generosa
megahit=/gscratch/srlab/programs/megahit_v1.1.4_LINUX_CPUONLY_x86_64-bin/megahit
bbmap_dir=/gscratch/srlab/programs/bbmap_38.34
samtools=/gscratch/srlab/programs/samtools-1.9/samtools
cpus=28

## Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()
names_array=(pH71 pH82)

# Create list of input FastQs used for concatenation
# Concatenate all pH7.1 R1 FastQs
# Uses parameter substitution to strip path
for fastq in ${fastq_dir}/Library_Geoduck_MG_[367]*_R1_*.gz
do
  echo ${fastq#${fastq_dir}} >> fastq.list.pH71.txt
  cat ${fastq} >> pH71.all.R1.fq.gz
done

# Create list of input FastQs used for concatenation
# Concatenate all pH7.1 R2 FastQs
# Uses parameter substitution to strip path
for fastq in ${fastq_dir}/Library_Geoduck_MG_[367]*_R2_*.gz
do
  echo ${fastq#${fastq_dir}} >> fastq.list.pH71.txt
  cat ${fastq} >> pH71.all.R2.fq.gz
done


# Create list of input FastQs used for concatenation
# Concatenate all pH8.2 R1 FastQs
# Uses parameter substitution to strip path
for fastq in ${fastq_dir}/Library_Geoduck_MG_[125]*_R1_*.gz
do
  echo ${fastq#${fastq_dir}} >> fastq.list.pH82.txt
  cat ${fastq} >> pH82.all.R1.fq.gz
done


# Create list of input FastQs used for concatenation
# Concatenate all pH8.2 R2 FastQs
# Uses parameter substitution to strip path
for fastq in ${fastq_dir}/Library_Geoduck_MG_[125]*_R2_*.gz
do
  echo ${fastq#${fastq_dir}} >> fastq.list.pH82.txt
  cat ${fastq} >> pH82.all.R2.fq.gz
done

# Populate R1 array with concatenated R1 FastQs
for fastq in *R1*.fq.gz
do
  fastq_array_R1+=(${fastq})
done

# Populate R2 array with concatenated R2 FastQs
for fastq in *R2*.gz
do
  fastq_array_R2+=(${fastq})
done

# Loop through samples
for sample in ${!names_array[@]}
do
  sample_name=$(echo ${names_array[sample]})
  mkdir ${sample_name} && cd ${sample_name}
  # Run Megahit using paired-end reads
  ${megahit} \
  -1 ${wd}/${fastq_array_R1[sample]} \
  -2 ${wd}/${fastq_array_R2[sample]} \
  --num-cpu-threads ${cpus} \
  --out-prefix ${sample_name}

  # Create FastA index file
  ${samtools} faidx megahit_out/${sample_name}.contigs.fa

  # Determine coverage
  ## Align reads with BBmap BBwrap
  ${bbmap_dir}/bbwrap.sh \
  ref=megahit_out/${sample_name}.contigs.fa \
  in1=${fastq_array_R1[sample]} \
  in2=${fastq_array_R2[sample]} \
  out=${sample_name}.aln.sam.gz

  ## Output contig coverage
  ${bbmap_dir}/pileup.sh \
  in=${sample_name}.aln.sam.gz \
  out=${sample_name}.coverage.txt

  # Return to working directory
  cd ${wd}
done
```


---

#### RESULTS

This tooks ~16hrs to complete:

![Screencap of inbox notification for Megahit Mox job runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190416-megahit-runtime.png?raw=true)

Output folder:

- [20190415_metagenomics_pgen_megahit/](http://gannet.fish.washington.edu/Atumefaciens/20190415_metagenomics_pgen_megahit/)

pH=7.1 Assembly (FastA) and Index:

- [20190415_metagenomics_pgen_megahit/pH71/megahit_out/pH71.contigs.fa](http://gannet.fish.washington.edu/Atumefaciens/20190415_metagenomics_pgen_megahit/pH71/megahit_out/pH71.contigs.fa)

- [20190415_metagenomics_pgen_megahit/pH71/megahit_out/pH71.contigs.fa.fai](http://gannet.fish.washington.edu/Atumefaciens/20190415_metagenomics_pgen_megahit/pH71/megahit_out/pH71.contigs.fa.fai)

pH=8.2 Assembly (FastA) and Index:

- [20190415_metagenomics_pgen_megahit/pH82/megahit_out/pH82.contigs.fa](http://gannet.fish.washington.edu/Atumefaciens/20190415_metagenomics_pgen_megahit/pH82/megahit_out/pH82.contigs.fa)

- [20190415_metagenomics_pgen_megahit/pH82/megahit_out/pH82.contigs.fa.fai](http://gannet.fish.washington.edu/Atumefaciens/20190415_metagenomics_pgen_megahit/pH82/megahit_out/pH82.contigs.fa.fai)


Next up, MetaGeneMark for gene prediction, followed by BLAST, and Krona plots. That is _extremely_ fast (like, should take less than 10mins!).
