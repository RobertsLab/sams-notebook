---
author: kubu4
comments: true
date: 2018-04-15 21:33:44+00:00
layout: post
slug: assembly-stats-quast-stats-for-geoduck-sparseassembler-job-from-20180405
title: Assembly Stats - Quast Stats for Geoduck SparseAssembler Job from 20180405
wordpress_id: 3264
author:
  - kubu4
categories:
  - Geoduck Genome Sequencing
tags:
  - geoduck
  - Panopea generosa
  - QUAST
---

[The geoduck genome assembly started 20180405](https://robertslab.github.io/sams-notebook/2018/04/05/genome-assembly-sparseassembler-geoduck-genomic-data-kmer101.html) completed this weekend.

This assembly utilized the BGI data and all of the Illumina project data (NMP and NovaSeq) with a kmer 101 setting.

I ran Quast to gather some assembly stats, using the following command:


    
    <code>python /home/sam/software/quast-4.5/quast.py -t 24 /mnt/owl/Athaliana/20180405_sparseassembler_kmer101_geoduck/Contigs.txt</code>





##### Results:



Quast output folder: [results_2018_04_15_13_45_03/](https://owl.fish.washington.edu/Athaliana/quast_results/results_2018_04_15_13_45_03/)

Quast report (HTML): [results_2018_04_15_13_45_03/report.html](https://owl.fish.washington.edu/Athaliana/quast_results/results_2018_04_15_13_45_03/report.html)

I've embedded the Quast HTML report below, but it may be easier to view by using the link above.

<iframe src="https://owl.fish.washington.edu/Athaliana/quast_results/results_2018_04_15_13_45_03/report.html" width="100%" height="2000" scrolling="yes"></iframe>
