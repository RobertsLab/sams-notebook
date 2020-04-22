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

DIAMOND BLASTx will and Meganization will be run on Mox. Conversion to RMA6 files will be done on my computer (swoose), due to MEGAN6's reliance on Java X11 window (this is not available on Mox - throws an error when trying to run it).

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

DAA conversion to RMA6 on swoose (GitHub):

- [20200414_cbai_diamond_blastx_daa2rma.sh](https://github.com/RobertsLab/sams-notebook/blob/master/bash_scripts/20200414_cbai_diamond_blastx_daa2rma.sh)

```shell
#!/bin/bash

# Script to run MEGAN6 meganizer on DIAMOND DAA files from
# 20200414_cbai_diamond_blastx Mox job.

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


# Populate array with unique sample names
## NOTE: Requires Bash >=v4.0
mapfile -t samples_array < <( for daa in *.daa; do echo "${daa}" | awk -F"_" '{print $1}'; done | sort -u )

# Loop to concatenate same sample R1 and R2 reads
for sample in "${!samples_array[@]}"
do
  # Concatenate R1 reads for each sample
  for daa in *R1*.daa
  do
    daa_sample=$(echo "${daa}" | awk -F"_" '{print $1}')
    if [ "${samples_array[sample]}" == "${daa_sample}" ]; then
      reads_1=${samples_array[sample]}_reads_1.daa
      echo "Concatenating ${daa} with ${reads_1}"
      cat "${daa}" >> "${reads_1}"
    fi
  done

  # Concatenate R2 reads for each sample
  for daa in *R2*.daa
  do
    daa_sample=$(echo "${daa}" | awk -F"_" '{print $1}')
    if [ "${samples_array[sample]}" == "${daa_sample}" ]; then
      reads_2=${samples_array[sample]}_reads_2.daa
      echo "Concatenating ${daa} with ${reads_2}"
      cat "${daa}" >> "${reads_2}"
    fi
  done
done

# Create array of DAA R1 files
for daa in *reads_1.daa
do
  daa_array_R1+=("${daa}")
done

# Create array of DAA R2 files
for daa in *reads_2.daa
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

The initial BLASTx and meganization didn't take terribly long, ~1.6 days :

![diamond/meganization runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200414_cbai_diamond_blastx_runtime.png?raw=true)


Conversion from DAA to RMA6 took almost the same amount of time.

Output folder:

- [20200414_cbai_diamond_blastx/](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/)


Output files ("meganized" DAA files):

- [380820_reads_1.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380820_reads_1.daa) (49G)

- [380820_reads_2.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380820_reads_2.daa) (46G)

- [380820_S1_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380820_S1_L001_R1_001.blastx.daa) (25G)

- [380820_S1_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380820_S1_L001_R2_001.blastx.daa) (23G)

- [380820_S1_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380820_S1_L002_R1_001.blastx.daa) (25G)

- [380820_S1_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380820_S1_L002_R2_001.blastx.daa) (23G)

- [380821_reads_1.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380821_reads_1.daa) (42G)

- [380821_reads_2.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380821_reads_2.daa) (40G)

- [380821_S2_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380821_S2_L001_R1_001.blastx.daa) (21G)

- [380821_S2_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380821_S2_L001_R2_001.blastx.daa) (20G)

- [380821_S2_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380821_S2_L002_R1_001.blastx.daa) (21G)

- [380821_S2_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380821_S2_L002_R2_001.blastx.daa) (20G)

- [380822_reads_1.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380822_reads_1.daa) (44G)

- [380822_reads_2.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380822_reads_2.daa) (40G)

- [380822_S3_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380822_S3_L001_R1_001.blastx.daa) (22G)

- [380822_S3_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380822_S3_L001_R2_001.blastx.daa) (20G)

- [380822_S3_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380822_S3_L002_R1_001.blastx.daa) (22G)

- [380822_S3_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380822_S3_L002_R2_001.blastx.daa) (20G)

- [380823_reads_1.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380823_reads_1.daa) (37G)

- [380823_reads_2.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380823_reads_2.daa) (34G)

- [380823_S4_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380823_S4_L001_R1_001.blastx.daa) (19G)

- [380823_S4_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380823_S4_L001_R2_001.blastx.daa) (17G)

- [380823_S4_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380823_S4_L002_R1_001.blastx.daa) (19G)

- [380823_S4_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380823_S4_L002_R2_001.blastx.daa) (17G)

- [380824_reads_1.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380824_reads_1.daa) (47G)

- [380824_reads_2.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380824_reads_2.daa) (42G)

- [380824_S5_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380824_S5_L001_R1_001.blastx.daa) (24G)

- [380824_S5_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380824_S5_L001_R2_001.blastx.daa) (21G)

- [380824_S5_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380824_S5_L002_R1_001.blastx.daa) (23G)

- [380824_S5_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380824_S5_L002_R2_001.blastx.daa) (22G)

- [380825_reads_1.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380825_reads_1.daa) (43G)

- [380825_reads_2.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380825_reads_2.daa) (40G)

- [380825_S6_L001_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380825_S6_L001_R1_001.blastx.daa) (22G)

- [380825_S6_L001_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380825_S6_L001_R2_001.blastx.daa) (20G)

- [380825_S6_L002_R1_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380825_S6_L002_R1_001.blastx.daa) (22G)

- [380825_S6_L002_R2_001.blastx.daa](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380825_S6_L002_R2_001.blastx.daa) (20G)



Output files for loading into MEGAN6 (RMA6):

- [380820.daa2rma.rma6](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380820.daa2rma.rma6)

- [380821.daa2rma.rma6](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380821.daa2rma.rma6)

- [380822.daa2rma.rma6](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380822.daa2rma.rma6)

- [380823.daa2rma.rma6](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380823.daa2rma.rma6)

- [380824.daa2rma.rma6](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380824.daa2rma.rma6)

- [380825.daa2rma.rma6](https://gannet.fish.washington.edu/Atumefaciens/20200414_cbai_diamond_blastx/380825.daa2rma.rma6)


These will be loaded into MEGAN6 and reads will be extracted based on classification to _Alveolata_ and/or _Arthropoda_ phyla.
