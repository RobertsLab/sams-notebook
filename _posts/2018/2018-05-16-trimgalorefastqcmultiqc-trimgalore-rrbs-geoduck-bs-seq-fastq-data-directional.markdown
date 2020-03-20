---
author: kubu4
comments: true
date: 2018-05-16 23:49:49+00:00
layout: post
slug: trimgalorefastqcmultiqc-trimgalore-rrbs-geoduck-bs-seq-fastq-data-directional
title: TrimGalore/FastQC/MultiQC – TrimGalore! RRBS Geoduck BS-seq FASTQ data (directional)
wordpress_id: 3358
author:
  - kubu4
categories:
  - Miscellaneous
tags:
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

[Earlier this week, I ran TrimGalore!, but set the trimming, incorrectly - due to a copy/paste mistake, as `--non-directional`](https://robertslab.github.io/sams-notebook/2018/05/16/trimgalorefastqcmultiqc-trimgalore-rrbs-geoduck-bs-seq-fastq-data.html), so I re-ran with the correct settings.

[Steven requested that I trim the Geoduck RRBS libraries](https://github.com/RobertsLab/resources/issues/260) that we have, in preparation to run them through Bismark.

These libraries were originally created by Hollie Putnam using the TruSeq DNA Methylation Kit (Illumina):





  * [project_juvenile_geoduck_OA/Sample_Processing (GitHub)](https://github.com/hputnam/project_juvenile_geoduck_OA/tree/master/Sample_Processing)



All analysis is documented in a Jupyter Notebook; see link below.

Overview of process:



  1. Run TrimGalore! with `--paired` and `--rrbs` settings.



  2. Run FastQC and MultiQC on trimmed files.



  3. Copy all data to owl (see Results below for link).



  4. Confirm data integrity via MD5 checksums.






Jupyter Notebook:





  * [20180516_roadrunner_geoduck_RRBS_trimming.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20180516_roadrunner_geoduck_RRBS_trimming.ipynb) (GitHub)





* * *





##### Results:





###### TrimGalore! output folder:







  * [20180516_geoduck_trimgalore_rrbs](https://owl.fish.washington.edu/Athaliana/20180516_geoduck_trimgalore_rrbs/)





###### FastQC output folder:







  * [20180516_geoduck_trimgalore_rrbs/20180514_geoduck_trimmed_fastqc/](https://owl.fish.washington.edu/Athaliana/20180516_geoduck_trimgalore_rrbs/20180516_geoduck_trimmed_fastqc)





###### MultiQC output folder:







  * [20180516_geoduck_trimgalore_rrbs/20180516_geoduck_trimmed_fastqc/multiqc_data](https://owl.fish.washington.edu/Athaliana/20180516_geoduck_trimgalore_rrbs/20180516_geoduck_trimmed_fastqc/multiqc_data)





###### MultiQC report (HTML):







  * [multiqc_report.html](https://owl.fish.washington.edu/Athaliana/20180516_geoduck_trimgalore_rrbs/20180516_geoduck_trimmed_fastqc/multiqc_data/multiqc_report.html)
