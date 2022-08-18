---
layout: post
title: Data Wrangling - Convert S.namaycush NCBI GFF to genes-only BED file for Use in Ballgown Analysis
date: '2022-08-18 07:39'
tags: 
  - lake trout
  - GFFutils
  - jupyter
  - ballgown
  - Salvelinus namaycush
categories: 
  - Miscellaneous
---
In preparation for isoform identificaiton/quantification in _S.namaycush_ RNAseq data, Ballgown will need a genes-only BED file. To generate, I used [GFFutils](https://gffutils.readthedocs.io/en/latest/) to extract only genes from the NCBI GFF: `GCF_016432855.1_SaNama_1.0_genomic.gff`. All code was documented in the following Jupyter Notebook.

Jupyter Notebook

- [GitHub](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20220818-snam-gff_to_bed-genes.ipynb)

- [NBViewer](https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20220818-snam-gff_to_bed-genes.ipynb)


<iframe src="https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20220818-snam-gff_to_bed-genes.ipynb" width="100%" height="1000" scrolling="yes"></iframe>

---

#### RESULTS

Output folder:

- []()

