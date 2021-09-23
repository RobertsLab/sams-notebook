---
layout: post
title: Transcriptome Annotation - C.bairdi Using DIAMOND BLASTx on Mox and MEGAN6 Meganizer on swoose
date: '2020-03-18 20:56'
tags:
  - Tanner crab
  - RNAseq
  - DIAMOND
  - BLASTx
  - mox
  - MEGAN6
  - meganizer
  - Chionoecetes bairdi
categories:
  - Tanner Crab RNAseq
---
[After receiving/trimming the latest round of _C.bairdi_ RNAseq data on 20200318](https://robertslab.github.io/sams-notebook/2020/03/18/TrimmingQCMultiQC-C.bairdi-RNAseq-FastQ-with-fastp-on-Mox.html), need to get the data ready to perform taxonomic selection of sequencing reads. To do this, I first need to run [DIAMOND BLASTx](https://github.com/bbuchfink/diamond), then "meganize" the output files in preparation for loading into [MEGAN6](https://uni-tuebingen.de/fakultaeten/mathematisch-naturwissenschaftliche-fakultaet/fachbereiche/informatik/lehrstuehle/algorithms-in-bioinformatics/software/megan6/), which will allow for taxonomic-specific read separation.

DIAMOND BLASTx will be run on Mox. Meganization will be run on my computer (swoose), due to MEGAN6's reliance on Java X11 window (this is not available on Mox - throws an error when trying to run it).

I fully anticipate this process to take a week or two (DIAMOND BLASTx will likely take a few days and read extraction will definitely take many days...)

SBATCH script (GitHub):

- [20200318_cbai_diamond_blastx.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200318_cbai_diamond_blastx.sh)

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
#SBATCH --time=20-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200318_cbai_diamond_blastx

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
fastq_dir=/gscratch/scrubbed/samwhite/outputs/20200318_cbai_RNAseq_fastp_trimming/


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

MEGANIZER script (GitHub):

- [20200323_cbai_diamond_blastx_meganizer.sh](https://github.com/RobertsLab/sams-notebook/blob/master/bash_scripts/20200323_cbai_diamond_blastx_meganizer.sh)

```shell
#!/bin/bash

# Script to run MEGAN6 meganizer on DIAMOND DAA files from
# 20200318_cbai_diamond_blastx Mox job.

# Requires MEGAN mapping files from:
# http://ab.inf.uni-tuebingen.de/data/software/megan6/download/

# Exit script if any command fails
set -e

# Program path
meganizer=/home/sam/programs/megan/tools/daa2rma

# MEGAN mapping files
prot_acc2tax=/home/sam/data/databases/MEGAN/prot_acc2tax-Jul2019X1.abin
acc2interpro=/home/sam/data/databases/MEGAN/acc2interpro-Jul2019X.abin
acc2eggnog=/home/sam/data/databases/MEGAN/acc2eggnog-Jul2019X.abin


## Inititalize arrays
daa_array_R1=()
daa_array_R2=()

# Create array of DAA R1 files
for daa in *R1*.daa
do
  daa_array_R1+=("${daa}")
done

# Create array of DAA R2 files
for daa in *R2*.daa
do
  daa_array_R2+=("${daa}")
done

## Run MEGANIZER

# Capture start "time"
# Uses builtin bash variable called ${SECONDS}
start=${SECONDS}

for index in "${!daa_array_R1[@]}"
do
  start_loop=${SECONDS}
  sample_name=$(echo "${daa_array_R1[index]}" | awk -F "_" '{print $1}')

  echo "Now processing ${sample_name}.daa2rma.rma6"
  echo ""

  # Run daa2rma with paired option
  ${meganizer} \
  --paired \
  --in "${daa_array_R1[index]}" "${daa_array_R2[index]}" \
	--acc2taxa ${prot_acc2tax} \
	--acc2interpro2go ${acc2interpro} \
	--acc2eggnog ${acc2eggnog} \
  --out "${sample_name}".daa2rma.rma6 \
  2>&1 | tee --append daa2rma_log.txt

  end_loop=${SECONDS}
  loop_runtime=$((end_loop-start_loop))


  echo "Finished processing ${sample_name}.daa2rma.rma6 in ${loop_runtime} seconds."
  echo ""

done

# Caputure end "time"
end=${SECONDS}

runtime=$((end-start))

# Print MEGANIZER runtime, in seconds

{
  echo ""
  echo "---------------------"
  echo ""
  echo "Total runtime was: ${runtime} seconds"
} >> daa2rma_log.txt
```

---

#### RESULTS

DIAMOND BLASTx took ~4.5 days:

- [DIAMOND BLASTx runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200318_cbai_diamond_blastx_runtime.png?raw=true)

The subsequent conversion from DAA to RMA6 files to ~5.6 days.

Output folder:

- [20200318_cbai_diamond_blastx/](https://gannet.fish.washington.edu/Atumefaciens/20200318_cbai_diamond_blastx/)

The RMA6 files can now be loaded into MEGAN6 to extract reads based on taxonomy.
