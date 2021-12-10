---
layout: post
title: Data Wrangling - C.virginica NCBI GCF_002022765.2 GFF to Gene BED File
date: '2021-12-09 17:19'
tags: 
  - Crassostrea virginica
  - jupyter
  - BED
  - GFF
  - GCF_002022765.2
  - Eastern oyster
categories: 
  - Miscellaneous
---
When working to [identify differentially expressed transcripts (DETs) and genes (DEGs)](https://robertslab.github.io/sams-notebook/2021/10/21/Differential-Transcript-Expression-C.virginica-Gonad-RNAseq-Using-Ballgown.html) for our [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) RNAseq/DNA methylation comparison of changes across sex and ocean acidification conditions ([https://github.com/epigeneticstoocean/2018_L18-adult-methylation](https://github.com/epigeneticstoocean/2018_L18-adult-methylation)), I realized that the DEG tables I was generating had excessive gene counts due to the fact that the analysis (and, in turn, the genome coordinates), were tied to transcripts. Thus, genes were counted multiple times due to the existence of multiple transcripts for a given gene, and the analysis didn't list gene coordinate data - only transcript coordinates.

In order to identify just gene coordinates, I needed a BED file to use for merging with the DEG data. As it turns out, we didn't have an existing BED file with just gene coordinates and gene names. So, I used [GFFutils](https://gffutils.readthedocs.io/en/v0.12.0/index.html) to extract just genes from the NCBI [GCF_002022765.2 GFF](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/022/765/GCF_002022765.2_C_virginica-3.0/) (links to NCBI directory - not directly to GFF file).

All the data wrangling is documented in the Jupyter Notebook below.


Jupyter Notebook (GitHub):

- [20211209_cvir_gff-to-bed.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20211209_cvir_gff-to-bed.ipynb)

<iframe src="https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20211209_cvir_gff-to-bed.ipynb" width="100%" height="1000" scrolling="yes"></iframe>

---

#### RESULTS

Output folder:

- []()

