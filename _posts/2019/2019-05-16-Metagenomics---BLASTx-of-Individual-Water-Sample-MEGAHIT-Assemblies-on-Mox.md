---
layout: post
title: Metagenomics - BLASTx of Individual Water Sample MEGAHIT Assemblies on Mox
date: '2019-05-16 14:47'
tags:
  - metagenomics
  - Panopea generosa
  - geoduck
  - mox
  - blastx
categories:
  - Miscellaneous
---
After a meeting on this project yesterda, we decided to try a few things to continue with various approaches to assessing the metagenome. One of the approaches is to run BLASTx on the individual water sample MEGAHIT assemblies [from 20190327 ](https://robertslab.github.io/sams-notebook/2019/03/27/Metagenome-Assemblies-P.generosa-Water-Samples-Trimmed-HiSeqX-Data-Using-Megahit-on-Mox.html) and obtain taxonomy info for them, so that's what I did here.

Here's how the sample names breakdown:

| Sample | Develomental Stage (days post-fertilization) | pH Treatment |
|--------|-------------------------|--------------|
| MG1    | 13                      | 8.2          |
| MG2    | 17                      | 8.2          |
| MG3    | 6                       | 7.1          |
| MG5    | 10                      | 8.2          |
| MG6    | 13                      | 7.1          |
| MG7    | 17                      | 7.1          |

SBATCH script (GitHub):

- [20190516_metagenomics_pgen_blastx.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20190516_metagenomics_pgen_blastx.sh)

```shell
    #!/bin/bash
    ## Job Name
    #SBATCH --job-name=blastx_metagenomics
    ## Allocation Definition
    #SBATCH --account=coenv
    #SBATCH --partition=coenv
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
    #SBATCH --workdir=/gscratch/scrubbed/samwhite/outputs/20190516_metagenomics_pgen_blastx

    # Exit script if any command fails
    set -e

    # Load Python Mox module for Python module availability

    module load intel-python3_2017

    # Document programs in PATH (primarily for program version ID)

    date >> system_path.log
    echo "" >> system_path.log
    echo "System PATH for $SLURM_JOB_ID" >> system_path.log
    echo "" >> system_path.log
    printf "%0.s-" {1..10} >> system_path.log
    echo "${PATH}" | tr : \\n >> system_path.log


    threads=28

    # Paths to programs
    blast_dir="/gscratch/srlab/programs/ncbi-blast-2.8.1+/bin"
    blastx="${blast_dir}/blastx"


    # Paths to blastdbs
    blastdb_dir="/gscratch/srlab/blastdbs/ncbi-sp-v5"
    blast_db="${blastdb_dir}/swissprot_v5"


    # Input files
    fasta_dir="/gscratch/srlab/sam/data/metagenomics/P_generosa/assemblies"


    ## Inititalize arrays
    fasta_array=()
    names_array=()

    # Export BLAST database directory
    export BLASTDB=${blastdb_dir}

    # Create array of FastA files
    # Create array of sample names
    ## Uses parameter substitution to strip leading path from filename
    for fasta in ${fasta_dir}/MG*.fa
    do
      fasta_array+=(${fasta})
      names_array+=($(echo "${fasta#${fasta_dir}/}" | awk -F"." '{print $1}'))
    done

    # Loop through arrays to customize sample names
    # and run BLASTx on each FastA
    for index in "${!names_array[@]}"
    do
      # Loops through sample names and appends appropriate treatment to each sample name
      sample_name=$(echo "${names_array[index]}")
      if [ "${sample_name}" == "MG1" ] \
      || [ "${sample_name}" == "MG2" ] \
      || [ "${sample_name}" == "MG5" ]
      then
        sample_name="${sample_name}"_pH82
      else
        sample_name="${sample_name}"_pH71
      fi

      # Create list of input FastA files
      echo "${fasta}" >> input.fasta.list.txt

      # Run BLASTx on each FastA
      ${blastx} \
      -query "${fasta_array[index]}" \
      -db ${blast_db} \
      -max_hsps 1 \
      -max_target_seqs 1 \
      -outfmt "6 std staxid ssciname" \
      -evalue 1e-10 \
      -num_threads ${threads} \
      > "${sample_name}".blastx.outfmt6
    done
```

---

#### RESULTS

Actually took longer than I thought it would (almost six days - essentially one day per sample):

![screencap of job runtime](https://github.com/RobertsLab/sams-notebook/raw/master/images/screencaps/20190522_metagenomics_blastx_runtime.png)

Output folder:

- [20190516_metagenomics_pgen_blastx](http://gannet.fish.washington.edu/Atumefaciens/20190516_metagenomics_pgen_blastx)

BLAST output files (Output format 6, plus taxids and scientific names):

- [MG1_pH82.blastx.outfmt6](http://gannet.fish.washington.edu/Atumefaciens/20190516_metagenomics_pgen_blastx/MG1_pH82.blastx.outfmt6)

- [MG2_pH82.blastx.outfmt6](http://gannet.fish.washington.edu/Atumefaciens/20190516_metagenomics_pgen_blastx/MG2_pH82.blastx.outfmt6)

- [MG3_pH71.blastx.outfmt6](http://gannet.fish.washington.edu/Atumefaciens/20190516_metagenomics_pgen_blastx/MG3_pH71.blastx.outfmt6)

- [MG5_pH82.blastx.outfmt6](http://gannet.fish.washington.edu/Atumefaciens/20190516_metagenomics_pgen_blastx/MG5_pH82.blastx.outfmt6)

- [MG6_pH71.blastx.outfmt6](http://gannet.fish.washington.edu/Atumefaciens/20190516_metagenomics_pgen_blastx/MG6_pH71.blastx.outfmt6)

- [MG7_pH71.blastx.outfmt6](http://gannet.fish.washington.edu/Atumefaciens/20190516_metagenomics_pgen_blastx/MG7_pH71.blastx.outfmt6)


I'll tackle some analysis of this data in a different notebook entry.
