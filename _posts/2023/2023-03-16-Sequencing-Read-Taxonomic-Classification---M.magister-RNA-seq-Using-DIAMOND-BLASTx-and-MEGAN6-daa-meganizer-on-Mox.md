---
layout: post
title: Sequencing Read Taxonomic Classification - M.magister RNA-seq Using DIAMOND BLASTx and MEGAN6 daa-meganizer on Mox
date: '2023-03-16 11:12'
tags: 
  - MEGAN6
  - RNAseq
  - Metacarcinus magister
  - dungeness crab
  - mox
  - daa-meganizer
categories: 
  - Miscellaneous
---
Running DIAMOND BLASTx, followed by [MEGAN6](https://software-ab.cs.uni-tuebingen.de/download/megan6/welcome.html) `daa-meganizer` for taxonomic classification of NOAA _M.magister_ trimmed RNA-seq reads (provided by Giles Goetz on [20230301](https://robertslab.github.io/sams-notebook/2023/03/01/Data-Received-Trimmed-M.magister-RNA-seq-from-NOAA.html)). This is primarily just for curiosity, per [Steven's GitHub Issue](https://github.com/RobertsLab/resources/issues/1597). This was run on Mox.



SBATCH Script (GitHub):

- [20230316-mmag-diamond-meganizer-RNAseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20230316-mmag-diamond-meganizer-RNAseq.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20230316-mmag-diamond-meganizer-RNAseq
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230316-mmag-diamond-meganizer-RNAseq

## Perform DIAMOND BLASTx on trimmed M.magister RNA-seq files from 20230301.
## Will be used to view taxonomic breakdown of sequencing reads.

## Expects input FastQ files to be match this pattern: *.trimmed.R[12].fastq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

fastq_pattern='*.trimmed.R[12].fastq.gz'

# Program paths
diamond=/gscratch/srlab/programs/diamond-v2.1.1/diamond
meganizer=/gscratch/srlab/programs/MEGAN-6.22.0/tools/daa-meganizer

# DIAMOND NCBI nr database
dmnd_db=/gscratch/srlab/blastdbs/20230215-ncbi-nr/20230215-ncbi-nr.dmnd

# MEGAN mapping files
megan_mapping_dir=/gscratch/srlab/sam/data/databases/MEGAN
megan_mapdb="${megan_mapping_dir}/megan-map-Feb2022.db"

# FastQ files directory
fastq_dir=/gscratch/srlab/sam/data/M_magister/RNAseq/trimmed

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

	# Strip leading path ${fastq##*/} by eliminating all text up to and including last slash from the left side.
    # Strip extensions by eliminating ".fastq.gz" from the right side.
	no_path=$(echo "${fastq##*/}")
	no_ext=$(echo "${no_path%%.fastq.gz}")

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

This took an insane amount of time to run: 41 _days_! This required me to run the remainder of the files in a second Mox job after the initial job exceeded the time limit I specified.

![Screenshot showing runtimes of the two jobs needed to process all of the M.magister DIAMOND BLASTx MEGANization.](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20230316-mmag-diamond-meganizer-RNAseq-runtime.png?raw=true)


The output files generated from this are absolutely _huge_! The _smallest_ file size is 68GB! The next step is two open these up in MEGAN6 and get a sense of the taxonomic breakdowns.

Output folder:

- [20230316-mmag-diamond-meganizer-RNAseq/](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/)

### MEGANized DAA files (DAA)

  - [CH01-06.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH01-06.trimmed.R1.blastx.meganized.daa) (170G)

    - MD5: `40cd0e6b88ebbcc623bcc703c1165767`

  - [CH01-06.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH01-06.trimmed.R2.blastx.meganized.daa) (172G)

    - MD5: `f0e49f829efcd8bd2759e77022ef1243`

  - [CH01-14.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH01-14.trimmed.R1.blastx.meganized.daa) (278G)

    - MD5: `aa2bd2293618975323e433b1c5b46af1`

  - [CH01-14.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH01-14.trimmed.R2.blastx.meganized.daa) (280G)

    - MD5: `9db3adecd8dcbb7bf35c609fe524e28c`

  - [CH01-22.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH01-22.trimmed.R1.blastx.meganized.daa) (118G)

    - MD5: `bb83f0f662d2ad048f6ea06fbd16cdd6`

  - [CH01-22.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH01-22.trimmed.R2.blastx.meganized.daa) (117G)

    - MD5: `26c9a3d732dc97b42d68fed33580989a`

  - [CH01-38.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH01-38.trimmed.R1.blastx.meganized.daa) (324G)

    - MD5: `24f600b7d0dc6625b1abd61abd40ba1a`

  - [CH01-38.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH01-38.trimmed.R2.blastx.meganized.daa) (327G)

    - MD5: `2c826f5c4d4cbe7e292c8633eda0045e`

  - [CH03-04.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH03-04.trimmed.R1.blastx.meganized.daa) (115G)

    - MD5: `221647010a04a7b90b5f43c09a66d255`

  - [CH03-04.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH03-04.trimmed.R2.blastx.meganized.daa) (115G)

    - MD5: `71aadedcb59ec1674aab190ea5e0b074`

  - [CH03-15.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH03-15.trimmed.R1.blastx.meganized.daa) (144G)

    - MD5: `d28e53896fb69761525dc3ebe51cd6d9`

  - [CH03-15.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH03-15.trimmed.R2.blastx.meganized.daa) (146G)

    - MD5: `f8c7cb85b6fe53fa8f29e35545a611cb`

  - [CH03-33.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH03-33.trimmed.R1.blastx.meganized.daa) (125G)

    - MD5: `1a48b209c2a5f378f68f2bd480edb909`

  - [CH03-33.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH03-33.trimmed.R2.blastx.meganized.daa) (128G)

    - MD5: `8e945f239f12e21cde91d96c3bfd22b0`

  - [CH05-01.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH05-01.trimmed.R1.blastx.meganized.daa) (192G)

    - MD5: `1b0ce1658f4e82702574b087069f44fe`

  - [CH05-01.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH05-01.trimmed.R2.blastx.meganized.daa) (193G)

    - MD5: `60a20767d13faa5147ae48182bc2f822`

  - [CH05-06.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH05-06.trimmed.R1.blastx.meganized.daa) (225G)

    - MD5: `0cbd183dd93be39311d087a957f336bc`

  - [CH05-06.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH05-06.trimmed.R2.blastx.meganized.daa) (227G)

    - MD5: `321269d6616c95bc46e7939ff7c54cf2`

  - [CH05-07.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH05-07.trimmed.R1.blastx.meganized.daa) (82G)

    - MD5: `d5d031054bf50b8b57db08970255ce38`

  - [CH05-07.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH05-07.trimmed.R2.blastx.meganized.daa) (83G)

    - MD5: `113fa38a7016da670082b1731bc52e3b`

  - [CH05-09.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH05-09.trimmed.R1.blastx.meganized.daa) (299G)

    - MD5: `3786ac49865bf0bdf35bb4f568c7b3fc`

  - [CH05-09.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH05-09.trimmed.R2.blastx.meganized.daa) (305G)

    - MD5: `b55eba3282c87da57b5d321ac937e96c`

  - [CH05-14.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH05-14.trimmed.R1.blastx.meganized.daa) (362G)

    - MD5: `d7212d9be6c2c77ec84f84097d25fca1`

  - [CH05-14.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH05-14.trimmed.R2.blastx.meganized.daa) (364G)

    - MD5: `e78be89442559acb8566af51b44b9853`

  - [CH05-21.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH05-21.trimmed.R1.blastx.meganized.daa) (380G)

    - MD5: `e263a8bb62cdd6fa6ca79bef6b1cc69c`

  - [CH05-21.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH05-21.trimmed.R2.blastx.meganized.daa) (385G)

    - MD5: `36fdfcbf693680e1cd950b21f7231159`

  - [CH05-29.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH05-29.trimmed.R1.blastx.meganized.daa) (189G)

    - MD5: `aa9c9a24e11f568cd3edf1ace1b8e0c5`

  - [CH05-29.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH05-29.trimmed.R2.blastx.meganized.daa) (191G)

    - MD5: `5893a50b3e354b191f2351696fa546b9`

  - [CH07-04.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH07-04.trimmed.R1.blastx.meganized.daa) (150G)

    - MD5: `fbc88fc2d5294b48a6f95e36cd18749a`

  - [CH07-04.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH07-04.trimmed.R2.blastx.meganized.daa) (151G)

    - MD5: `7f9b2f4d381a0e2d8c6cf1fed29b111e`

  - [CH07-06.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH07-06.trimmed.R1.blastx.meganized.daa) (287G)

    - MD5: `58fb37a4318fa24e11973bbecc738f2c`

  - [CH07-06.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH07-06.trimmed.R2.blastx.meganized.daa) (292G)

    - MD5: `f16e101aee88ee4dbb266524bf057b33`

  - [CH07-08.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH07-08.trimmed.R1.blastx.meganized.daa) (769G)

    - MD5: `8f1ccc1acf69eb131fcdb2b9a5589cad`

  - [CH07-08.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH07-08.trimmed.R2.blastx.meganized.daa) (774G)

    - MD5: `c950134f0975623f99a0c7be6dc80129`

  - [CH07-11.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH07-11.trimmed.R1.blastx.meganized.daa) (275G)

    - MD5: `3e546f482ab9c0b754f8b5138b153c30`

  - [CH07-11.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH07-11.trimmed.R2.blastx.meganized.daa) (280G)

    - MD5: `0b1ee907aa70051f4868d83a8bedf442`

  - [CH07-24.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH07-24.trimmed.R1.blastx.meganized.daa) (848G)

    - MD5: `cce94a417a5f52bc35f747b34c8f38cb`

  - [CH07-24.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH07-24.trimmed.R2.blastx.meganized.daa) (856G)

    - MD5: `643b6a4a5338c68f5e7d83882f312e14`

  - [CH09-02.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH09-02.trimmed.R1.blastx.meganized.daa) (115G)

    - MD5: `f18701d768fd7b88ee17f34fde6af332`

  - [CH09-02.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH09-02.trimmed.R2.blastx.meganized.daa) (116G)

    - MD5: `704d7e770b98a8640b6380a31e87b2d8`

  - [CH09-13.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH09-13.trimmed.R1.blastx.meganized.daa) (68G)

    - MD5: `f17ffe982e1cfab2990cdbbd262437f0`

  - [CH09-13.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH09-13.trimmed.R2.blastx.meganized.daa) (69G)

    - MD5: `fd3905e5c4b3ef8a4a8de2cee1d7ffea`

  - [CH09-28.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH09-28.trimmed.R1.blastx.meganized.daa) (72G)

    - MD5: `9878ae6dc902124f6e20b0047549f100`

  - [CH09-28.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH09-28.trimmed.R2.blastx.meganized.daa) (73G)

    - MD5: `bd5079f578dc0b03ef8bdbeb12e013b4`

  - [CH10-08.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH10-08.trimmed.R1.blastx.meganized.daa) (247G)

    - MD5: `2591f18e401dc13003b3c6e74f40b726`

  - [CH10-08.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH10-08.trimmed.R2.blastx.meganized.daa) (248G)

    - MD5: `171de114cdc7e656004da6fc88ce296e`

  - [CH10-11.trimmed.R1.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH10-11.trimmed.R1.blastx.meganized.daa) (97G)

    - MD5: `771d532b1ff7d71d108aae16cfc0fc0a`

  - [CH10-11.trimmed.R2.blastx.meganized.daa](https://gannet.fish.washington.edu/Atumefaciens/20230316-mmag-diamond-meganizer-RNAseq/CH10-11.trimmed.R2.blastx.meganized.daa) (97G)

    - MD5: `83eefbb73c44b62fce38b6767fdc6a7d`
