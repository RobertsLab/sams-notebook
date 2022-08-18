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

- [20220818-snam-gff_to_bed-genes/](https://gannet.fish.washington.edu/Atumefaciens/20220818-snam-gff_to_bed-genes/)

  - BED file (2.2MB)

    - [20211209_cvir_gff-to-bed/20220818-snam-GCF_016432855.1_SaNama_1.0_genes.bed](https://gannet.fish.washington.edu/Atumefaciens/20220818-snam-gff_to_bed-genes/20220818-snam-GCF_016432855.1_SaNama_1.0_genes.bed)

      - MD5 checksum:

        - `440d09ac4bd225a6585d69ef623fd812  `


The resulting BED file was added to the [Roberts Lab Handbook - Genomic Resources page](https://robertslab.github.io/resources/Genomic-Resources/#salvelinus-namaycush).

