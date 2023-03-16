---
layout: post
title: Sequencing Read Taxonomic Classification - P.verrucosa E5 RNA-seq Using DIAMOND BLASTx and MEGAN daa-meganizer on Mox
date: '2023-02-21 08:47'
tags: 
  - mox
  - MEGAN6
  - RNA-seq
  - Pocillipora verrucosa
  - DIAMOND
  - BLASTx
categories: 
  - E5
---
After some discussion with Steven at Science Hour last week regarding the handling of endosymbiont sequences in the E5 _P.verrucosa_ RNA-seq data, Steven thought it would be interesting to run the RNA-seq reads through [MEGAN6](https://uni-tuebingen.de/fakultaeten/mathematisch-naturwissenschaftliche-fakultaet/fachbereiche/informatik/lehrstuehle/algorithms-in-bioinformatics/software/megan6/) just to see what the taxonomic breakdown looks like. We may or may not (probably not) separating reads based on taxonomy. In the meantime, we'll still proceed with [`HISAT2`](https://daehwankimlab.github.io/hisat2/) alignments to the respective genomes as a means to separate the endosymbiont reads from the _P.verrucosa_ reads.

The process involves the following:

1. DIAMOND BLASTx sequencing reads. Generates the appropriate `.daa` output file for import into [MEGAN6](https://uni-tuebingen.de/fakultaeten/mathematisch-naturwissenschaftliche-fakultaet/fachbereiche/informatik/lehrstuehle/algorithms-in-bioinformatics/software/megan6/).

    - Used a DIAMOND-formatted BLAST database of the NCBI `nr` database, combined with NCBI taxonomic dump files.

2. "MEGANize" the DIAMOND BLASTx file using the MEGAN6 tool, `daa-maganizer`. This prepares the `.daa` file for import into MEGAN6.


SBATCH Script (GitHub):

- [20230221-pver-diamond-meganizer-E5_RNAseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20230221-pver-diamond-meganizer-E5_RNAseq.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20230221-pver-diamond-meganizer-E5_RNAseq
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=12-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230221-pver-diamond-meganizer-E5_RNAseq

## Perform DIAMOND BLASTx on trimmed P.verrucosa RNA-seq files from 20230215.
## Will be used to view taxonomic breakdown of sequencing reads.

## Expects input FastQ files to be match this pattern: *.fastp-trim.20230215.fq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

fastq_pattern='*.fastp-trim.20230215.fq.gz'

# Program paths
diamond=/gscratch/srlab/programs/diamond-v2.1.1/diamond
meganizer=/gscratch/srlab/programs/MEGAN-6.22.0/tools/daa-meganizer

# DIAMOND NCBI nr database
dmnd_db=/gscratch/srlab/blastdbs/20230215-ncbi-nr/20230215-ncbi-nr.dmnd

# MEGAN mapping files
megan_mapping_dir=/gscratch/srlab/sam/data/databases/MEGAN
megan_mapdb="${megan_mapping_dir}/megan-map-Feb2022.db"

# FastQ files directory
fastq_dir=/gscratch/srlab/sam/data/P_verrucosa/RNAseq

# CPU threads
threads=40

# MEGAN memory limit
mem_limit=100G

# Programs associative array
declare -A programs_array
programs_array=(
[diamond]="${diamond}" \
[meganizer]="${meganizer}"
)

###################################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017


# Loop through FastQ files, log filenames to fastq_list.txt.
# Run DIAMOND on each FastQ, followed by "MEGANization"
# DO NOT QUOTE ${fastq_pattern}
for fastq in "${fastq_dir}"/${fastq_pattern}
do
	# Log input FastQs
    echo ""
    echo "Generating MD5 checksum for ${fastq}..."
	md5sum "${fastq}" | tee --append input_fastqs-checksums.md5
    echo ""

	# Strip leading path and extensions
	no_path=$(echo "${fastq##*/}")
	no_ext=$(echo "${no_path%%.*}")

	# Run DIAMOND with blastx
	# Output format 100 produces a DAA binary file for use with MEGAN
    echo "Running DIAMOND BLASTx on ${fastq}."
    echo ""
	"${programs_array[diamond]}" blastx \
	--db ${dmnd_db} \
	--query "${fastq}" \
	--out "${no_ext}".blastx.meganized.daa \
	--outfmt 100 \
	--top 5 \
	--block-size 15.0 \
	--index-chunks 4 \
    --memory-limit ${mem_limit} \
    --threads ${threads}
    echo "DIAMOND BLASTx on ${fastq} complete: ${no_ext}.blastx.meganized.daa"
    echo ""

    # Meganize DAA files
    # Used for ability to import into MEGAN6
    echo "Now MEGANizing ${no_ext}.blastx.meganized.daa"
    "${programs_array[meganizer]}" \
    --in "${no_ext}".blastx.meganized.daa \
    --threads ${threads} \
    --mapDB ${megan_mapdb}
    echo "MEGANization of ${no_ext}.blastx.meganized.daa completed."
    echo ""

done

# Generate MD5 checksums
for file in *
do
  echo ""
  echo "Generating MD5 checksums for ${file}:"
  md5sum "${file}" | tee --append checksums.md5
  echo ""
done

# Generate checksum for MEGAN database(s)
{
    md5sum "${megan_mapdb}"
    md5sum "${dmnd_db}"
} >> checksums.md5

#######################################################################################################

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
  echo "Finished logging programs options."
  echo ""
fi


# Document programs in PATH (primarily for program version ID)
echo "Logging system $PATH..."
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log
echo "Finished logging system $PATH."
```

---

#### RESULTS

This took a fair amount of time to run and I had to restart a couple of times to continue where it left off. Thus, I don't have a default "runtime" screencap like I usually do. But, it took ~ 3 weeks. Additionally, the output files are all _very_ large (~100GB _each_!).

Output folder:

- [20230221-pver-diamond-meganizer-E5_RNAseq/](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/)

The resulting MEGANized DIAMOND BLASTx DAA files can now be imported into MEGAN6 to visualize/quantify read classification across taxonomic groups. Additionally, MEGAN6 can also be used to separate reads based on taxonomy, if desired.

---

List of all MEGANized DAA output files:

- [C17_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C17_R1.blastx.meganized.daa) (110G)

  - MD5: `be9b3c559ba723abe6788571adbfd474`

- [C17_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C17_R2.blastx.meganized.daa) (107G)

  - MD5: `8cf0e78112148e8c73e854ca510da445`

- [C18_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C18_R1.blastx.meganized.daa) (108G)

  - MD5: `2ef115e884ca0dd55d5088f8d007e80e`

- [C18_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C18_R2.blastx.meganized.daa) (106G)

  - MD5: `a9004484f55627760ab32446e8e32cf1`

- [C19_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C19_R1.blastx.meganized.daa) (110G)

  - MD5: `480d97311d1e9f3509a534f1272f2ce1`

- [C19_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C19_R2.blastx.meganized.daa) (108G)

  - MD5: `4537c13070fa9f2479f35593f4381687`

- [C20_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C20_R1.blastx.meganized.daa) (113G)

  - MD5: `67a1ffdd3a28eaea24842f9844e426e6`

- [C20_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C20_R2.blastx.meganized.daa) (111G)

  - MD5: `dbffe78b8726d2d2d8dde50295593096`

- [C21_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C21_R1.blastx.meganized.daa) (75G)

  - MD5: `ddff06097a72bfad996f09be4e8bd668`

- [C21_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C21_R2.blastx.meganized.daa) (72G)

  - MD5: `fb1d7031bf7516d901774294ac96134b`

- [C22_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C22_R1.blastx.meganized.daa) (113G)

  - MD5: `45dbfd94aaac899ece46395e93d55c8a`

- [C22_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C22_R2.blastx.meganized.daa) (110G)

  - MD5: `d703065dc3b7fcbe2b3dd69b652a576a`

- [C23_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C23_R1.blastx.meganized.daa) (100G)

  - MD5: `71d97580338e50ea290783ebdd0ba4ed`

- [C23_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C23_R2.blastx.meganized.daa) (97G)

  - MD5: `cac405cd7c9c5b10d0d212f38716c864`

- [C24_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C24_R1.blastx.meganized.daa) (115G)

  - MD5: `1706251787b6dbc59adce51f08660496`

- [C24_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C24_R2.blastx.meganized.daa) (111G)

  - MD5: `6106fd2e7cc2081e6597ba11e08f6ecb`

- [C25_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C25_R1.blastx.meganized.daa) (132G)

  - MD5: `057c4be22f10ebb38810fac5e3aa19f2`

- [C25_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C25_R2.blastx.meganized.daa) (128G)

  - MD5: `0c7b5cfbe71205136c5d9e4137598184`

- [C26_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C26_R1.blastx.meganized.daa) (99G)

  - MD5: `7e98d11e52626098ad87aad5724ab219`

- [C26_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C26_R2.blastx.meganized.daa) (97G)

  - MD5: `ac81a6312081c067b39edd62c7caccaa`

- [C27_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C27_R1.blastx.meganized.daa) (109G)

  - MD5: `6ab40680af6ac326ae0caf21becb4686`

- [C27_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C27_R2.blastx.meganized.daa) (105G)

  - MD5: `516659fce2b18cdf85c69c4d535a5fb4`

- [C28_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C28_R1.blastx.meganized.daa) (107G)

  - MD5: `905b9c8ed40079b02ceaa10a9ad13b11`

- [C28_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C28_R2.blastx.meganized.daa) (104G)

  - MD5: `7a873065b8811a3c1d30d77687babb97`

- [C29_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C29_R1.blastx.meganized.daa) (81G)

  - MD5: `5d3f5a59e15fc938da9b1d4494006100`

- [C29_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C29_R2.blastx.meganized.daa) (80G)

  - MD5: `4af338f349ab57eb89dee4c61ad02157`

- [C30_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C30_R1.blastx.meganized.daa) (128G)

  - MD5: `4dc54e030b94a138a278a203e835306a`

- [C30_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C30_R2.blastx.meganized.daa) (123G)

  - MD5: `93d0d816312f3741bd237daa725af7e2`

- [C31_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C31_R1.blastx.meganized.daa) (114G)

  - MD5: `ff20b2a788e2d2026aab9d4cc230ea0b`

- [C31_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C31_R2.blastx.meganized.daa) (110G)

  - MD5: `97b3b2610007664592d896afe54faf9c`

- [C32_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C32_R1.blastx.meganized.daa) (120G)

  - MD5: `2ddca606834c351e2d8d1c518b168862`

- [C32_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/C32_R2.blastx.meganized.daa) (117G)

  - MD5: `6c9ecf752eea45b39567b38a9891d08d`

- [E10_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E10_R1.blastx.meganized.daa) (133G)

  - MD5: `dce1c1592422a24060cd7ec687bbe979`

- [E10_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E10_R2.blastx.meganized.daa) (129G)

  - MD5: `7895c253564959372c893691a65b06ad`

- [E11_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E11_R1.blastx.meganized.daa) (82G)

  - MD5: ``

- [E11_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E11_R2.blastx.meganized.daa) (80G)

  - MD5: ``

- [E12_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E12_R1.blastx.meganized.daa) (140G)

  - MD5: `358595b80994e5d69eec7c8526cfbaa9`

- [E12_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E12_R2.blastx.meganized.daa) (136G)

  - MD5: `ceca96ac43676836cce3e0d4665cd72e`

- [E13_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E13_R1.blastx.meganized.daa) (118G)

  - MD5: `9f821a77046c85d49da52a63645ee21b`

- [E13_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E13_R2.blastx.meganized.daa) (115G)

  - MD5: `838b573c1bba5a09f4dae0d0f9dd6e47`

- [E14_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E14_R1.blastx.meganized.daa) (106G)

  - MD5: `08fb7bc876db3b6931ffc418ae13e340`

- [E14_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E14_R2.blastx.meganized.daa) (103G)

  - MD5: `2debfdd94dab304b8f9c868cb6c69e3c`

- [E15_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E15_R1.blastx.meganized.daa) (103G)

  - MD5: `9f435164fe31f58938c85c1623a6bf7b`

- [E15_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E15_R2.blastx.meganized.daa) (100G)

  - MD5: `dbde35c6da30e434d9926198c282faa1`

- [E16_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E16_R1.blastx.meganized.daa) (134G)

  - MD5: `34ad5152843e3ee8b319c920e5a19646`

- [E16_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E16_R2.blastx.meganized.daa) (131G)

  - MD5: `336599bb1e3e62dafed617a12e596942`

- [E1_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E1_R1.blastx.meganized.daa) (114G)

  - MD5: `e3c45073f599b0b9ae61e791a80491b8`

- [E1_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E1_R2.blastx.meganized.daa) (112G)

  - MD5: `d767d0f450f2f7f3b5a5b57b5bb7cf08`

- [E2_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E2_R1.blastx.meganized.daa) (110G)

  - MD5: `dcd6cae85765bf0826edca36eadfc336`

- [E2_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E2_R2.blastx.meganized.daa) (108G)

  - MD5: `6ac3437b42d007224d6f03de3b5247ee`

- [E3_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E3_R1.blastx.meganized.daa) (120G)

  - MD5: `d84a9308792ebdae52cee5ab3094be68`

- [E3_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E3_R2.blastx.meganized.daa) (119G)

  - MD5: `d5dfec54bb56af0c0f9f86821e35c2e7`

- [E4_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E4_R1.blastx.meganized.daa) (101G)

  - MD5: `41502debf9a6d4618cbbebb076ab833e`

- [E4_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E4_R2.blastx.meganized.daa) (99G)

  - MD5: `e3fc7b190daf7e607a13a0a27f0bb7a2`

- [E5_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E5_R1.blastx.meganized.daa) (71G)

  - MD5: `713752d87b09ad72c43afeea378530bc`

- [E5_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E5_R2.blastx.meganized.daa) (70G)

  - MD5: `657f1f8ada0d3c411a2556c16b713b24`

- [E6_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E6_R1.blastx.meganized.daa) (126G)

  - MD5: `404ba9d64db6639d202d3960c1ad9c02`

- [E6_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E6_R2.blastx.meganized.daa) (125G)

  - MD5: `6a74ab0c0e8eb866b4eec56dfde948e1`

- [E7_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E7_R1.blastx.meganized.daa) (112G)

  - MD5: `314dc6e70fca57d3cfe14a33ffdd72a1`

- [E7_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E7_R2.blastx.meganized.daa) (109G)

  - MD5: `85279fb94656f1f6f8fbc880f9f62026`

- [E8_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E8_R1.blastx.meganized.daa) (110G)

  - MD5: `85ac6332ee4777a1b307cb83ce2c1974`

- [E8_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E8_R2.blastx.meganized.daa) (108G)

  - MD5: `1e285d6d06f3cff942a7c53099f93113`

- [E9_R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E9_R1.blastx.meganized.daa) (116G)

  - MD5: `e911058c6af6e360d8f82c4432d35f48`

- [E9_R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230221-pver-diamond-meganizer-E5_RNAseq/E9_R2.blastx.meganized.daa) (113G)

  - MD5: `ed219f906c7a3ef7c7cc2ddeb665439a`