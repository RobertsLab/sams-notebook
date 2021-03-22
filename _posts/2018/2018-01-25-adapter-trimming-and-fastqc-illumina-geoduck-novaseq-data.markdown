---
author: kubu4
comments: true
date: 2018-01-25 16:01:22+00:00
layout: post
slug: adapter-trimming-and-fastqc-illumina-geoduck-novaseq-data
title: Adapter Trimming and FASTQC - Illumina Geoduck Novaseq Data
wordpress_id: 3078
author:
  - kubu4
categories:
  - Geoduck Genome Sequencing
tags:
  - FASTQC
  - geoduck
  - Illumina
  - multiqc
  - NovaSeq
  - Panopea generosa
  - trim galore
  - trimming
---

We would like to get an assembly of the geoduck NovaSeq data that Illumina provided us with.

[Steven previously ran the raw data through FASTQC](https://sr320.github.io/Illumina-Summary/) and there was a significant amount of adapter contamination (up to 44% in some libraries) present ([see his FASTQC report here](http://owl.fish.washington.edu/halfshell/bu-alanine-wd/17-09-15b/multiqc_report.html)).

So, I trimmed them using TrimGalore and re-ran FASTQC on them.

This required two rounds of trimming using the "auto-detect" feature of Trim Galore.





  * Round 1: remove NovaSeq adapters


  * Round 2: remove standard Illumina adapters



See Jupyter notebook below for the gritty details.



##### Results:



All data for this NovaSeq assembly project can be found here: [https://owl.fish.washington.edu/Athaliana/20180125_geoduck_novaseq/](http://owl.fish.washington.edu/Athaliana/20180125_geoduck_novaseq/).

Round 1 Trim Galore reports: [20180125_trim_galore_reports/](https://owl.fish.washington.edu/Athaliana/20180125_geoduck_novaseq/20180125_trim_galore_reports/]
Round 1 FASTQC: [20180129_trimmed_multiqc_fastqc_01](https://owl.fish.washington.edu/Athaliana/20180125_geoduck_novaseq/20180129_trimmed_multiqc_fastqc_01/)
Round 1 FASTQC MultiQC overview: [20180129_trimmed_multiqc_fastqc_01/multiqc_report.html](https://owl.fish.washington.edu/Athaliana/20180125_geoduck_novaseq/20180129_trimmed_multiqc_fastqc_01/multiqc_report.html)

<iframe src="https://owl.fish.washington.edu/Athaliana/20180125_geoduck_novaseq/20180129_trimmed_multiqc_fastqc_01/multiqc_report.html" width="100%" height="2000" scrolling="yes"></iframe>



* * *



  


  


  



Round 2 Trim Galore reports: [20180125_geoduck_novaseq/20180205_trim_galore_reports/](https://owl.fish.washington.edu/Athaliana/20180125_geoduck_novaseq/20180205_trim_galore_reports/)
Round 2 FASTQC: [20180205_trimmed_fastqc_02/](https://owl.fish.washington.edu/Athaliana/20180125_geoduck_novaseq/20180205_trimmed_fastqc_02/)
Round 2 FASTQC MultiQC overview: [20180205_trimmed_multiqc_fastqc_02/multiqc_report.html](https://owl.fish.washington.edu/Athaliana/20180125_geoduck_novaseq/20180205_trimmed_multiqc_fastqc_02/multiqc_report.html)

<iframe src="https://owl.fish.washington.edu/Athaliana/20180125_geoduck_novaseq/20180205_trimmed_multiqc_fastqc_02/multiqc_report.html" width="100%" height="2000" scrolling="yes"></iframe>

  


  


  



For the astute observer, you might notice the "Per Base Sequence Content" generates a "Fail" warning for all samples. Per [the FASTQC help](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/3%20Analysis%20Modules/4%20Per%20Base%20Sequence%20Content.html), this is likely expected (due to the fact that NovaSeq libraries are prepared using transposases) and doesn't have any downstream impacts on analyses.

  


  


  



Jupyter Notebook (GitHub): [20180125_roadrunner_trimming_geoduck_novaseq.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20180125_roadrunner_trimming_geoduck_novaseq.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=4776dd87980bb1e99159dff31429a5a9deac9f48&enc;_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f343737366464383739383062623165393931353964666633313432396135613964656163396634382f6a7570797465725f6e62732f73616d2f32303138303132355f726f616472756e6e65725f7472696d6d696e675f67656f6475636b5f6e6f76617365712e6970796e62&nwo;=sr320%2FLabDocs&path;=jupyter_nbs%2Fsam%2F20180125_roadrunner_trimming_geoduck_novaseq.ipynb&repository;_id=13746500&repository;_type=Repository#13978f4e-90d1-41ac-9320-cddebbb90252" width="100%" height="2000" scrolling="yes"></iframe>
