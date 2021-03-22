---
author: kubu4
comments: true
date: 2018-04-09 22:21:59+00:00
layout: post
slug: fastqcmultiqc-c-virginica-mbd-bs-seq-data
title: FastQC/MultiQC - C. virginica MBD BS-seq Data
wordpress_id: 3219
author:
  - kubu4
categories:
  - Miscellaneous
tags:
  - BS-seq
  - Crassostrea virginica
  - Eastern oyster
  - FASTQC
  - MBD-Seq
  - multiqc
  - ZymoResearch
---

Per [Steven's GitHub Issues request](https://github.com/RobertsLab/resources/issues/217), I ran FastQC on the Eastern oyster MBD bisulfite sequencing data [we recently got back from ZymoResearch.](https://robertslab.github.io/sams-notebook/2018/03/29/data-recived-crassostrea-virginica-mbd-bs-seq-from-zymoresearch.html)

Ran FastQC locally with the following script: [20180409_fastqc_Cvirginica_MBD.sh](https://owl.fish.washington.edu/Athaliana/20180409_fastqc_Cvirginica_MBD/20180409_fastqc_Cvirginica_MBD.sh)


    
    <code>
    #!/bin/bash
    /home/sam/software/FastQC/fastqc \
    --threads 18 \
    --outdir /home/sam/20180409_fastqc_Cvirginica_MBD \
    /mnt/owl/nightingales/C_virginica/zr2096_10_s1_R1.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_10_s1_R2.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_1_s1_R1.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_1_s1_R2.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_2_s1_R1.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_2_s1_R2.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_3_s1_R1.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_3_s1_R2.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_4_s1_R1.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_4_s1_R2.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_5_s1_R1.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_5_s1_R2.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_6_s1_R1.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_6_s1_R2.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_7_s1_R1.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_7_s1_R2.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_8_s1_R1.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_8_s1_R2.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_9_s1_R1.fastq.gz \
    /mnt/owl/nightingales/C_virginica/zr2096_9_s1_R2.fastq.gz
    </code>



MultiQC was then run on the FastQC output files.

All files were moved to Owl after the jobs completed.



##### Results:



FastQC Output folder: [20180409_fastqc_Cvirginica_MBD/](https://owl.fish.washington.edu/Athaliana/20180409_fastqc_Cvirginica_MBD/)

MultiQC Output folder: [20180409_fastqc_Cvirginica_MBD/multiqc_data/](https://owl.fish.washington.edu/Athaliana/20180409_fastqc_Cvirginica_MBD/multiqc_data/)

MultiQC report (HTML): [20180409_fastqc_Cvirginica_MBD/multiqc_data/multiqc_report.html](https://owl.fish.washington.edu/Athaliana/20180409_fastqc_Cvirginica_MBD/multiqc_data/multiqc_report.html)

Everything looks good to me.

Steven's interested in seeing what the trimmed output would look like (and, how it would impact mapping efficiencies). Will initiate trimming.

See the GitHub issue linked above for the full discussion.

<iframe src="https://owl.fish.washington.edu/Athaliana/20180409_fastqc_Cvirginica_MBD/multiqc_data/multiqc_report.html" width="100%" height="2000" scrolling="yes"></iframe>
