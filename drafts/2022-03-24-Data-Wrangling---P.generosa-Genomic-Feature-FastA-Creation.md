---
layout: post
title: Data Wrangling - P.generosa Genomic Feature FastA Creation
date: '2022-03-24 14:56'
tags: 
  - Panopea generosa
  - Pacific geoduck
  - jupyter
  - jupyter notebook
  - gffutils
  - bedtools
categories: 
  - Miscellaneous
---
Steven wanted me to [generate FastA files](https://github.com/RobertsLab/resources/issues/1439) (GitHub Issue) for [_Panopea generosa_ (Pacific geoduck)](http://en.wikipedia.org/wiki/Geoduck) coding sequences (CDS), genes, and mRNAs. One of the primary needs, though, was to have an ID that could be used for downstream table joining/mapping. I ended up using a combination of [GFFutils](https://gffutils.readthedocs.io/en/v0.12.0/index.html) and [`bedtools getfasta`](https://bedtools.readthedocs.io/en/latest/content/tools/getfasta.html). I took advantage of being able to create a custom `name` column in BED files to generate the desired FastA description line having IDs that could identify, and map, CDS, genes, and mRNAs across FastAs and GFFs.

This was all documented in a Jupyter Notebook:

GitHub:

- [20220324-pgen-gffs_to_fastas.ipynb](https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20220324-pgen-gffs_to_fastas.ipynb)

NB Viewer:

- [20220324-pgen-gffs_to_fastas.ipynb](https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20220324-pgen-gffs_to_fastas.ipynb)

<iframe src="https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20220324-pgen-gffs_to_fastas.ipynb" width="100%" height="2000" scrolling="yes"></iframe>


---

#### RESULTS

Output folder:

- []()

