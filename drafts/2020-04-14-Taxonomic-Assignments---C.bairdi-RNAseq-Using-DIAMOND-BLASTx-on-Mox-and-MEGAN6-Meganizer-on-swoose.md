---
layout: post
title: Taxonomic Assignments - C.bairdi RNAseq Using DIAMOND BLASTx on Mox and MEGAN6 Meganizer on swoose
date: '2020-04-14 09:35'
tags:
  - Tanner crab
  - DIAMOND
  - BLASTx
  - mox
  - swoose
  - RNAseq
  - meganizer
  - MEGAN6
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
[After receiving/trimming the latest round of _C.bairdi_ RNAseq data on 20200413](https://robertslab.github.io/sams-notebook/2020/04/13/Data-Received-C.bairdi-RNAseq-from-NWGSC.html), need to get the data ready to perform taxonomic selection of sequencing reads. To do this, I first need to run [DIAMOND BLASTx](https://github.com/bbuchfink/diamond), then "meganize" the output files in preparation for loading into [MEGAN6](https://uni-tuebingen.de/fakultaeten/mathematisch-naturwissenschaftliche-fakultaet/fachbereiche/informatik/lehrstuehle/algorithms-in-bioinformatics/software/megan6/), which will allow for taxonomic-specific read separation.

DIAMOND BLASTx will be run on Mox. Meganization will be run on my computer (swoose), due to MEGAN6's reliance on Java X11 window (this is not available on Mox - throws an error when trying to run it).

I fully anticipate this process to take a week or two (DIAMOND BLASTx will likely take a few days and read extraction will definitely take many days...)



SBATCH script (GitHub):

- [20200414_cbai_diamond_blastx.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200414_cbai_diamond_blastx.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_blastx_DIAMOND
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200414_cbai_diamond_blastx

## Perform DIAMOND BLASTx on trimmed Chionoecetes bairdi (Tanner crab) FastQ files.

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# SegFault fix?
export THREADS_DAEMON_MODEL=1

# Document programs in PATH (primarily for program version ID)

{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log



# Program paths
diamond=/gscratch/srlab/programs/diamond-0.9.29/diamond

# DIAMOND NCBI nr database
dmnd=/gscratch/srlab/blastdbs/ncbi-nr-20190925/nr.dmnd

# Capture program options
{
echo "Program options for DIAMOND: "
echo ""
"${diamond}" help
echo ""
echo ""
echo "----------------------------------------------"
echo ""
echo ""
} &>> program_options.log || true

# Trimmed FastQ files directory
fastq_dir=/gscratch/scrubbed/samwhite/outputs/20200414_cbai_RNAseq_fastp_trimming/


# Loop through FastQ files, log filenames to fastq_list.txt.
# Run DIAMOND on each FastQ
for fastq in ${fastq_dir}*fastp-trim*.fq.gz
do
	# Log input FastQs
	echo "${fastq}" >> fastq_list.txt

	# Strip leading path and extensions
	no_path=$(echo "${fastq##*/}")
	no_ext=$(echo "${no_path%%.*}")

	# Run DIAMOND with blastx
	# Output format 100 produces a DAA binary file for use with MEGAN
	${diamond} blastx \
	--db ${dmnd} \
	--query "${fastq}" \
	--out "${no_ext}".blastx.daa \
	--outfmt 100 \
	--top 5 \
	--block-size 15.0 \
	--index-chunks 4
done
```

---

#### RESULTS

Output folder:

- [20200414_cbai_diamond_blastx/](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/)


Output files ("meganized" DAA files):

- [380820_S1_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380820_S1_L001_R1_001.blastx.daa)(25G)

- [380820_S1_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380820_S1_L001_R2_001.blastx.daa)(23G)

- [380820_S1_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380820_S1_L002_R1_001.blastx.daa)(25G)

- [380820_S1_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380820_S1_L002_R2_001.blastx.daa)(23G)

- [380821_S2_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380821_S2_L001_R1_001.blastx.daa)(21G)

- [380821_S2_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380821_S2_L001_R2_001.blastx.daa)(20G)

- [380821_S2_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380821_S2_L002_R1_001.blastx.daa)(21G)

- [380821_S2_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380821_S2_L002_R2_001.blastx.daa)(20G)

- [380822_S3_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380822_S3_L001_R1_001.blastx.daa)(22G)

- [380822_S3_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380822_S3_L001_R2_001.blastx.daa)(20G)

- [380822_S3_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380822_S3_L002_R1_001.blastx.daa)(22G)

- [380822_S3_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380822_S3_L002_R2_001.blastx.daa)(20G)

- [380823_S4_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380823_S4_L001_R1_001.blastx.daa)(19G)

- [380823_S4_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380823_S4_L001_R2_001.blastx.daa)(17G)

- [380823_S4_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380823_S4_L002_R1_001.blastx.daa)(19G)

- [380823_S4_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380823_S4_L002_R2_001.blastx.daa)(17G)

- [380824_S5_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380824_S5_L001_R1_001.blastx.daa)(24G)

- [380824_S5_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380824_S5_L001_R2_001.blastx.daa)(21G)

- [380824_S5_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380824_S5_L002_R1_001.blastx.daa)(23G)

- [380824_S5_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380824_S5_L002_R2_001.blastx.daa)(22G)

- [380825_S6_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380825_S6_L001_R1_001.blastx.daa)(22G)

- [380825_S6_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380825_S6_L001_R2_001.blastx.daa)(20G)

- [380825_S6_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380825_S6_L002_R1_001.blastx.daa)(22G)

- [380825_S6_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/380825_S6_L002_R2_001.blastx.daa)(20G)


These will be loaded into MEGAN6 and reads will be extracted based on classification to _Alveolata_ and/or _Arthropoda_ phyla.
