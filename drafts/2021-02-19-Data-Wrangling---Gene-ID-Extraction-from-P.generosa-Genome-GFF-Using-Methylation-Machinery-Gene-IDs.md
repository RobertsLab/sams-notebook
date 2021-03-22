---
layout: post
title: Data Wrangling - Gene ID Extraction from P.generosa Genome GFF Using Methylation Machinery Gene IDs
date: '2021-02-19 21:37'
tags:
  - jupyter notebook
  - methylation
  - Panopea generosa
  - Pacific geoduck
categories:
  - Miscellaneous
---
Per [this GitHub issue](https://github.com/RobertsLab/resources/issues/1116), Steven provided a list of methylation-related gene names and wanted to extract the corresponding [_Panopea generosa_ ([Pacific geoduck (_Panopea generosa_)](http://en.wikipedia.org/wiki/Geoduck))](http://en.wikipedia.org/wiki/Geoduck) gene ID from our _P.generosa_ genome, along with corresponding [`BLAST`](https://www.ncbi.nlm.nih.gov/books/NBK279690/) e-values.

Everything is documented in the Jupyter Notebook linked below.

Here's the list of gene IDs of interest:

```
dnmt1
dnmt3a
dnmt3b
dnmt3l
mbd1
mbd2
mbd3
mbd4
mbd5
mbd6
mecp2
Baz2a
Baz2b
UHRF1
UHRF2
Kaiso
zbtb4
zbtb38b
zfp57
klf4
egr1
wt1
ctcf
tet1
tet2
tet3
```

The gist of the process was like this:

1. `grep` gene IDs in `Panopea-generosa-vv0.74.a4.gene.gff3`

2. Use resulting _P.generosa_ genome IDs to `grep` [`BLASTp`](https://www.ncbi.nlm.nih.gov/books/NBK279690/) and [`DIAMOND`](https://github.com/bbuchfink/diamond) BLASTx tables (`Panopea-generosa-vv0.74.a4.5d951a9b74287-blast_functional.tab` and `Panopea-generosa-vv0.74.a4.5d951bcf45b4b-diamond_functional.tab`) to extract e-values.

Jupyter Notebook (GitHub):

- [20210226_pgen_methylation_gene_IDs.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20210226_pgen_methylation_gene_IDs.ipynb)

Jupyter Notebook (NBviewer):

- [0210226_pgen_methylation_gene_IDs.ipynb](https://nbviewer.jupyter.org/github/RobertsLab/code/blob/master/notebooks/sam/20210226_pgen_methylation_gene_IDs.ipynb)

Jupyter Notebook:

<iframe src="https://nbviewer.jupyter.org/github/RobertsLab/code/blob/master/notebooks/sam/20210226_pgen_methylation_gene_IDs.ipynb" width="100%" height="2000" scrolling="yes"></iframe>


---

#### RESULTS