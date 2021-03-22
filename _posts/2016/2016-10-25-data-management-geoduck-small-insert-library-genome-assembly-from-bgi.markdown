---
author: kubu4
comments: true
date: 2016-10-25 21:20:50+00:00
layout: post
slug: data-management-geoduck-small-insert-library-genome-assembly-from-bgi
title: Data Management – Geoduck Small Insert Library Genome Assembly from BGI
wordpress_id: 2311
author:
  - kubu4
categories:
  - Geoduck Genome Sequencing
tags:
  - BGI
  - geoduck
  - jupyter notebook
  - Panopea generosa
---

Received another set of _Panopea generosa_ genome assembly data from BGI back in May! I neglected to create MD5 checksums, as well as a readme file for this data set! Of course, I needed some of the info that the readme file should've had and it wasn't there. So, here's the skinny...

It's data assembled from the small insert libraries they created for this project.

All data is stored here: [https://owl.fish.washington.edu/P_generosa_genome_assemblies_BGI/20160512/](http://owl.fish.washington.edu/P_generosa_genome_assemblies_BGI/20160512/)

They've provided a [Genome Survey (PDF)(https://owl.fish.washington.edu/P_generosa_genome_assemblies_BGI/20160512/20160512_F15FTSUSAT0328_genome_survey.pdf) that has some info about the data they've assembled. In it, is the estimated genome size:

Geoduck genome size: 2972.9 Mb

Additionally, there's a table breaking down the N50 distributions of scaffold and contig sizes.

Data management stuff was performed in a Jupyter (iPython) notebook; see below.

Jupyter Notebook: [20161025_Pgenerosa_Small_Library_Genome_Read_Counts.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20161025_Pgenerosa_Small_Library_Genome_Read_Counts.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=139b403640257229a3ad4a64de7d1678ca451f04&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f313339623430333634303235373232396133616434613634646537643136373863613435316630342f6a7570797465725f6e62732f73616d2f32303136313032355f5067656e65726f73615f536d616c6c5f4c6962726172795f47656e6f6d655f526561645f436f756e74732e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20161025_Pgenerosa_Small_Library_Genome_Read_Counts.ipynb&repository_id=13746500#9dceaa19-effc-47a5-80fd-58b794d4e05a" width="100%" height="2000" scrolling="yes"></iframe>
