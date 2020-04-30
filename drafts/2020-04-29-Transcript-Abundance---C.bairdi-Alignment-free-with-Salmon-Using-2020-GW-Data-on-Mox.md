---
layout: post
title: Transcript Abundance - C.bairdi Alignment-free with Salmon Using 2020-GW Data on Mox
date: '2020-04-29 11:26'
tags:
  - salmon
  - mox
  - Tanner crab
  - Chionoecetes bairdi
categories:
  - Miscellneous
---


SBATCH script (GitHub):

- [20200429_cbai_salmon_2020GW_transcript_abundances.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200429_cbai_salmon_2020GW_transcript_abundances.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_DEG_basic
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200429_cbai_salmon_2020GW_transcript_abundances

# Script to generate set of transcript abundances for all C.bairdi Genewiz 2020 data.
#
# C.bairdi-specific reads were extracted with MEGAN6:
# https://robertslab.github.io/sams-notebook/2020/03/30/RNAseq-Reads-Extractions-C.bairdi-Taxonomic-Reads-Extractions-with-MEGAN6-on-swoose.html
#
# Transcriptome was produced here: https://robertslab.github.io/sams-notebook/2020/03/30/Transcriptome-Assembly-C.bairdi-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html
# Transcriptome is the same as: cbai_transcriptome_v1.5.fasta
#
# Salmon index generated during a previous gene expression analysis:
# https://robertslab.github.io/sams-notebook/2020/04/22/Gene-Expression-C.bairdi-Pairwise-DEG-Comparisons-with-2019-RNAseq-using-Trinity-Salmon-EdgeR-on-Mox.html



###################################################################################################################
# BEGIN USER SETTINGS


# Programs array
declare -A programs_array
programs_array=([salmon]="/gscratch/srlab/programs/salmon-1.2.1_linux_x86_64/bin/salmon")

## Designate input files and locations
fastq_dir="/gscratch/srlab/sam/data/C_bairdi/RNAseq/"
salmon_index="/gscratch/srlab/sam/data/C_bairdi/transcriptomes/20200408.C_bairdi.megan.Trinity.fasta.salmon.idx"

# Set number of CPU threads
# Salmon default is 56 threads - so not needed
# threads=28

# END USER SETTINGS
####################################################################################################################

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

# Caputure working directory
#wd="$(pwd)"


# Capture program options
## NOTE: This particular instance is specific to salmon!
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${programs_array[$program]}: "
	echo ""
	${programs_array[$program]} quant --help
	echo ""
	${programs_array[$program]} quant --help-reads
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
  } &>> program_options.log || true
done

# Populate array with FastQ files
reads_array=("${fastq_dir}"*.fq)

# Loop through read pairs
# Increment by 2 to process next pair of FastQ files
for (( i=0; i<${#reads_array[@]} ; i+=2 ))
do

	# Create list of FastQ files used
	{
	echo "${reads_array[i]}"
	echo "${reads_array[i+1]}"
} >> fastq-list.txt

  # Strip path and save just sample number
	# Expects sample name to be like:
	# 20200413.C_bairdi.359.D12.infected.ambient.megan_R2.fq
	# Will pull out '359'
  sample=$(echo ${reads_array[i]##*/} | awk -F"." '{print $3}')

	# Run salmon
	# Library type (stranded or not) is set to auto (A)
	${programs_array[salmon]} quant \
	--index ${salmon_index} \
	--libType A \
	--validateMappings \
	--output "${sample}"_quant \
	-1 ${reads_array[i]} \
	-2 ${reads_array[i+1]}
done
```

---

#### RESULTS

Extremely fast:

![]()

Output folder:

- [20200429_cbai_salmon_2020GW_transcript_abundances](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances)

Here are links to the individual quants files:

#### Sample 72

- [72_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/72_quant/quant.sf)

#### Sample 73

- [73_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/73_quant/quant.sf)

#### Sample 113

- [113_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/113_quant/quant.sf)

#### Sample 118

- [118_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/118_quant/quant.sf)

#### Sample 127

- [127_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/127_quant/quant.sf)

#### Sample 132

- [132_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/132_quant/quant.sf)

#### Sample 151

- [151_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/151_quant/quant.sf)

#### Sample 173

- [173_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/173_quant/quant.sf)

#### Sample 178

- [178_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/178_quant/quant.sf)

#### Sample 221

- [221_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/221_quant/quant.sf)

#### Sample 222

- [222_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/222_quant/quant.sf)

#### Sample 254

- [254_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/254_quant/quant.sf)

#### Sample 272

- [272_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/272_quant/quant.sf)

#### Sample 280

- [280_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/280_quant/quant.sf)

#### Sample 294

- [294_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/294_quant/quant.sf)

#### Sample 334

- [334_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/334_quant/quant.sf)

#### Sample 349

- [349_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/349_quant/quant.sf)

#### Sample 359

- [359_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/359_quant/quant.sf)

#### Sample 425

- [425_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/425_quant/quant.sf)

#### Sample 427

- [427_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/427_quant/quant.sf)

#### Sample 445

- [445_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/445_quant/quant.sf)

#### Sample 463

- [463_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/463_quant/quant.sf)

#### Sample 481

- [481_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/481_quant/quant.sf)

#### Sample 485

- [485_quant.sf](https://gannet.fish.washington.edu/Atumefaciens/20200429_cbai_salmon_2020GW_transcript_abundances/485_quant/quant.sf)
