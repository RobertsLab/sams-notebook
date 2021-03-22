---
author: kubu4
comments: true
date: 2015-05-07 05:27:47+00:00
layout: post
slug: bioinformatics-trimmomaticfastqc-on-c-gigas-larvae-oa-ngs-data
title: Bioinformatics - Trimmomatic/FASTQC on C.gigas Larvae OA NGS Data
wordpress_id: 1322
author:
  - kubu4
categories:
  - Crassostrea gigas larvae OA (2011) bisulfite sequencing
tags:
  - bioinformatics
  - BS-seq
  - Crassostrea gigas
  - FASTQC
  - graphs
  - ipython notebook
  - jupyter notebook
  - Pacific oyster
  - Trimmomatic
  - troubleshooting
---

In another troubleshooting attempt for this problematic BS-seq Illumina data, I'm going to use Trimmomatic to remove the first 39 bases of each read. This is due to the fact that even [after the previous quality trimming with Trimmomatic](https://robertslab.github.io/sams-notebook/2015/04/16/quality-trimming-c-gigas-larvae-oa-bs-seq-data.html), the first 39 bases still showed inconsistent quality:

![](https://eagle.fish.washington.edu/Arabidopsis/20150414_trimmed_2212_lane2_CTTGTA_L002_R1_001_fastqc/Images/per_base_sequence_content.png)(http://eagle.fish.washington.edu/Arabidopsis/20150414_trimmed_2212_lane2_CTTGTA_L002_R1_001_fastqc/Images/per_base_sequence_content.png)



Ran Trimmomatic on just a single data set to try things out: [2212_lane2_CTTGTA_L002_R1_001.fastq.gz](https://owl.fish.washington.edu/nightingales/C_gigas/2212_lane2_CTTGTA_L002_R1_001.fastq.gz)

Notebook Viewer: [20150506_Cgigas_larvae_OA_trimmomatic_FASTQC](https://nbviewer.ipython.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20150506_Cgigas_larvae_OA_trimmomatic_FASTQC.ipynb)

Jupyter (IPython) notebook: [20150506_Cgigas_larvae_OA_trimmomatic_FASTQC.ipynb](https://eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20150506_Cgigas_larvae_OA_trimmomatic_FASTQC.ipynb)

<iframe src="https://nbviewer.ipython.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20150506_Cgigas_larvae_OA_trimmomatic_FASTQC.ipynb" width="100%" height="2000" scrolling="yes"></iframe>

Results:

Trimmed FASTQ: [20150506_trimmed_2212_lane2_CTTGTA_L002_R1_001.fastq.gz](https://eagle.fish.washington.edu/Arabidopsis/20150506_trimmed_2212_lane2_CTTGTA_L002_R1_001.fastq.gz)

FASTQC Report: [20150506_trimmed_2212_lane2_CTTGTA_L002_R1_001_fastqc.html](https://eagle.fish.washington.edu/Arabidopsis/20150506_trimmed_2212_lane2_CTTGTA_L002_R1_001_fastqc.html)

![](https://eagle.fish.washington.edu/Arabidopsis/20150506_trimmed_2212_lane2_CTTGTA_L002_R1_001_fastqc/Images/per_base_sequence_content.png)(http://eagle.fish.washington.edu/Arabidopsis/20150506_trimmed_2212_lane2_CTTGTA_L002_R1_001_fastqc/Images/per_base_sequence_content.png)

You can see how flat the newly trimmed data is (which is what one would expect).

Steven will take this trimmed dataset and try additional mapping with it to see if removal of the first 39 bases will improve the mapping.
