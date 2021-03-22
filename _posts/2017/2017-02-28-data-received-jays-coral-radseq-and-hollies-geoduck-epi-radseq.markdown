---
author: kubu4
comments: true
date: 2017-02-28 00:29:16+00:00
layout: post
slug: data-received-jays-coral-radseq-and-hollies-geoduck-epi-radseq
title: Data Received - Jay's Coral RADseq and Hollie's Geoduck Epi-RADseq
wordpress_id: 2481
author:
  - kubu4
categories:
  - Miscellaneous
tags:
  - Anthopleura elegantissima
  - docker
  - geoduck
  - jupyter notebook
  - Panopea generosa
  - Porites astreoides
  - wget
---

Jay received notice from [UC Berkeley](https://qb3.berkeley.edu/gsl/) that the sequencing data from [his coral RADseq](http://onsnetwork.org/jdimond/2017/02/14/rad-library-prep/) was ready. In addition, [the sequencing contains some epiRADseq data from samples provided by Hollie Putnam](https://hputnam.github.io/Putnam_Lab_Notebook/Geoduck_Larval_DNA_Extractions/). See his notebook for multiple links that describe library preparation (indexing and barcodes), sample pooling, and species breakdown.

For quickest reference, here's Jay's spreadsheet with virtually all the sample/index/barcode/pooling info (Google Sheet): [ddRAD/EpiRAD_Jan_16](https://docs.google.com/spreadsheets/d/1zS7lGuESGLiRUs8qdDf1aYxaYBmNHnwx51YtsAs83O4/edit#gid=1930556752)

I've downloaded both the demultiplexed and non-demultiplexed data, verified data integrity by generating and comparing MD5 checksums, copied the files to each of the three species folders on owl/nightingales that were sequenced (_Panopea generosa_, _Anthopleura elegantissima_, _Porites astreoides_), generated and compared MD5 checksums for the files in their directories on owl/nightingales, and created/updated the readme files in each respective folder.




Data management is detailed in the Jupyter notebook below. The notebook is embedded in this post, but it may be easier to view on GitHub (linked below).

Readme files were updated outside of the notebook.

Jupyter notebook (GitHub): [20170227_docker_jay_ngs_data_retrieval.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20170227_docker_jay_ngs_data_retrieval.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=65febaac781eab05c13d38bbd7f1b6cfb2c5dc3d&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f363566656261616337383165616230356331336433386262643766316236636662326335646333642f6a7570797465725f6e62732f73616d2f32303137303232375f646f636b65725f6a61795f6e67735f646174615f72657472696576616c2e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20170227_docker_jay_ngs_data_retrieval.ipynb&repository_id=13746500#56f5c595-c4e5-419d-9c38-78290d1996f1" width="100%" height="2000" scrolling="yes"></iframe>
