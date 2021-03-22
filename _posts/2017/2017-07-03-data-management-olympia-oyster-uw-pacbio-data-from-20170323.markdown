---
author: kubu4
comments: true
date: 2017-07-03 20:29:53+00:00
layout: post
slug: data-management-olympia-oyster-uw-pacbio-data-from-20170323
title: Data Management - Olympia oyster UW PacBio Data from 20170323
wordpress_id: 2614
author:
  - kubu4
categories:
  - Olympia Oyster Genome Sequencing
tags:
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
  - PacBio
---

Due to other priorities, getting [this PacBio data](https://github.com/RobertsLab/project-olympia.oyster-genomic/wiki/Genome-sequencing-December-2016-(UW-PacBio)) sorted and prepped for our [next gen sequencing data management plan (DMP)(https://github.com/sr320/LabDocs/wiki/Data-Management#ngs-data-management-plan) was put on the back burner. I finally got around to this, but it wasn't all successful.

The primary failure is the inability to get the original data file archived as a gzipped tarball. The problem lies in loss of connection to Owl during the operation. This connection issue was recently noticed by Sean in his dealings with Hyak (mox). According to Sean, the Hyak (mox) people or UW IT ran some tests of their own on this connection and their results suggested that the connection issue is related to a network problem in FTR, and is not related to Owl itself. Whatever the case is, we need to have this issue addressed sometime soon...

Anyway, below is the Jupyter notebook that demonstrates the file manipulations I used to find, copy, rename, and verify data integrity of all the FASTQ files from this sequencing run.

Next up is to get these FASTQ files added to the DMP spreadsheets.

Jupyter notebook (GitHub): [20170622_oly_pacbio_data_management.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20170622_oly_pacbio_data_management.ipynb)



I've also embedded the notebook below, but it might be easier to view at the GitHub link provided above.

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=62a6072a6c454aa59120a25fddbadc43ba74ec82&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f363261363037326136633435346161353931323061323566646462616463343362613734656338322f6a7570797465725f6e62732f73616d2f32303137303632325f6f6c795f70616362696f5f646174615f6d616e6167656d656e742e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20170622_oly_pacbio_data_management.ipynb&repository_id=13746500&repository_type=Repository#56cc1c12-916d-4386-89ce-97b88c1512e4" width="100%" height="2000" scrolling="yes"></iframe>
