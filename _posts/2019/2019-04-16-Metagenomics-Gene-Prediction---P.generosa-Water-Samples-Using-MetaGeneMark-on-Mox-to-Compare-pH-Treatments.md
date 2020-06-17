---
layout: post
title: Metagenomics Gene Prediction - P.generosa Water Samples Using MetaGeneMark on Mox to Compare pH Treatments
date: '2019-04-16 12:50'
tags:
  - metagenomics
  - metagenemark
  - Panopea generosa
  - geoduck
  - mox
categories:
  - Miscellaneous
---
Continuing with a relatively quick comparison of pH treatments (pH=7.1 vs. pH=8.2), I wanted to run gene prediction on the [MEGAHIT assemblies I made yesterday](https://robertslab.github.io/sams-notebook/2019/04/15/Metagenome-Assemblies-P.generosa-Water-Samples-Trimmed-HiSeqX-Data-Using-Megahit-on-Mox-to-Compare-pH-Treatments.html). I ran [MetaGeneMark](http://opal.biology.gatech.edu/GeneMark/) on the two pH-specific assemblies on Mox. This should be a _very_ fast process (I'm talking, like a couple of minutes fast), so it enhances the annotation with very little effort and time.

This will output a nucleotides FastA, proteins FastA, and a GFF for each of the two assemblies (i.e. pH treatments).

Here's how the sample names breakdown:

| Sample | Develomental Stage (days post-fertilization) | pH Treatment |
|--------|-------------------------|--------------|
| MG1    | 13                      | 8.2          |
| MG2    | 17                      | 8.2          |
| MG3    | 6                       | 7.1          |
| MG5    | 10                      | 8.2          |
| MG6    | 13                      | 7.1          |
| MG7    | 17                      | 7.1          |

SBATCH script (GitHub):

- [20190416_metagenomics_pgen_metagenemark.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20190416_metagenomics_pgen_metagenemark.sh)


```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=mgm
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=20-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --workdir=/gscratch/scrubbed/samwhite/outputs/20190416_metagenomics_pgen_metagenemark

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

# Programs
gmhmmp="/gscratch/srlab/programs/MetaGeneMark_linux_64_3.38/mgm/gmhmmp"
mgm_mod="/gscratch/srlab/programs/MetaGeneMark_linux_64_3.38/mgm/MetaGeneMark_v1.mod"
samtools="/gscratch/srlab/programs/samtools-1.9/samtools"

# Variables
assemblies_dir=/gscratch/scrubbed/samwhite/outputs/20190415_metagenomics_pgen_megahit

## Initialize array
assemblies_array=()

# Populate array with MegaHit FastAs
assemblies_array=$(find ${assemblies_dir} -maxdepth 3 -name "*.contigs.fa")

# List of files in array
printf "%s\n" "${assemblies_array[@]}" >> fastas.list.txt

# Loop through array and run MetaGeneMark
# Parse out sample name by removing .contigs.fa from filename
# and remove path
for sample in ${assemblies_array[@]}
do
  no_ext=${sample%%.*}
  sample_name=$(echo ${no_ext##*/})
  # Run MetaGeneMark
  ## Specifying the following:
  ### -a : output predicted proteins
  ### -A : write predicted proteins to designated file
  ### -d : output predicted nucleotides
  ### -D : write predicted nucleotides to designated file
  ### -f 3 : Output format in GFF3
  ### -m : Model file (supplied with software)
  ### -o : write GFF3 to designated file
  ${gmhmmp} \
  -a \
  -A ${sample_name}.mgm-proteins.fasta \
  -d \
  -D ${sample_name}.mgm-nucleotides.fasta \
  -f 3 \
  -m ${mgm_mod} \
  ${sample} \
  -o ${sample_name}.mgm.gff
done

# Index FastAs
for fasta in *.fasta
do
  ${samtools} faidx ${fasta}
done
```

---

#### RESULTS

As predicted, this completed really quickly - 7.5 _minutes_!

Output folder:

- [20190416_metagenomics_pgen_metagenemark/](http://gannet.fish.washington.edu/Atumefaciens/20190416_metagenomics_pgen_metagenemark/)

pH=7.1 Outputs:

- [20190416_metagenomics_pgen_metagenemark/pH71.mgm-nucleotides.fasta](http://gannet.fish.washington.edu/Atumefaciens/20190416_metagenomics_pgen_metagenemark/pH71.mgm-nucleotides.fasta)

- [20190416_metagenomics_pgen_metagenemark/pH71.mgm-nucleotides.fasta.fai](http://gannet.fish.washington.edu/Atumefaciens/20190416_metagenomics_pgen_metagenemark/pH71.mgm-nucleotides.fasta.fai)

- [20190416_metagenomics_pgen_metagenemark/pH71.mgm-proteins.fasta](http://gannet.fish.washington.edu/Atumefaciens/20190416_metagenomics_pgen_metagenemark/pH71.mgm-proteins.fasta)

- [20190416_metagenomics_pgen_metagenemark/pH71.mgm-proteins.fasta.fai](http://gannet.fish.washington.edu/Atumefaciens/20190416_metagenomics_pgen_metagenemark/pH71.mgm-proteins.fasta.fai)

- [20190416_metagenomics_pgen_metagenemark/pH71.mgm.gff](http://gannet.fish.washington.edu/Atumefaciens/20190416_metagenomics_pgen_metagenemark/pH71.mgm.gff)


pH=8.2 Outputs:

- [20190416_metagenomics_pgen_metagenemark/pH82.mgm-nucleotides.fasta](http://gannet.fish.washington.edu/Atumefaciens/20190416_metagenomics_pgen_metagenemark/pH82.mgm-nucleotides.fasta)

- [20190416_metagenomics_pgen_metagenemark/pH82.mgm-nucleotides.fasta.fai](http://gannet.fish.washington.edu/Atumefaciens/20190416_metagenomics_pgen_metagenemark/pH82.mgm-nucleotides.fasta.fai)

- [20190416_metagenomics_pgen_metagenemark/pH82.mgm-proteins.fasta](http://gannet.fish.washington.edu/Atumefaciens/20190416_metagenomics_pgen_metagenemark/pH82.mgm-proteins.fasta)

- [20190416_metagenomics_pgen_metagenemark/pH82.mgm-proteins.fasta.fai](http://gannet.fish.washington.edu/Atumefaciens/20190416_metagenomics_pgen_metagenemark/pH82.mgm-proteins.fasta.fai)

- [20190416_metagenomics_pgen_metagenemark/pH82.mgm.gff](http://gannet.fish.washington.edu/Atumefaciens/20190416_metagenomics_pgen_metagenemark/pH82.mgm.gff)


Next, annotate these using BLASTn (will probably do BLASTp eventually, too, but this will take significantly longer and Steven need's some data from this comparison before the end of the week) and then visualize with KronaTools.
