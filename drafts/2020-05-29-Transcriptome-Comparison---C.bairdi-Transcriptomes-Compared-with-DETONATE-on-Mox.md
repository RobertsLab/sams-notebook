---
layout: post
title: Transcriptome Comparison - C.bairdi Transcriptomes Compared with DETONATE on Mox
date: '2020-05-29 09:40'
tags:
  - Tanner crab
  - Chionoecetes bairdi
  - mox
  - DETONATE
  - Carcinus maenas
  - green crab
  - Portunus trituberculatus
  - Japanese blue crab
categories:
  - Miscellaneous
---


SBATCH script (GitHub):

- [20200529_cbai_detonate_transcriptome_comparisons.sh](https://github.com/RobertsLab/sams-notebook/blob/f41eb77f8e22c263cf364d536f8b720f6737b8d4/sbatch_scripts/20200529_cbai_detonate_transcriptome_comparisons.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_detonate_transcriptome_comparisons
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=8-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200529_cbai_detonate_transcriptome_comparisons


###################################################################################
# These variables need to be set by user

# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
transcriptomes_array=(
cbai_transcriptome_v1.0.fa \
cbai_transcriptome_v1.5.fa \
cbai_transcriptome_v1.6.fa \
cbai_transcriptome_v1.7.fa \
cbai_transcriptome_v2.0.fa \
cbai_transcriptome_v3.0.fa \
20200526.P_trituberculatus.Trinity.fa \
GFFJ01.1.fa \
GBXE01.1.fa
)


###################################################################################

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


threads=28

#programs
pblat="/gscratch/srlab/programs/pblat-2.1/pblat"
detonate="/gscratch/srlab/programs/detonate-1.11/ref-eval/ref-eval"


# Determine length of transcriptomes array
transcriptomes_array_length=${#transcriptomes_array[@]}

# Loop through each comparison
for (( i=0; i < transcriptomes_array_length; i++ ))
do
  transcriptome1="${transcriptomes_array[$i]}"

  # Capture FastA checksums for verification
  echo "Generating checksum for ${transcriptome1}"
  md5sum "${transcriptome1}" >> fasta.checksums.md5
  echo "Finished generating checksum for ${transcriptome1}"
  echo ""

  for (( j=0; j < transcriptomes_array_length; j++ ))
  do
    # Don't run comparison of the same transcriptome
    if [[ "${transcriptomes_array[$j]}" != "${transcriptomes_array[$i]}" ]]; then
      transcriptome2="${transcriptomes_array[$j]}"
      comparison1="${transcriptome1}-vs-${transcriptome2}"
      comparison2="${transcriptome2}-vs-${transcriptome1}"

      # Check if pblat output files are not present
      if [[ ! -f "${comparison1}.psl" ]] && [[  -f "${comparison2}".psl ]]; then
        # Run pblat
        echo "Starting pblat: ${comparison1}"
        ${pblat} -minIdentity=80 -threads=${threads} "${transcriptome2}" "${transcriptome1}" "${comparison1}".psl
        echo "Finished pblat: ${comparison1}"
        echo ""

        echo "Starting pblat: ${comparison2}"
        ${pblat} -minIdentity=80 -threads=${threads} "${transcriptome1}" "${transcriptome2}" "${comparison2}".psl
        echo "Finished pblat: ${comparison2}"
        echo ""
      fi

      # Check if DETONATE output file exists
      if [[ ! -f "${comparison1}.scores.txt" ]]; then
        # Run ref-eval, unweighted scores only
        echo "Running DETONATE with ${transcriptome1} and ${transcriptome2}."
        ${detonate} \
        --scores=nucl,pair,contig \
        --weighted=no \
        --A-seqs "${transcriptome1}" \
        --B-seqs "${transcriptome2}" \
        --A-to-B "${comparison1}".psl \
        --B-to-A "${comparison2}".psl \
        | tee "${comparison1}.scores.txt"
        echo "Finished DETONATE with ${transcriptome1} and ${transcriptome2}."
        echo ""
      fi
    fi


  done
done
```

---

#### RESULTS

Output folder:

- [20200529_cbai_detonate_transcriptome_comparisons/](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/)




#### Reference: cbai_transcriptome_v1.0

- [GBXE01.1.fa-vs-cbai_transcriptome_v1.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GBXE01.1.fa-vs-cbai_transcriptome_v1.0.fa.scores.txt)

- [GFFJ01.1.fa-vs-cbai_transcriptome_v1.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GFFJ01.1.fa-vs-cbai_transcriptome_v1.0.fa.scores.txt)

- [cbai_transcriptome_v1.5.fa-vs-cbai_transcriptome_v1.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.5.fa-vs-cbai_transcriptome_v1.0.fa.scores.txt)

- [cbai_transcriptome_v1.6.fa-vs-cbai_transcriptome_v1.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.6.fa-vs-cbai_transcriptome_v1.0.fa.scores.txt)

- [cbai_transcriptome_v1.7.fa-vs-cbai_transcriptome_v1.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.7.fa-vs-cbai_transcriptome_v1.0.fa.scores.txt)

- [cbai_transcriptome_v2.0.fa-vs-cbai_transcriptome_v1.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v2.0.fa-vs-cbai_transcriptome_v1.0.fa.scores.txt)

- [cbai_transcriptome_v3.0.fa-vs-cbai_transcriptome_v1.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v3.0.fa-vs-cbai_transcriptome_v1.0.fa.scores.txt)

---

#### Reference: cbai_transcriptome_v1.5

- [GBXE01.1.fa-vs-cbai_transcriptome_v1.5.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GBXE01.1.fa-vs-cbai_transcriptome_v1.5.fa.scores.txt)

- [GFFJ01.1.fa-vs-cbai_transcriptome_v1.5.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GFFJ01.1.fa-vs-cbai_transcriptome_v1.5.fa.scores.txt)

- [cbai_transcriptome_v1.0.fa-vs-cbai_transcriptome_v1.5.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.0.fa-vs-cbai_transcriptome_v1.5.fa.scores.txt)

- [cbai_transcriptome_v1.6.fa-vs-cbai_transcriptome_v1.5.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.6.fa-vs-cbai_transcriptome_v1.5.fa.scores.txt)

- [cbai_transcriptome_v1.7.fa-vs-cbai_transcriptome_v1.5.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.7.fa-vs-cbai_transcriptome_v1.5.fa.scores.txt)

- [cbai_transcriptome_v2.0.fa-vs-cbai_transcriptome_v1.5.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v2.0.fa-vs-cbai_transcriptome_v1.5.fa.scores.txt)

- [cbai_transcriptome_v3.0.fa-vs-cbai_transcriptome_v1.5.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v3.0.fa-vs-cbai_transcriptome_v1.5.fa.scores.txt)

---

#### Reference: cbai_transcriptome_v1.6

- [GBXE01.1.fa-vs-cbai_transcriptome_v1.6.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GBXE01.1.fa-vs-cbai_transcriptome_v1.6.fa.scores.txt)

- [GFFJ01.1.fa-vs-cbai_transcriptome_v1.6.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GFFJ01.1.fa-vs-cbai_transcriptome_v1.6.fa.scores.txt)

- [cbai_transcriptome_v1.0.fa-vs-cbai_transcriptome_v1.6.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.0.fa-vs-cbai_transcriptome_v1.6.fa.scores.txt)

- [cbai_transcriptome_v1.5.fa-vs-cbai_transcriptome_v1.6.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.5.fa-vs-cbai_transcriptome_v1.6.fa.scores.txt)

- [cbai_transcriptome_v1.7.fa-vs-cbai_transcriptome_v1.6.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.7.fa-vs-cbai_transcriptome_v1.6.fa.scores.txt)

- [cbai_transcriptome_v2.0.fa-vs-cbai_transcriptome_v1.6.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v2.0.fa-vs-cbai_transcriptome_v1.6.fa.scores.txt)

- [cbai_transcriptome_v3.0.fa-vs-cbai_transcriptome_v1.6.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v3.0.fa-vs-cbai_transcriptome_v1.6.fa.scores.txt)

---

#### Reference: cbai_transcriptome_v1.7

- [GBXE01.1.fa-vs-cbai_transcriptome_v1.7.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GBXE01.1.fa-vs-cbai_transcriptome_v1.7.fa.scores.txt)

- [GFFJ01.1.fa-vs-cbai_transcriptome_v1.7.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GFFJ01.1.fa-vs-cbai_transcriptome_v1.7.fa.scores.txt)

- [cbai_transcriptome_v1.0.fa-vs-cbai_transcriptome_v1.7.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.0.fa-vs-cbai_transcriptome_v1.7.fa.scores.txt)

- [cbai_transcriptome_v1.5.fa-vs-cbai_transcriptome_v1.7.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.5.fa-vs-cbai_transcriptome_v1.7.fa.scores.txt)

- [cbai_transcriptome_v1.6.fa-vs-cbai_transcriptome_v1.7.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.6.fa-vs-cbai_transcriptome_v1.7.fa.scores.txt)

- [cbai_transcriptome_v2.0.fa-vs-cbai_transcriptome_v1.7.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v2.0.fa-vs-cbai_transcriptome_v1.7.fa.scores.txt)

- [cbai_transcriptome_v3.0.fa-vs-cbai_transcriptome_v1.7.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v3.0.fa-vs-cbai_transcriptome_v1.7.fa.scores.txt)

---

#### Reference: cbai_transcriptome_v2.0

- [GBXE01.1.fa-vs-cbai_transcriptome_v2.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GBXE01.1.fa-vs-cbai_transcriptome_v2.0.fa.scores.txt)

- [GFFJ01.1.fa-vs-cbai_transcriptome_v2.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GFFJ01.1.fa-vs-cbai_transcriptome_v2.0.fa.scores.txt)

- [cbai_transcriptome_v1.0.fa-vs-cbai_transcriptome_v2.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.0.fa-vs-cbai_transcriptome_v2.0.fa.scores.txt)

- [cbai_transcriptome_v1.5.fa-vs-cbai_transcriptome_v2.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.5.fa-vs-cbai_transcriptome_v2.0.fa.scores.txt)

- [cbai_transcriptome_v1.6.fa-vs-cbai_transcriptome_v2.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.6.fa-vs-cbai_transcriptome_v2.0.fa.scores.txt)

- [cbai_transcriptome_v1.7.fa-vs-cbai_transcriptome_v2.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.7.fa-vs-cbai_transcriptome_v2.0.fa.scores.txt)

- [cbai_transcriptome_v3.0.fa-vs-cbai_transcriptome_v2.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v3.0.fa-vs-cbai_transcriptome_v2.0.fa.scores.txt)

---

#### Reference: cbai_transcriptome_v3.0

- [GBXE01.1.fa-vs-cbai_transcriptome_v3.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GBXE01.1.fa-vs-cbai_transcriptome_v3.0.fa.scores.txt)

- [GFFJ01.1.fa-vs-cbai_transcriptome_v3.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GFFJ01.1.fa-vs-cbai_transcriptome_v3.0.fa.scores.txt)

- [cbai_transcriptome_v1.0.fa-vs-cbai_transcriptome_v3.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.0.fa-vs-cbai_transcriptome_v3.0.fa.scores.txt)

- [cbai_transcriptome_v1.5.fa-vs-cbai_transcriptome_v3.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.5.fa-vs-cbai_transcriptome_v3.0.fa.scores.txt)

- [cbai_transcriptome_v1.6.fa-vs-cbai_transcriptome_v3.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.6.fa-vs-cbai_transcriptome_v3.0.fa.scores.txt)

- [cbai_transcriptome_v1.7.fa-vs-cbai_transcriptome_v3.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.7.fa-vs-cbai_transcriptome_v3.0.fa.scores.txt)

- [cbai_transcriptome_v2.0.fa-vs-cbai_transcriptome_v3.0.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v2.0.fa-vs-cbai_transcriptome_v3.0.fa.scores.txt)

---

#### Reference: 20200526.P_trituberculatus

- [GBXE01.1.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GBXE01.1.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt)

- [GFFJ01.1.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GFFJ01.1.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt)

- [cbai_transcriptome_v1.0.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.0.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt)

- [cbai_transcriptome_v1.5.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.5.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt)

- [cbai_transcriptome_v1.6.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.6.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt)

- [cbai_transcriptome_v1.7.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.7.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt)

- [cbai_transcriptome_v2.0.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v2.0.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt)

- [cbai_transcriptome_v3.0.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v3.0.fa-vs-20200526.P_trituberculatus.Trinity.fa.scores.txt)

---

#### Reference: GBXE01.1

- [GFFJ01.1.fa-vs-GBXE01.1.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GFFJ01.1.fa-vs-GBXE01.1.fa.scores.txt)

- [cbai_transcriptome_v1.0.fa-vs-GBXE01.1.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.0.fa-vs-GBXE01.1.fa.scores.txt)

- [cbai_transcriptome_v1.5.fa-vs-GBXE01.1.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.5.fa-vs-GBXE01.1.fa.scores.txt)

- [cbai_transcriptome_v1.6.fa-vs-GBXE01.1.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.6.fa-vs-GBXE01.1.fa.scores.txt)

- [cbai_transcriptome_v1.7.fa-vs-GBXE01.1.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.7.fa-vs-GBXE01.1.fa.scores.txt)

- [cbai_transcriptome_v2.0.fa-vs-GBXE01.1.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v2.0.fa-vs-GBXE01.1.fa.scores.txt)

- [cbai_transcriptome_v3.0.fa-vs-GBXE01.1.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v3.0.fa-vs-GBXE01.1.fa.scores.txt)

---

#### Reference: GFFJ01.1

- [GBXE01.1.fa-vs-GFFJ01.1.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/GBXE01.1.fa-vs-GFFJ01.1.fa.scores.txt)

- [cbai_transcriptome_v1.0.fa-vs-GFFJ01.1.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.0.fa-vs-GFFJ01.1.fa.scores.txt)

- [cbai_transcriptome_v1.5.fa-vs-GFFJ01.1.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.5.fa-vs-GFFJ01.1.fa.scores.txt)

- [cbai_transcriptome_v1.6.fa-vs-GFFJ01.1.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.6.fa-vs-GFFJ01.1.fa.scores.txt)

- [cbai_transcriptome_v1.7.fa-vs-GFFJ01.1.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v1.7.fa-vs-GFFJ01.1.fa.scores.txt)

- [cbai_transcriptome_v2.0.fa-vs-GFFJ01.1.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v2.0.fa-vs-GFFJ01.1.fa.scores.txt)

- [cbai_transcriptome_v3.0.fa-vs-GFFJ01.1.fa.scores.txt](https://gannet.fish.washington.edu/Atumefaciens/20200529_cbai_detonate_transcriptome_comparisons/cbai_transcriptome_v3.0.fa-vs-GFFJ01.1.fa.scores.txt)
