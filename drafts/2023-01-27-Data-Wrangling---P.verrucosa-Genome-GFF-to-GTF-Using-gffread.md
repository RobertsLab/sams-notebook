---
layout: post
title: Data Wrangling - P.verrucosa Genome GFF to GTF Using gffread
date: '2023-01-27 09:38'
tags: 
  - jupyter
  - GFF
  - GTF
  - gffread
  - Pocillopora verrucosa
  - coral
categories: 
  - Miscellaneous
---
As part of getting [these three coral species genome files](https://github.com/RobertsLab/resources/issues/1571) (GitHub Issue) added to our [Lab Handbook Genomic Resources page](https://robertslab.github.io/resources/Genomic-Resources/), I will index the _P.verrucosa_ genome file (`Pver_genome_assembly_v1.0.fasta`) using [`HISAT2`](https://daehwankimlab.github.io/hisat2/), but need a GTF file to also identify exon/intro splice sites. Since a GTF file is not available, but a GFF file is, I needed to convert the GFF to GTF. Used `gffread` to do this on my computer. Process is documented in Jupyter Notebook linked below.

Jupyter Notebook (GitHub):

https://github.com/RobertsLab/code/blob/master/notebooks/sam/20230127-pver-gff_to_gtf.ipynb

Jupyter Notebook (NBviewier):

https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230127-pver-gff_to_gtf.ipynb


<iframe src="https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230127-pver-gff_to_gtf.ipynb" width="100%" height="1000" scrolling="yes"></iframe>

---

#### RESULTS

Output folder:

- [20230127-pver-gff_to_gtf](https://gannet.fish.washington.edu/Atumefaciens/20230127-pver-gff_to_gtf)

  #### GTF

  - [20230127-pver-gff_to_gtf/Pver_genome_assembly_v1.0.gtf](https://gannet.fish.washington.edu/Atumefaciens/20230127-pver-gff_to_gtf/Pver_genome_assembly_v1.0.gtf) (48MB)

  - MD5 checkum: `c3cc8fb576bcf39dd17b6d229100aa56`
