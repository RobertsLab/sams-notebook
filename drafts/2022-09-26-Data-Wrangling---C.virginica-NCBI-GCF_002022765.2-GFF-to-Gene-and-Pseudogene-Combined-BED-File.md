---
layout: post
title: Data Wrangling - C.virginica NCBI GCF_002022765.2 GFF to Gene and Pseudogene Combined BED File
date: '2022-09-26 13:52'
tags: 
  - jupyter
  - Crassostrea virginica
  - Eastern oyster
  - GCF_002022765.2
  - gff
  - gffutils
categories: 
  - Miscellaneous
---
Working on the [CEABIGR project](https://github.com/sr320/ceabigr), I was preparing to make a gene expression file to use in [CIRCOS](https://github.com/sr320/ceabigr/issues/70) (GitHub Issue) when I realized that the [Ballgown gene expression file](https://github.com/epigeneticstoocean/2018_L18-adult-methylation/blob/main/data/whole_gx_table.csv) (CSV; GitHub) had more genes than the [C.virginica genes BED file](https://eagle.fish.washington.edu/Cvirg_tracks/C_virginica-3.0_Gnomon_genes.bed) we were using. After some sleuthing, I discovered that the discrepancy was caused by the lack of pseudogenes in the genes BED file I was using. Although it might not really have any impact on things, I thought it would still be prudent to have a BED file that completely matched all of the genes in the Ballgown gene expression file. Plus, having the pseudogenes might be of longterm usefulness if we we ever decide to evalute the role of long non-coding RNAs (lncRNAs) in this project.

So, I created a new BED file containing genes _and_ pseudogenes.

It's all documented in the following Jupyter Notebook:

- GitHub: [20220926_cvir_gff-to-bed-genes_and_pseudogenes.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20220926_cvir_gff-to-bed-genes_and_pseudogenes.ipynb)

- NBviewer: [20220926_cvir_gff-to-bed-genes_and_pseudogenes.ipynb](https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20220926_cvir_gff-to-bed-genes_and_pseudogenes.ipynb)


<iframe src="https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20220926_cvir_gff-to-bed-genes_and_pseudogenes.ipynb" width="100%" height="2000" scrolling="yes"></iframe>


---

#### RESULTS

Output folder:

- []()

