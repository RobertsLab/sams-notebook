---
author: kubu4
comments: true
date: 2017-03-07 17:46:56+00:00
layout: post
slug: fastqc-oly-bgi-gbs-raw-illumina-data-demultiplexed
title: FASTQC - Oly BGI GBS Raw Illumina Data Demultiplexed
wordpress_id: 2506
author:
  - kubu4
categories:
  - Genotype-by-sequencing at BGI
tags:
  - BGI
  - docker
  - FASTQC
  - GBS
  - genotype-by-sequencing
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
  - ostrich
---

[Last week, I ran the two raw FASTQ files through FastQC](https://robertslab.github.io/sams-notebook/2017/03/02/fastqc-oly-bgi-gbs-raw-illumina-data.html). As expected, FastQC detected "errors". These errors are due to the presence of adapter sequences, barcodes, and the use of a restriction enzyme (ApeKI) in library preparation. In summary, it's not surprising that FastQC was not please with the data because it's expecting a "standard" library prep that's already been trimmed and demultiplexed.

However, just for comparison, I ran the demultiplexed files through FastQC. The Jupyter notebook is linked (GitHub) and embedded below. I recommend viewing the Jupyter notebook on GitHub for easier viewing.

Results:

Pretty much the same, but with slight improvements due to removal of adapter and barcode sequences. The restriction site still leads to FastQC to report errors, which is expected.

Links to all of the FastQC output files are linked at the bottom of the notebook.

Jupyter notebook (GitHub): [20170306_docker_fastqc_demultiplexed_bgi_oly_gbs.ipynb
](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20170306_docker_fastqc_demultiplexed_bgi_oly_gbs.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=c302f2e650ec50453a2a4c1f00540a9bb3672e13&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f633330326632653635306563353034353361326134633166303035343061396262333637326531332f6a7570797465725f6e62732f73616d2f32303137303330365f646f636b65725f6661737471635f64656d756c7469706c657865645f6267695f6f6c795f6762732e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20170306_docker_fastqc_demultiplexed_bgi_oly_gbs.ipynb&repository_id=13746500#375aacff-7cdf-48f6-b3ec-5c215f69d56d" width="100%" height="2000" scrolling="yes"></iframe>
