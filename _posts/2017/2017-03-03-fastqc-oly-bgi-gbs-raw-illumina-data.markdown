---
author: kubu4
comments: true
date: 2017-03-03 00:00:12+00:00
layout: post
slug: fastqc-oly-bgi-gbs-raw-illumina-data
title: FASTQC - Oly BGI GBS Raw Illumina Data
wordpress_id: 2497
author:
  - kubu4
categories:
  - Genotype-by-sequencing at BGI
tags:
  - BGI
  - FASTQC
  - GBS
  - genotype-by-sequencing
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
---

In getting things prepared for [the manuscript we're writing about the Olympia oyster genotype-by-sequencing data from BGI](https://www.authorea.com/users/4974/articles/149442), I felt we needed to provide a [FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) analysis of the raw data (since these two files are what [we submitted to the NCBI short read archive](http://onsnetwork.org/kubu4/wp-admin/post.php?post=2474&action=edit)) to provide support for the [Technical Validation section](https://github.com/kubu4/paper_oly_gbs/blob/master/technical_validation.md) of the manuscript.

Below, is the Jupyter notebook I used to run the FastQC analysis on the two files. I've embedded for quick viewing, but it might be easier to view the notebook via the GitHub link.



Results:

Well, I realized that running FastQC on the raw data might not reveal anything all too helpful. The reason for this is that the adaptor and barcode sequences are still present on all the reads. This will lead to over-representation of these sequences in all of the samples, which, in turn, will skew FastQC's intepretation of the read qualities. For comparison, I'll run FastQC on the demultiplexed data provided by BGI and see what the FastQC report looks like on trimmed data.

However, I'll need to discuss with Steven about whether or not providing the FastQC analysis is worthwhile as part of the "technical validation" aspect of the manuscript. I guess it can't hurt to provide it, but I'm not entirely sure that the FastQC report provides any real information regarding the quality of the sequencing reads that we received...



Jupyter notebook (GitHub): [20170301_docker_fastqc_nondemultiplexed_bgi_oly_gbs.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20170301_docker_fastqc_nondemultiplexed_bgi_oly_gbs.ipynb)
<iframe src="https://render.githubusercontent.com/view/ipynb?commit=dbea27dfef626a1da60c6b26b6102332b4ffc3e6&enc;_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f646265613237646665663632366131646136306336623236623631303233333262346666633365362f6a7570797465725f6e62732f73616d2f32303137303330315f646f636b65725f6661737471635f6e6f6e64656d756c7469706c657865645f6267695f6f6c795f6762732e6970796e62&nwo;=sr320%2FLabDocs&path;=jupyter_nbs%2Fsam%2F20170301_docker_fastqc_nondemultiplexed_bgi_oly_gbs.ipynb&repository;_id=13746500#47abd8fd-05f3-4142-941a-082b11afb242" width="100%" height="2000" scrolling="yes"></iframe>
