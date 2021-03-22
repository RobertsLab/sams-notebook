---
layout: post
title: Data Wrangling - Gene ID Extraction from P.generosa Genome GFF Using Methylation Machinery Gene IDs
date: '2021-02-26 21:37'
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

Here's the final table:

| Gene_ID         | gene_name | BLASTp_evalue | DIAMOND_evalue |
|-----------------|-----------|---------------|----------------|
| PGEN_.00g104080 | Baz2b     | 1.05E-98      | 5.40E-102      |
| PGEN_.00g104170 | Baz2b     | 3.09E-96      | 1.20E-109      |
| PGEN_.00g116950 | mbd5      | 6.40E-21      | 2.80E-20       |
| PGEN_.00g186870 | ctcf      | 1.25E-116     |                |
| PGEN_.00g192900 | UHRF1     | 2.32E-19      |                |
| PGEN_.00g202750 | mbd2      | 9.46E-82      | 2.60E-63       |
| PGEN_.00g209890 | mbd2      | 4.37E-19      | 9.20E-09       |
| PGEN_.00g209900 | mbd4      | 3.14E-32      | 8.00E-29       |
| PGEN_.00g243700 | egr1      | 6.24E-58      | 2.20E-23       |
| PGEN_.00g249090 | egr1      | 4.19E-18      | 2.60E-06       |
| PGEN_.00g283000 | dnmt1     | 5.03E-10      | 8.20E-28       |
| PGEN_.00g283010 | dnmt1     | 0             | 7.30E-224      |