---
layout: post
title: Data Wrangling - P.meandrina Genome GFF to GTF Using gffread
date: '2023-05-19 12:55'
tags: 
  - gffread
  - jupyter
  - Pocillopora meandrina
  - cora
  - E5
  - GFF
  - GTF
categories: 
  - E5
---
As part of getting _P.meandrina_ genome info added to our [Lab Handbook Genomic Resources page](https://robertslab.github.io/resources/Genomic-Resources/), I will index the _P.meandrina_ genome file (`Pocillopora_meandrina_HIv1.assembly.fasta`) using [`HISAT2`](https://daehwankimlab.github.io/hisat2/), but need a GTF file to also identify exon/intro splice sites. Since a GTF file is not available, but a GFF file is, I needed to convert the GFF to GTF. Used `gffread` to do this on my computer. Process is documented in Jupyter Notebook linked below.

Jupyter Notebook (GitHub):

[20230519-pmea-gff_to_gtf.ipynb)](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20230519-pmea-gff_to_gtf.ipynb)

Jupyter Notebook (NBviewier):

[20230519-pmea-gff_to_gtf.ipynb](https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230519-pmea-gff_to_gtf.ipynb)


<iframe src="https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230519-pmea-gff_to_gtf.ipynb" width="100%" height="1000" scrolling="yes"></iframe>

---

#### RESULTS

Output folder:

- [20230519-pmea-gff_to_gtf](https://gannet.fish.washington.edu/Atumefaciens/20230519-pmea-gff_to_gtf)

  #### GTF

  - [20230519-pmea-gff_to_gtf/Pocillopora_meandrina_HIv1.genes.gtf](https://gannet.fish.washington.edu/Atumefaciens/20230519-pmea-gff_to_gtf/Pocillopora_meandrina_HIv1.genes.gtf) (60MB)

  - MD5 checkum: `638abc4f5f115e7a32731ad24cc558fd`

