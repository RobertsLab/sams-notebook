---
layout: post
title: Assembly Stats - cbaiodinium Transcriptomes v2.1 and v3.1 Trinity Stats on Mox
date: '2020-08-17 06:31'
tags:
  - Tanner crab
  - mox
  - transcriptome assembly
  - Chionoecetes bairdi
  - cbaiodinium
categories:
  - Miscellaneous
---
Working on dealing with our various _cbaiodinium sp._ transcriptomes and realized that transcriptomes v2.1 and v3.1 ([extracted from BLASTx-annotated FastAs from 20200605](https://robertslab.github.io/sams-notebook/2020/06/05/Sequence-Extractions-C.bairdi-Transcriptomes-v2.0-and-v3.0-Excluding-Alveolata-with-MEGAN6-on-Swoose.html)) didn't have any associated stats.

Used built-in Trinity scripts to generate assembly stats on Mox.

SBATCH script (GitHub):

- [20200819_cbai_trinity_stats_v2.1_3.1.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200819_cbai_trinity_stats_v2.1_3.1.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20200819_cbai_trinity_stats_v2.1_3.1
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=15-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200819_cbai_trinity_stats_v2.1_3.1


# Script to generate cbaiodinium Trinity transcriptome stats:
# v2.1
# v3.1

###################################################################################
# These variables need to be set by user

# Assign Variables
transcriptomes_dir=/gscratch/srlab/sam/data/cbaiodinium/transcriptomes


# Paths to programs
trinity_dir="/gscratch/srlab/programs/trinityrnaseq-v2.9.0"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"


# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
transcriptomes_array=(
"${transcriptomes_dir}"/cbai_transcriptome_v2.1.fasta \
"${transcriptomes_dir}"/cbai_transcriptome_v3.1.fasta
)




# Programs array
declare -A programs_array
programs_array=(
[samtools_faidx]="${samtools} faidx" \
[trinity_stats]="${trinity_dir}/util/TrinityStats.pl" \
[trinity_gene_trans_map]="${trinity_dir}/util/support_scripts/get_Trinity_gene_to_trans_map.pl" \
[trinity_fasta_seq_length]="${trinity_dir}/util/misc/fasta_seq_length.pl"
)



###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017


# Loop through each transcriptome
for transcriptome in "${!transcriptomes_array[@]}"
do


  # Variables
  transcriptome_name="${transcriptomes_array[$transcriptome]##*/}"
  assembly_stats="${transcriptome_name}_assembly_stats.txt"


  # Assembly stats
  ${programs_array[trinity_stats]} "${transcriptomes_array[$transcriptome]}" \
  > "${assembly_stats}"

  # Create gene map files
  ${programs_array[trinity_gene_trans_map]} \
  "${transcriptomes_array[$transcriptome]}" \
  > "${transcriptome_name}".gene_trans_map

  # Create sequence lengths file (used for differential gene expression)
  ${programs_array[trinity_fasta_seq_length]} \
  "${transcriptomes_array[$transcriptome]}" \
  > "${transcriptome_name}".seq_lens

  # Create FastA index
  ${programs_array[samtools_faidx]} \
  "${transcriptomes_array[$transcriptome]}" \
  > "${transcriptome_name}".fai

  # Copy files to transcriptomes directory
  rsync -av \
  "${transcriptome_name}"* \
  ${transcriptomes_dir}

  # Capture FastA checksums for verification
  echo "Generating checksum for ${transcriptome_name}"
  md5sum "${transcriptomes_array[$transcriptome]}" > "${transcriptome_name}".checksum.md5
  echo "Finished generating checksum for ${transcriptome_name}"
  echo ""


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

# Capture program options
## Note: Trinity util/support scripts don't have options/help menus
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${program}: "
	echo ""
	${programs_array[$program]} --help
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true
done
```

---

#### RESULTS

As expected, very fast; ~2mins:

![cumulative runtime of running Trinity stats scripts on C.bairdi transcriptomes v2.1 and v3.1](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200819_cbai_trinity_stats_v2.1_v3.1_runtime.png?raw=true)


Output folder:

- [20200819_cbai_trinity_stats_v2.1_3.1/](https://gannet.fish.washington.edu/Atumefaciens/20200819_cbai_trinity_stats_v2.1_3.1/)

All stats below have been added to the _C.bairdi_ assembly comparison spreadsheet:

- [cbai_transcriptome_comp](https://docs.google.com/spreadsheets/d/1XAgU_xQKJjWk4ThJHn1wLDtPuW6X7s6Jjh_373bMc0U/edit?usp=sharing) (Google Sheet)


##### cbai_transcriptome_v2.1.fasta


- [20200819_cbai_trinity_stats_v2.1_3.1/cbai_transcriptome_v2.1.fasta_assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20200819_cbai_trinity_stats_v2.1_3.1/cbai_transcriptome_v2.1.fasta_assembly_stats.txt)

```
################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	131239
Total trinity transcripts:	237494
Percent GC: 50.37

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 5347
	Contig N20: 3867
	Contig N30: 3024
	Contig N40: 2457
	Contig N50: 1996

	Median contig length: 494
	Average contig: 1037.76
	Total assembled bases: 246461881


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 5047
	Contig N20: 3463
	Contig N30: 2579
	Contig N40: 1938
	Contig N50: 1388

	Median contig length: 344
	Average contig: 722.72
	Total assembled bases: 94849243
```

Other useful files for downstream annotation using Trinotate:

Trinity Gene Trans Map:

- [20200819_cbai_trinity_stats_v2.1_3.1/cbai_transcriptome_v2.1.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20200819_cbai_trinity_stats_v2.1_3.1/cbai_transcriptome_v2.1.fasta.gene_trans_map)

Trinity FastA Sequence Lengths:

- [20200819_cbai_trinity_stats_v2.1_3.1/cbai_transcriptome_v2.1.fasta.seq_lens](https://gannet.fish.washington.edu/Atumefaciens/20200819_cbai_trinity_stats_v2.1_3.1/cbai_transcriptome_v2.1.fasta.seq_lens)

##### cbai_transcriptome_v3.1.fasta

- [20200819_cbai_trinity_stats_v2.1_3.1/cbai_transcriptome_v3.1.fasta_assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20200819_cbai_trinity_stats_v2.1_3.1/cbai_transcriptome_v3.1.fasta_assembly_stats.txt)

```
################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	27399
Total trinity transcripts:	78649
Percent GC: 48.83

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 5638
	Contig N20: 4370
	Contig N30: 3580
	Contig N40: 3016
	Contig N50: 2580

	Median contig length: 1522
	Average contig: 1825.11
	Total assembled bases: 143543003


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 5753
	Contig N20: 4423
	Contig N30: 3622
	Contig N40: 3052
	Contig N50: 2597

	Median contig length: 979
	Average contig: 1505.44
	Total assembled bases: 41247546
```

Other useful files for downstream annotation using Trinotate:

Trinity Gene Trans Map:

- [20200819_cbai_trinity_stats_v2.1_3.1/cbai_transcriptome_v3.1.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20200819_cbai_trinity_stats_v2.1_3.1/cbai_transcriptome_v3.1.fasta.gene_trans_map)

Trinity FastA Sequence Lengths:

- [20200819_cbai_trinity_stats_v2.1_3.1/cbai_transcriptome_v3.1.fasta.seq_lens](https://gannet.fish.washington.edu/Atumefaciens/20200819_cbai_trinity_stats_v2.1_3.1/cbai_transcriptome_v3.1.fasta.seq_lens)
