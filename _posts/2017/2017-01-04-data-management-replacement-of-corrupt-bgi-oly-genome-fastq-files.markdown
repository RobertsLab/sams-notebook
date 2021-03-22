---
author: kubu4
comments: true
date: 2017-01-04 21:46:24+00:00
layout: post
slug: data-management-replacement-of-corrupt-bgi-oly-genome-fastq-files
title: Data Management - Replacement of Corrupt BGI Oly Genome FASTQ Files
wordpress_id: 2442
categories:
  - Olympia Oyster Genome Sequencing
tags:
  - BGI
  - jupyter notebook
  - md5
  - olympia oyster
  - Ostrea lurida
---

[Previously, Sean and Steven identified two potentially corrupt FASTQ files](https://robertslab.github.io/sams-notebook/2016/11/17/data-management-tracking-o-lurida-fastq-file-corruption.html). I contacted BGI about getting replacement files and they informed me that all versions of the FASTQ files they have delivered on three separate occasions are all the same file (despite having different file names). As such, I could use one of these versions to replace the corrupt FASTQ files. So, that's what I did!

See the Jupyter Notebook below for the deets!

Jupyter Notebook (GitHub): [20170104_docker_oly_BGI_genome_corruption_solved.ipynb
](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20170104_docker_oly_BGI_genome_corruption_solved.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=d87fbcaa56a0ca5cb007139deecf73ab1a6c0704&enc;_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f643837666263616135366130636135636230303731333964656563663733616231613663303730342f6a7570797465725f6e62732f73616d2f32303137303130345f646f636b65725f6f6c795f4247495f67656e6f6d655f636f7272757074696f6e5f736f6c7665642e6970796e62&nwo;=sr320%2FLabDocs&path;=jupyter_nbs%2Fsam%2F20170104_docker_oly_BGI_genome_corruption_solved.ipynb&repository;_id=13746500#0a5b39f5-15e8-4138-8fc7-d248214e88fd" width="100%" height="2000" scrolling="yes"></iframe>
