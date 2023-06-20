---
layout: post
title: Trimming - L.staminea RNA-seq Using FastQC fastp and MultiQC on Mox
date: '2023-06-16 13:21'
tags: 
  - Leukoma staminea
  - mox
  - fastp
  - FastQC
  - little neck clam
  - RNAseq
categories: 
  - Miscellaneous
---



---

#### RESULTS

Since there were only two files, trimming was fast: ~20mins:

![Screenshot of trimming/fastqc results on Mox showing a runtime of 20mins 28secs](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20230616-lsta-fastqc-fastp-multiqc-RNAseq-runtime.png?raw=true)

Output folder:

- [](https://gannet.fish.washington.edu/Atumefaciens/20230616-lsta-fastqc-fastp-multiqc-RNAseq/)

  #### Raw FastQ MultiQC Report (HTML):

    - [20230616-lsta-fastqc-fastp-multiqc-RNAseq/raw_fastqc/multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20230616-lsta-fastqc-fastp-multiqc-RNAseq/raw_fastqc/multiqc_report.html)

  #### Trimmed FastQ MultiQC Report (HTML):

    - [20230616-lsta-fastqc-fastp-multiqc-RNAseq/trimmed/multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20230616-lsta-fastqc-fastp-multiqc-RNAseq/trimmed/multiqc_report.html)

  #### Trimmed FastQs:

    - [L-T-167_R1_001.fastp-trim.20230616.fastq.gz](https://gannet.fish.washington.edu/Atumefaciens/20230616-lsta-fastqc-fastp-multiqc-RNAseq/trimmed/L-T-167_R1_001.fastp-trim.20230616.fastq.gz) (2.8G)

      - MD5: `615d0b2b51c6619b1b81ad8d064d29ed`

    - [L-T-167_R2_001.fastp-trim.20230616.fastq.gz](https://gannet.fish.washington.edu/Atumefaciens/20230616-lsta-fastqc-fastp-multiqc-RNAseq/trimmed/L-T-167_R2_001.fastp-trim.20230616.fastq.gz) (3.0G)

      - MD5: `7ac850913e3e863b06ca7282b1261a81`
