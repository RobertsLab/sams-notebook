---
layout: post
title: Transcriptome Assembly - C.bairdi Transcriptome v4.0 Using Trinity on Mox
date: '2021-03-17 08:19'
tags:
  - mox
  - Tanner crab
  - Chionoecetes bairdi
  - Trinity
  - transcriptome
  - assembly
  - RNAseq
categories:
  - Tanner Crab RNAseq
---
Continuing to addressing [this GitHub issue, to generate an additional _C.bairdi_ transcriptome](https://github.com/RobertsLab/resources/issues/1135), I finally got to the point of actually running the assembly using Trinity using [the extracted reads from 20210316](https://robertslab.github.io/sams-notebook/2021/03/16/Read-Extractions-C.bairdi-RNAseq-Reads-from-C.opilio-BLASTx-Matches-with-seqkit-on-Mox.html). Those reads were [identified via BLASTx agianst the _C.opilio_ genome proteins on 20210312](https://robertslab.github.io/sams-notebook/2021/03/12/DIAMOND-BLASTx-C.bairdi-RNAseq-vs-C.opilio-Genome-Proteins-on-Mox.html). Trinty was run on Mox.

SBATCH script (GitHub):

- [20210317_cbai_trinity_RNAseq_transcriptome-v4.0.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210317_cbai_trinity_RNAseq_transcriptome-v4.0.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210317_cbai_trinity_RNAseq_transcriptome-v4.0
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=20-00:00:00
## Memory per node
#SBATCH --mem=200G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210317_cbai_trinity_RNAseq_transcriptome-v4.0

## Trinity assembly of C.bairdi RNAseq reads
## with BLASTx matches to NCBI C.opilio genome proteins (GCA_016584305.1)
## Assembly will be referred to as cbai_transcriptome_v4.0

###################################################################################
# These variables need to be set by user

# Path to this script
script_path=/gscratch/scrubbed/samwhite/outputs/20210317_cbai_trinity_RNAseq_transcriptome-v4.0/20210317_cbai_trinity_RNAseq_transcriptome-v4.0.sh

# RNAseq FastQs directory
reads_dir=/gscratch/scrubbed/samwhite/outputs/20210316_cbai-vs-copi_reads_extractions

# Transcriptomes directory
transcriptomes_dir=/gscratch/srlab/sam/data/C_bairdi/transcriptomes

# CPU threads
threads=40

# Capture specified RAM from this script
# Carrot needed to limit grep to line starting with #SBATCH
# Avoids grep-ing the command below.
max_mem=$(grep "^#SBATCH --mem=" ${script_path} | awk -F [=] '{print $2}')

# Paths to programs
trinity_dir="/gscratch/srlab/programs/trinityrnaseq-v2.12.0"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"

# Set transcriptome name
transcriptome_name="cbai_transcriptome_v4.0.fasta"

# Programs array
declare -A programs_array
programs_array=(
[samtools_faidx]="${samtools} faidx" \
[trinity]="${trinity_dir}/Trinity" \
[trinity_stats]="${trinity_dir}/util/TrinityStats.pl" \
[trinity_gene_trans_map]="${trinity_dir}/util/support_scripts/get_Trinity_gene_to_trans_map.pl" \
[trinity_fasta_seq_length]="${trinity_dir}/util/misc/fasta_seq_length.pl"
)

# FastQ array
fastq_array=(${reads_dir}/*copi-BLASTx-match.fq.gz)

# Variables
R1_list=""
R2_list=""


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Set variables
trinity_out_dir=""
assembly_stats="${transcriptome_name}_assembly_stats.txt"
trinity_out_dir="${transcriptome_name}_trinity_out_dir"

# Adds empty line between checksums and next info logged to SLURM output.
echo ""

# Create comma-separated lists of FastQ reads
# Loop through read pairs
# Increment by 2 to process next pair of FastQ files
for (( i=0; i<${#fastq_array[@]} ; i+=2 ))
  do
    # Handle "fence post" problem
    # associated with comma placement
    if [[ ${i} -eq 0 ]]; then
      R1_list="${fastq_array[${i}]},"
      R2_list="${fastq_array[${i}+1]},"
    elif [[ ${i} -eq $(( ${#fastq_array[@]} - 1 )) ]]; then
      R1_list="${R1_list}${fastq_array[${i}]}"
      R2_list="${R2_list}${fastq_array[${i}+1]}"
    else
      R1_list="${R1_list}${fastq_array[${i}]},"
      R2_list="${R2_list}${fastq_array[${i}+1]},"
    fi
done

# Run Trinity without stranded RNAseq option
${programs_array[trinity]} \
--seqType fq \
--max_memory ${max_mem} \
--CPU ${threads} \
--output ${trinity_out_dir} \
--left "${R1_list}" \
--right "${R2_list}"

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
echo ""
echo "Generating checksum for ${transcriptome_name}"
md5sum "${transcriptome_name}" > "${transcriptome_name}".checksum.md5
echo "Finished generating checksum for ${transcriptome_name}"
echo ""

# Generate input FastQ checksums
for fastq in "${!fastq_array[@]}"
do
  echo ""
  echo "Generating checksum for ${fastq_array[$fastq]}"
  md5sum "${fastq_array[$fastq]}" >> fastq_checksums.md5
  echo "Checksum for ${fastq_array[$fastq]} complete."
done

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

Runtime was just less than 6.5hrs:

![trinity assembly of C.bairdi v4.0 transcriptome runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210317_cbai_trinity_RNAseq_transcriptome-v4.0_runtime.png?raw=true)
Output folder:

- [20210317_cbai_trinity_RNAseq_transcriptome-v4.0/](https://gannet.fish.washington.edu/Atumefaciens/20210317_cbai_trinity_RNAseq_transcriptome-v4.0/)


- Input FastQ list (text):

  - [fastq_checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20210317_cbai_trinity_RNAseq_transcriptome-v4.0/cbai_transcriptome_v4.0.fasta_trinity_out_dir/fastq_checksums.md5)

- FastA (50MB):

  - [cbai_transcriptome_v4.0.fasta](https://gannet.fish.washington.edu/Atumefaciens/20210317_cbai_trinity_RNAseq_transcriptome-v4.0/cbai_transcriptome_v4.0.fasta_trinity_out_dir/cbai_transcriptome_v4.0.fasta)

  - MD5 = `6450d6f5650bfb5f910a5f42eef94913`

- FastA Index (text):

  - [cbai_transcriptome_v4.0.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20210317_cbai_trinity_RNAseq_transcriptome-v4.0/cbai_transcriptome_v4.0.fasta_trinity_out_dir/cbai_transcriptome_v4.0.fasta.fai)

The following sets of files are useful for downstream gene expression and annotation using Trinity.

Trinity FastA Gene Trans Map (text):

- [cbai_transcriptome_v4.0.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20210317_cbai_trinity_RNAseq_transcriptome-v4.0/cbai_transcriptome_v4.0.fasta_trinity_out_dir/cbai_transcriptome_v4.0.fasta.gene_trans_map)

Trinity FastA Sequence Lengths (text):

- [cbai_transcriptome_v4.0.fasta.seq_lens](https://gannet.fish.washington.edu/Atumefaciens/20210317_cbai_trinity_RNAseq_transcriptome-v4.0/cbai_transcriptome_v4.0.fasta_trinity_out_dir/cbai_transcriptome_v4.0.fasta.seq_lens)


Assembly stats (text):

- [assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20210317_cbai_trinity_RNAseq_transcriptome-v4.0/cbai_transcriptome_v4.0.fasta_assembly_stats.txt)

```
################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	47097
Total trinity transcripts:	88302
Percent GC: 52.86

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 2340
	Contig N20: 1588
	Contig N30: 1180
	Contig N40: 880
	Contig N50: 635

	Median contig length: 317
	Average contig: 507.68
	Total assembled bases: 44829042


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 2334
	Contig N20: 1601
	Contig N30: 1185
	Contig N40: 862
	Contig N50: 605

	Median contig length: 294
	Average contig: 484.58
	Total assembled bases: 22822315
```
