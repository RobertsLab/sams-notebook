---
author: kubu4
comments: true
date: 2016-04-28 05:40:12+00:00
layout: post
slug: data-management-o-lurida-raw-bgi-gbs-fastq-data
title: Data Management - O.lurida Raw BGI GBS FASTQ Data
wordpress_id: 2099
author:
  - kubu4
categories:
  - Genotype-by-sequencing at BGI
  - Olympia oyster reciprocal transplant
tags:
  - GBS
  - genotype-by-sequencing
  - ipython notebook
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
---

BGI had previously supplied us with demultiplexed GBS FASTQ files. However, they had not provided us with the information/data on how those files were created. I contacted them and they've given us the two original FASTQ files, as well as the library index file and corresponding script they used for demultiplexing all of the files. The Jupyter (iPython) notebook below updates our [checksum](https://owl.fish.washington.edu/nightingales/O_lurida/20160223_gbs/checksums.md5) and [readme](http://owl.fish.washington.edu/nightingales/O_lurida/20160223_gbs/readme.md) files in our server directory that's hosting the files: [http://owl.fish.washington.edu/nightingales/O_lurida/20160223_gbs/](http://owl.fish.washington.edu/nightingales/O_lurida/20160223_gbs/)

See Jupyter Notebook below for processing details.

Jupyter Notebook: [20160427_Oly_GBS_data_management.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20160427_Oly_GBS_data_management.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=84216391d94be042f3c24fcc3e214cff1a3addbf&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f383432313633393164393462653034326633633234666363336532313463666631613361646462662f6a7570797465725f6e62732f73616d2f32303136303432375f4f6c795f4742535f646174615f6d616e6167656d656e742e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20160427_Oly_GBS_data_management.ipynb&repository_id=13746500#01e52499-e9e6-4ed9-a9ea-7349bca944bb" width="100%" height="2000" scrolling="yes"></iframe>
