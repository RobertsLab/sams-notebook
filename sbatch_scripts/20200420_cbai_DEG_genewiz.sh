#!/bin/bash

fastq_dir=/gscratch/srlab/sam/data/C_bairdi/RNAseq/
comparisons=(infected-uninfected D9-D12 D9-D26 D12-D26 ambient-cold ambient-warm cold-warm)

# Functions
get_day () { day=$(echo "$1" | awk -F"." '{print $4}'); }
get_inf () { inf=$(echo "$1" | awk -F"." '{print $5}'); }
get_temp () { temp=$(echo "$1" | awk -F"." '{print $6}'); }

for comparison in "${!comparisons[@]}"
do
  comparison=${comparisons[${comparison}]}
  mkdir "${comparison}"
  cd "${comparison}" || exit
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
      get_day "${fastq}"
      if [[ "${day}" == "D9" || "${day}" == "D12" ]]; then
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

done
