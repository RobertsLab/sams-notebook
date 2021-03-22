---
author: kubu4
comments: true
date: 2018-02-05 17:29:00+00:00
layout: post
slug: novaseq-assembly-trimmed-geoduck-novaseq-with-meraculous
title: NovaSeq Assembly - Trimmed Geoduck NovaSeq with Meraculous
wordpress_id: 3086
author:
  - kubu4
categories:
  - Geoduck Genome Sequencing
tags:
  - assembly
  - geoduck
  - Illumina
  - kmer
  - kmer genie
  - meraculous
  - NovaSeq
  - Panopea generosa
  - roadrunner
---

Attempted to use [Meraculous](https://jgi.doe.gov/data-and-tools/meraculous/) to assemble the [trimmed geoduck NovaSeq data](https://robertslab.github.io/sams-notebook/2018/01/25/adapter-trimming-and-fastqc-illumina-geoduck-novaseq-data.html).

Here's the [Meraculous manual (PDF)(https://1ofdmq2n8tc36m6i46scovo2e.wpengine.netdna-cdn.com/wp-content/uploads/2014/12/Manual.pdf).

After a bunch of various issues (running out of hard drive space - multiple times, config file issues, typos), I've finally given up on running meraculous. It failed, again, saying it couldn't find a file in a directory that _meraculous created_! I've emailed the authors and if they have an easy fix, I'll implement it and see what happens.

Anyway, it's all documented in the Jupyter Notebook below.

One good thing came out of all of it is that I had to run [kmergenie]() to identify an appopriate kmer size to use for assembly, as well as estimated genome size (this info is needed for both meraculous and SOAPdeNovo (which I'll be trying next)):

**kmergenie output folder**: [https://owl.fish.washington.edu/Athaliana/20180125_geoduck_novaseq/20180206_kmergenie/](http://owl.fish.washington.edu/Athaliana/20180125_geoduck_novaseq/20180206_kmergenie/)
kmergenie HTML report (doesn't display histograms for some reason): [20180206_kmergenie/histograms_report.html](https://owl.fish.washington.edu/Athaliana/20180125_geoduck_novaseq/20180206_kmergenie/histograms_report.html)
**kmer size**: 117
**Est. genome size**: 2.17Gbp

**Jupyter Notebook (GitHub)**: [20180205_roadrunner_meraculous_geoduck_novaseq.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20180205_roadrunner_meraculous_geoduck_novaseq.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=4776dd87980bb1e99159dff31429a5a9deac9f48&enc;_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f343737366464383739383062623165393931353964666633313432396135613964656163396634382f6a7570797465725f6e62732f73616d2f32303138303230355f726f616472756e6e65725f6d65726163756c6f75735f67656f6475636b5f6e6f76617365712e6970796e62&nwo;=sr320%2FLabDocs&path;=jupyter_nbs%2Fsam%2F20180205_roadrunner_meraculous_geoduck_novaseq.ipynb&repository;_id=13746500&repository;_type=Repository#87ce7773-2332-4116-897c-83334e49961b" width="100%" height="2000" scrolling="yes"></iframe>
