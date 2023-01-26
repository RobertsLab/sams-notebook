---
layout: post
title: Data Wrangling - P.acuta Genome GFF to GTF Conversion Using gffread
date: '2023-01-26 07:42'
tags: 
  - gffread
  - GFF
  - GTF
  - Pocillopora acuta
  - jupyter
categories: 
  - Miscellaneous
---
As part of getting [these three coral species genome files](https://github.com/RobertsLab/resources/issues/1571) (GitHub Issue) added to our [Lab Handbook Genomic Resources page](https://robertslab.github.io/resources/Genomic-Resources/), I will index the _P.acuta_ genome file using [`HISAT2`](https://daehwankimlab.github.io/hisat2/), but need a GTF file to also identify exon/intro splice sites. Since a GTF file is not available, but a GFF file is, I needed to convert the GFF to GTF. Used `gffread` to do this on my computer. Process is documented in Jupyter Notebook linked below.

Jupyter Notebook (GitHub):

https://github.com/RobertsLab/code/blob/master/notebooks/sam/20230126-pacu-gff_to_gtf.ipynb

Jupyter Notebook (NBviewier):

https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230126-pacu-gff_to_gtf.ipynb


<iframe src="https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230126-pacu-gff_to_gtf.ipynb" width="100%" height="1000" scrolling="yes"></iframe>

---

#### RESULTS

Output folder:

- []()

