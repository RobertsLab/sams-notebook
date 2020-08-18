---
layout: post
title: Assembly Stats - Hematodinium Transcriptomes v2.1 and v3.1 Trinity Stats on Mox
date: '2020-08-17 06:31'
tags:
  - Tanner crab
  - mox
  - transcriptome assembly
  - Chionoecetes bairdi
  - Hematodinium
categories:
  - Miscellaneous
---
Working on dealing with our various _Hematodinium sp._ transcriptomes and realized that transcriptomes v2.1 and v3.1 ([extracted from BLASTx-annotated FastAs from 20200605](https://robertslab.github.io/sams-notebook/2020/06/05/Sequence-Extractions-C.bairdi-Transcriptomes-v2.0-and-v3.0-Excluding-Alveolata-with-MEGAN6-on-Swoose.html)) didn't have any associated stats.

Used built-in Trinity scripts to generate assembly stats on Mox.

SBATCH script (GitHub):

- [20200817_hemat_trinity_stats_v2.1_3.1.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200817_hemat_trinity_stats_v2.1_3.1.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20200817_hemat_trinity_stats_v2.1_3.1
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200817_hemat_trinity_stats_v2.1_3.1


# Script to generate Hematodinium Trinity transcriptome stats:
# v2.1
# v3.1

###################################################################################
# These variables need to be set by user

# Assign Variables
transcriptomes_dir=/gscratch/srlab/sam/data/Hematodinium/transcriptomes


# Paths to programs
trinity_dir="/gscratch/srlab/programs/trinityrnaseq-v2.9.0"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"


# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
transcriptomes_array=(
"${transcriptomes_dir}"/hemat_transcriptome_v2.1.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v3.1.fasta
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

As expected, very fast; 27 seconds:

![cumulative runtime of running Trinity stats scripts on Hemat transcriptomes v2.1 and v3.1](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200817_hemat_trinity_stats_v2.1_3.1_runtime.png?raw=true)


Output folder:

- [20200817_hemat_trinity_stats_v2.1_3.1/](https://gannet.fish.washington.edu/Atumefaciens/20200817_hemat_trinity_stats_v2.1_3.1/)

All stats below have been added to the _Hematodinium_ assembly comparison spreadsheet:

- [hemat_transcriptome_comp](https://docs.google.com/spreadsheets/d/1A81cFdFw5Mlks5DWMmq0-8eVqyTXqmoCsHNWs95N_p4/edit#gid=0) (Google Sheet)


##### hemat_transcriptome_v2.1.fasta


- [20200817_hemat_trinity_stats_v2.1_3.1/hemat_transcriptome_v2.1.fasta_assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20200817_hemat_trinity_stats_v2.1_3.1/hemat_transcriptome_v2.1.fasta_assembly_stats.txt)

```
################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	5967
Total trinity transcripts:	30612
Percent GC: 47.40

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 4850
	Contig N20: 3944
	Contig N30: 3360
	Contig N40: 2936
	Contig N50: 2598

	Median contig length: 2018
	Average contig: 2245.91
	Total assembled bases: 68751815


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 5158
	Contig N20: 4254
	Contig N30: 3613
	Contig N40: 3162
	Contig N50: 2806

	Median contig length: 2075
	Average contig: 2268.13
	Total assembled bases: 13533919
```

Other useful files for downstream annotation using Trinotate:

Trinity Gene Trans Map:

- [20200817_hemat_trinity_stats_v2.1_3.1/hemat_transcriptome_v2.1.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20200817_hemat_trinity_stats_v2.1_3.1/hemat_transcriptome_v2.1.fasta.gene_trans_map)

Trinity FastA Sequence Lengths:

- [20200817_hemat_trinity_stats_v2.1_3.1/hemat_transcriptome_v2.1.fasta.seq_lens](https://gannet.fish.washington.edu/Atumefaciens/20200817_hemat_trinity_stats_v2.1_3.1/hemat_transcriptome_v2.1.fasta.seq_lens)

##### hemat_transcriptome_v3.1.fasta

- [20200817_hemat_trinity_stats_v2.1_3.1/hemat_transcriptome_v3.1.fasta_assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20200817_hemat_trinity_stats_v2.1_3.1/hemat_transcriptome_v3.1.fasta_assembly_stats.txt)

```
################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	5702
Total trinity transcripts:	29863
Percent GC: 47.43

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 4805
	Contig N20: 3890
	Contig N30: 3353
	Contig N40: 2939
	Contig N50: 2598

	Median contig length: 2034
	Average contig: 2258.74
	Total assembled bases: 67452749


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 5235
	Contig N20: 4213
	Contig N30: 3619
	Contig N40: 3174
	Contig N50: 2805

	Median contig length: 2129.5
	Average contig: 2333.10
	Total assembled bases: 13303359
```

Other useful files for downstream annotation using Trinotate:

Trinity Gene Trans Map:

- [20200817_hemat_trinity_stats_v2.1_3.1/hemat_transcriptome_v3.1.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20200817_hemat_trinity_stats_v2.1_3.1/hemat_transcriptome_v3.1.fasta.gene_trans_map)

Trinity FastA Sequence Lengths:

- [20200817_hemat_trinity_stats_v2.1_3.1/hemat_transcriptome_v3.1.fasta.seq_lens](https://gannet.fish.washington.edu/Atumefaciens/20200817_hemat_trinity_stats_v2.1_3.1/hemat_transcriptome_v3.1.fasta.seq_lens)
