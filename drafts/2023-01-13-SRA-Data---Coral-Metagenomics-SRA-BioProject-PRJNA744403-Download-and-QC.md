---
layout: post
title: SRA Data - Coral Metagenomics SRA BioProject PRJNA744403 Download and QC
date: '2023-01-13 10:14'
tags: 
  - PRJNA744403
  - SRA
  - NCBI
  - fastp
  - FastQC
  - MultiQC
  - coral
  - metagenomics
categories: 
  - Miscellaneous
---
Per [this GitHub Issue](https://github.com/RobertsLab/resources/issues/1569), Steven wanted me to download all of the SRA data (RNA-seq and WGBS-seq) from [NCBI BioProject PRJNA744403](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA744403) and run QC on the data.

Prior to QC, I had to get the data:

1. Acquired accessions list file:

    ![Screenshot of NCBI BioProject PRJNA744403 page showing dropdown menu to generate SRA accessions list file](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20230113-coral-metagenomics-PRJNA744403-sra_accessions_list-screenshot.png?raw=true)

    Resulting file looks like this:

    ```
    Run accession
    SRR15101687
    SRR15101688
    SRR15101689
    SRR15101690
    SRR15101691
    SRR15101692
    SRR15101693
    SRR15101694
    SRR15101695
    ```

2. Downloaded associated SRA runs (done on Mox using a build node):

    ```shell
    time \
    /gscratch/srlab/programs/sratoolkit.2.11.3-centos_linux64/bin/prefetch \
    --option-file /gscratch/srlab/sam/data/NCBI-BioProject-PRJNA744403-coral_metagenomics/SraAccList-PRJNA744403.txt
    ```

    NOTE: This puts all files in this directory:

    ```
    /gscratch/srlab/data/ncbi/sra
    ```

    Took a bit over 2hrs to download all the files:

    ![Screenshot showing execution time of 168mins 27.9 seconds to download SRA files for BioProject PRJNA744403](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20230113-coral-metagenomics-PRJNA744403-sra_download-runtime-screenshot.png?raw=true)

3. Converted `.sra` files to FastQ (done on Mox using a build node):

    ```shell
    for file in *.sra; do /gscratch/srlab/programs/sratoolkit.2.11.3-centos_linux64/bin/fasterq-dump "${file}"; done
    ```

[`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/), [`fastp`](https://github.com/OpenGene/fastp), and [`MultiQC`](https://multiqc.info/) were run on Mox.

SBATCH script (GitHub):

- [202230113-coral-fastqc-fastp-multiqc-PRJNA744403.sh]()


---

#### RESULTS

Output folder:

- []()

