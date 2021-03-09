---
layout: post
title: Transcriptome Assembly - Hematodinium Transcriptomes v1.6 and v1.7 with Trinity on Mox
date: '2021-03-08 20:44'
tags:
  - Tanner crab
  - hematodinium
  - mox
  - trinity
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
I'd previously assembled [`hemat_transcriptome_v1.0.fasta` on 20200122](https://robertslab.github.io/sams-notebook/2020/01/22/Transcriptome-Assembly-Hematodinium-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html), [`hemat_transcriptome_v1.5.fasta` on 20200408](https://robertslab.github.io/sams-notebook/2020/03/30/Transcriptome-Assembly-Hematodinium-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html), extracted [`hemat_transcriptome_v2.1.fasta` from an existing FastA on 20200605](https://robertslab.github.io/sams-notebook/2020/06/05/Sequence-Extractions-C.bairdi-Transcriptomes-v2.0-and-v3.0-Excluding-Alveolata-with-MEGAN6-on-Swoose.html), as well as extracted [`hemat_transcriptome_v3.1.fasta` on 20200605](https://robertslab.github.io/sams-notebook/2020/06/05/Sequence-Extractions-C.bairdi-Transcriptomes-v2.0-and-v3.0-Excluding-Alveolata-with-MEGAN6-on-Swoose.html).

All of the above transcriptomes were assembled with different combinations of the crab RNAseq data we generated. Here's a link to an overview of the various assemblies (including the two generated today):

- [hemat_transcriptome_comp](https://docs.google.com/spreadsheets/d/1A81cFdFw5Mlks5DWMmq0-8eVqyTXqmoCsHNWs95N_p4/edit?usp=sharing) (Google Sheet)


SBATCH script (GitHub):

- [20210308_hemat_trinity_v1.6_v1.7.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210308_hemat_trinity_v1.6_v1.7.sh)


```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=hemat_trinity_v1.6_v1.7
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210308_hemat_trinity_v1.6_v1.7


# Script to generate Hematodinium Trinity transcriptome assemblies:
# v1.6 libaries: 2018	2019	2020-GW	2020-UW
# v1.7 libraries: 2018	2019	2020-UW
# See corresponding FastQ list for each assembly to see FastQ used in each assembly.

###################################################################################
# These variables need to be set by user

# Assign Variables
script_path=/gscratch/scrubbed/samwhite/outputs/20210308_hemat_trinity_v1.6_v1.7/20210308_hemat_trinity_v1.6_v1.7.sh
reads_dir=/gscratch/srlab/sam/data/Hematodinium/RNAseq
transcriptomes_dir=/gscratch/srlab/sam/data/Hematodinium/transcriptomes
threads=28
# Carrot needed to limit grep to line starting with #SBATCH
# Avoids grep-ing the command below.
max_mem=$(grep "^#SBATCH --mem=" ${script_path} | awk -F [=] '{print $2}')

# Paths to programs
trinity_dir="/gscratch/srlab/programs/trinityrnaseq-v2.9.0"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"


# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
transcriptomes_array=(
"${transcriptomes_dir}"/hemat_transcriptome_v1.6.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v1.7.fasta
)




# Programs array
declare -A programs_array
programs_array=(
[samtools_faidx]="${samtools} faidx" \
[trinity]="${trinity_dir}/Trinity" \
[trinity_stats]="${trinity_dir}/util/TrinityStats.pl" \
[trinity_gene_trans_map]="${trinity_dir}/util/support_scripts/get_Trinity_gene_to_trans_map.pl" \
[trinity_fasta_seq_length]="${trinity_dir}/util/misc/fasta_seq_length.pl"
)



###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Set working directory
wd=$(pwd)

# Loop through each transcriptome
for transcriptome in "${!transcriptomes_array[@]}"
do

  ## Inititalize arrays
  R1_array=()
  R2_array=()
  reads_array=()

  # Variables
  R1_list=""
  R2_list=""
  trinity_out_dir=""

  transcriptome_name="${transcriptomes_array[$transcriptome]##*/}"
  assembly_stats="${transcriptome_name}_assembly_stats.txt"
  trinity_out_dir="${transcriptome_name}_trinity_out_dir"


  # v1.6 libraries: 2018	2019	2020-GW	2020-UW
  if [[ "${transcriptome_name}" == "hemat_transcriptome_v1.6.fasta" ]]; then

    reads_array=("${reads_dir}"/*megan*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/*megan*R1.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/*megan*R2.fq)

  # v.17 libraries: 2018	2019	2020-UW
  elif [[ "${transcriptome_name}" == "hemat_transcriptome_v1.7.fasta" ]]; then

    reads_array=("${reads_dir}"/20200[145][13][189]*megan*.fq)

    # Create array of fastq R1 files
    R1_array=("${reads_dir}"/20200[145][13][189]*megan*R1.fq)

    # Create array of fastq R2 files
    R2_array=("${reads_dir}"/20200[145][13][189]*megan*R2.fq)

  fi

  # Create checksum list of fastq files used in analysis
  ## Uses parameter substitution to strip leading path from filename
  md5sum "${reads_array[@]}" >> "${transcriptome_name}".fastq-checksums.md5

  # Create comma-separated lists of FastQ reads
  R1_list=$(echo "${R1_array[@]}" | tr " " ",")
  R2_list=$(echo "${R2_array[@]}" | tr " " ",")


  if [[ "${transcriptome_name}" == "hemat_transcriptome_v1.6.fasta" ]]; then

    # Run Trinity without stranded RNAseq option
    ${programs_array[trinity]} \
    --seqType fq \
    --max_memory ${max_mem} \
    --CPU ${threads} \
    --output ${trinity_out_dir} \
    --left "${R1_list}" \
    --right "${R2_list}"

  else

    # Run Trinity with stranded RNAseq option
    ${programs_array[trinity]} \
    --seqType fq \
    --max_memory ${max_mem} \
    --CPU ${threads} \
    --output ${trinity_out_dir} \
    --SS_lib_type RF \
    --left "${R1_list}" \
    --right "${R2_list}"

  fi

  # Rename generic assembly FastA
  mv "${trinity_out_dir}"/Trinity.fasta "${trinity_out_dir}"/"${transcriptome_name}"

  # Assembly stats
  ${programs_array[trinity_stats]} "${trinity_out_dir}"/"${transcriptome_name}" \
  > "${assembly_stats}"

  # Create gene map files
  ${programs_array[trinity_gene_trans_map]} \
  "${trinity_out_dir}"/"${transcriptome_name}" \
  > "${trinity_out_dir}"/"${transcriptome_name}".gene_trans_map

  # Create sequence lengths file (used for differential gene expression)
  ${programs_array[trinity_fasta_seq_length]} \
  "${trinity_out_dir}"/"${transcriptome_name}" \
  > "${trinity_out_dir}"/"${transcriptome_name}".seq_lens

  # Create FastA index
  ${programs_array[samtools_faidx]} \
  "${trinity_out_dir}"/"${transcriptome_name}"

  # Copy files to transcriptomes directory
  rsync -av \
  "${trinity_out_dir}"/"${transcriptome_name}"* \
  ${transcriptomes_dir}

  # Capture FastA checksums for verification
  cd "${trinity_out_dir}"/
  echo "Generating checksum for ${transcriptome_name}"
  md5sum "${transcriptome_name}" > "${transcriptome_name}".checksum.md5
  echo "Finished generating checksum for ${transcriptome_name}"
  echo ""

  cd ${wd}


done

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

echo ""
echo "Finished logging program options."
echo ""

echo ""
echo "Logging system PATH."
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

Just under 5hrs to run both assemblies:

![Hemat Trinity assemblies v1.6 and v1.7 combined runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210308_hemat_trinity_v1.6_v1.7_runtime.png?raw=true)

Output folder:

- [20210308_hemat_trinity_v1.6_v1.7/](https://gannet.fish.washington.edu/Atumefaciens/20210308_hemat_trinity_v1.6_v1.7/)


#### hemat_transcriptome_v1.6

Input FastQ list (text):

- [20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.6.fasta.fastq-checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.6.fasta.fastq-checksums.md5)

FastA (4.5MB):

- [20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.6.fasta_trinity_out_dir/hemat_transcriptome_v1.6.fasta](https://gannet.fish.washington.edu/Atumefaciens/20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.6.fasta_trinity_out_dir/hemat_transcriptome_v1.6.fasta)

FastA Index (text):

- [20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.6.fasta_trinity_out_dir/hemat_transcriptome_v1.6.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.6.fasta_trinity_out_dir/hemat_transcriptome_v1.6.fasta.fai)

The following sets of files are useful for downstream gene expression and annotation using Trinity.

Trinity FastA Gene Trans Map (text):

- [20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.6.fasta_trinity_out_dir/hemat_transcriptome_v1.6.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.6.fasta_trinity_out_dir/hemat_transcriptome_v1.6.fasta.gene_trans_map)

Trinity FastA Sequence Lengths (text):

-  [20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.6.fasta_trinity_out_dir/hemat_transcriptome_v1.6.fasta.seq_lens](https://gannet.fish.washington.edu/Atumefaciens/20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.6.fasta_trinity_out_dir/hemat_transcriptome_v1.6.fasta.seq_lens)

Assembly stats:

- [hemat_transcriptome_v1.6.fasta_assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.6.fasta_assembly_stats.txt)

```
## Counts of transcripts, etc.
################################
Total trinity 'genes':	5395
Total trinity transcripts:	6176
Percent GC: 50.22

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 1889
	Contig N20: 1490
	Contig N30: 1212
	Contig N40: 1015
	Contig N50: 868

	Median contig length: 582
	Average contig: 700.74
	Total assembled bases: 4327777


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 1818
	Contig N20: 1423
	Contig N30: 1160
	Contig N40: 978
	Contig N50: 835

	Median contig length: 548
	Average contig: 669.49
	Total assembled bases: 3611911
```

#### hemat_transcriptome_v1.7

Input FastQ list (text):

- [20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.7.fasta.fastq-checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.7.fasta.fastq-checksums.md5)

FastA (1.9MB):

- [20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.7.fasta_trinity_out_dir/hemat_transcriptome_v1.7.fasta](https://gannet.fish.washington.edu/Atumefaciens/20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.7.fasta_trinity_out_dir/hemat_transcriptome_v1.7.fasta)



FastA Index (text):

- [20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.7.fasta_trinity_out_dir/hemat_transcriptome_v1.7.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.7.fasta_trinity_out_dir/hemat_transcriptome_v1.7.fasta.fai)


The following sets of files are useful for downstream gene expression and annotation using Trinity.

Trinity FastA Gene Trans Map (text):

- [20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.7.fasta_trinity_out_dir/hemat_transcriptome_v1.7.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.7.fasta_trinity_out_dir/hemat_transcriptome_v1.7.fasta.gene_trans_map)

Trinity FastA Sequence Lengths (text):

- [20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.7.fasta_trinity_out_dir/hemat_transcriptome_v1.7.fasta.seq_lens](https://gannet.fish.washington.edu/Atumefaciens/20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.7.fasta_trinity_out_dir/hemat_transcriptome_v1.7.fasta.seq_lens)


Assembly stats:

 - [20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.7.fasta_assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20210308_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.7.fasta_assembly_stats.txt)

 ```
 ################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	3331
Total trinity transcripts:	3538
Percent GC: 50.78

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 1346
	Contig N20: 1008
	Contig N30: 820
	Contig N40: 688
	Contig N50: 588

	Median contig length: 407
	Average contig: 506.42
	Total assembled bases: 1791711


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 1250
	Contig N20: 959
	Contig N30: 782
	Contig N40: 661
	Contig N50: 560

	Median contig length: 392
	Average contig: 488.48
	Total assembled bases: 1627114
 ```
