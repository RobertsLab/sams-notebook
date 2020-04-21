#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_DEG_basic
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=04-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200421_cbai_DEG_basic_comparisons

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


wd="$(pwd)"
timestamp=$(date +%Y%m%d)
species="cbai"
threads=28

fastq_dir=/gscratch/srlab/sam/data/C_bairdi/RNAseq/
comparisons=(infected-uninfected D9-D12 D9-D26 D12-D26 ambient-cold ambient-warm cold-warm)

# Functions
get_day () { day=$(echo "$1" | awk -F"." '{print $4}'); }
get_inf () { inf=$(echo "$1" | awk -F"." '{print $5}'); }
get_temp () { temp=$(echo "$1" | awk -F"." '{print $6}'); }
get_sample_id () { sample_id=$(echo "$1" | awk -F"." '{print $3}'); }

for comparison in "${!comparisons[@]}"
do
  count=0
  samples="${comparison}.samples.txt"
  comparison=${comparisons[${comparison}]}
  mkdir "${comparison}"
  cd "${comparison}" || exit

  cond1=$(echo "${comparison}" | awk -F"-" '{print $1}')
  cond2=$(echo "${comparison}" | awk -F"-" '{print $2}')

  if [[ "${comparison}" == "infected-uninfected" ]]; then
    rsync --archive --verbose ${fastq_dir}*.fq .
  fi

  if [[ "${comparison}" == "D9-D12" ]]; then
    #statements
    for fastq in "${fastq_dir}"*.fq
    do
      get_day "${fastq}"
      if [[ "${day}" == "D9" || "${day}" == "D12" ]]; then
        rsync --archive --verbose "${fastq}" .
      fi
    done
  fi

  if [[ "${comparison}" == "D9-D26" ]]; then
    #statements
    for fastq in "${fastq_dir}"*.fq
    do
      get_day "${fastq}"
      if [[ "${day}" == "D9" || "${day}" == "D26" ]]; then
        rsync --archive --verbose "${fastq}" .
      fi
    done
  fi

  if [[ "${comparison}" == "D12-D26" ]]; then
    #statements
    for fastq in "${fastq_dir}"*.fq
    do
      get_day "${fastq}"
      if [[ "${day}" == "D12" || "${day}" == "D26" ]]; then
        rsync --archive --verbose "${fastq}" .
      fi
    done
  fi

  if [[ "${comparison}" == "ambient-cold" ]]; then
    #statements
    for fastq in "${fastq_dir}"*.fq
    do
      get_temp "${fastq}"
      if [[ "${temp}" == "ambient" || "${temp}" == "cold" ]]; then
        rsync --archive --verbose "${fastq}" .
      fi
    done
  fi

  if [[ "${comparison}" == "ambient-warm" ]]; then
    #statements
    for fastq in "${fastq_dir}"*.fq
    do
      get_temp "${fastq}"
      if [[ "${temp}" == "ambient" || "${temp}" == "warm" ]]; then
        rsync --archive --verbose "${fastq}" .
      fi
    done
  fi

  if [[ "${comparison}" == "cold-warm" ]]; then
    #statements
    for fastq in "${fastq_dir}"*.fq
    do
      get_temp "${fastq}"
      if [[ "${temp}" == "cold" || "${temp}" == "warm" ]]; then
        rsync --archive --verbose "${fastq}" .
      fi
    done
  fi

  # Create reads array
  reads_array=(*.fq)

  # Loop to create sample list file
  for (( i=0; i<${#reads_array[@]} ; i+=2 ))
  do
    (( count ++ ))

    get_day "${reads_array[i]}"
    get_inf "${reads_array[i]}"
    get_temp "${reads_array[i]}"

    if [[ "${cond1}" == "${day}" || "${cond1}" == "${inf}" || "${cond1}" || "${temp}" ]]; then
      #statements
      # Create tab-delimited samples file.
      printf "%s\t%s%02d\t%s\t%s\n" "${cond1}" "${comparison}_" "${count}" "${reads_array[i]}" "${reads_array[i+1]}" \
      >> "${samples}"
    elif [[ "${cond2}" == "${day}" || "${cond2}" == "${inf}" || "${cond2}" || "${temp}" ]]; then
      printf "%s\t%s%02d\t%s\t%s\n" "${cond2}" "${comparison}_" "${count}" "${reads_array[i]}" "${reads_array[i+1]}" \
      >> "${samples}"
    fi
  done

done
