---
author: kubu4
comments: true
date: 2018-05-16 19:09:02+00:00
layout: post
slug: trimgalorefastqcmultiqc-trimgalore-rrbs-geoduck-bs-seq-fastq-data
title: TrimGalore/FastQC/MultiQC – TrimGalore! RRBS Geoduck BS-seq FASTQ data
wordpress_id: 3348
author:
  - kubu4
categories:
  - Miscellaneous
tags:
  - bismark
  - BS-seq
  - FASTQC
  - geoduck
  - jupyter notebook
  - multiqc
  - Panopea generosa
  - roadrunner
  - RRBS
  - TrimGalore!
---

* * *





### 20180516 - UPDATE!!





#### THIS WAS RUN WITH THE INCORRECT SETTING IN TRIMGALORE! `--non-directional`





#### WILL RE-RUN





* * *



[Steven requested that I trim the Geoduck RRBS libraries](https://github.com/RobertsLab/resources/issues/260) that we have, in preparation to run them through Bismark.

These libraries were originally created by Hollie Putnam using the TruSeq DNA Methylation Kit (Illumina):





  * [project_juvenile_geoduck_OA/Sample_Processing (GitHub)](https://github.com/hputnam/project_juvenile_geoduck_OA/tree/master/Sample_Processing)



All analysis is documented in a Jupyter Notebook; see link below.

Overview of process:



  1. Copy `EPI*` FastQ files from [owl/P_generosa](https://owl.fish.washington.edu/nightingales/P_generosa/) to roadrunner.



  2. Confirm data integrity via MD5 checksums.



  3. Run TrimGalore! with `--paired`, `--rrbs`, and `--non-directional` settings.



  4. Run FastQC and MultiQC on trimmed files.



  5. Copy all data to owl (see Results below for link).



  6. Confirm data integrity via MD5 checksums.






Jupyter Notebook:





  * [20180514_roadrunner_geoduck_RRBS_trimming.ipynb (GitHub)](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20180514_roadrunner_geoduck_RRBS_trimming.ipynb)





* * *





##### Results:





###### TrimGalore! output folder:







  * [20180514_geoduck_trimgalore_rrbs](https://owl.fish.washington.edu/Athaliana/20180514_geoduck_trimgalore_rrbs/)





###### FastQC output folder:







  * [20180514_geoduck_trimgalore_rrbs/20180514_geoduck_trimmed_fastqc/](https://owl.fish.washington.edu/Athaliana/20180514_geoduck_trimgalore_rrbs/20180514_geoduck_trimmed_fastqc)





###### MultiQC output folder:







  * [20180514_geoduck_trimgalore_rrbs/20180514_geoduck_trimmed_fastqc/multiqc_data](https://owl.fish.washington.edu/Athaliana/20180514_geoduck_trimgalore_rrbs/20180514_geoduck_trimmed_fastqc/multiqc_data)





###### MultiQC report (HTML):







  * [multiqc_report.html](https://owl.fish.washington.edu/Athaliana/20180514_geoduck_trimgalore_rrbs/20180514_geoduck_trimmed_fastqc/multiqc_data/multiqc_report.html)
