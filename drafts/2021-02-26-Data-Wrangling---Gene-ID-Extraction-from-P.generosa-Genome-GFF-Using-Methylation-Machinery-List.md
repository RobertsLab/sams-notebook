---
layout: post
title: Data Wrangling - Gene ID Extraction from P.generosa Genome GFF Using Methylation Machinery List
date: '2021-02-26 20:31'
tags:
  - Panopea generosa
  - Pacific geoduck
  - mox
categories:
  - Miscellaneous
---
Per [this GitHub Issue](https://github.com/RobertsLab/resources/issues/1116) Steven asked that I take a list of gene names associated with DNA methylation and see if I could extract a list of [_Panopea generosa_ (Panopea generosa)](http://en.wikipedia.org/wiki/Geoduck) gene IDs and corresponding BLAST e-values for each from our _P.generosa_ genome annotation (see [Genomic Resources wiki](https://github.com/RobertsLab/resources/wiki/Genomic-Resources) for more info).

Here's the list of gene names provided:

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

The operations were run in a Jupyter Notebook. All results are available in the notebook, as well as in the RESULTS section below.

Briefly, here's how the process was run:

1. Use list of gene names to scan GenSAS `Panopea-generosa-vv0.74.a4.gene.gff3`

2. Use list of matches to scan both GenSAS BLAST results files:

 - `Panopea-generosa-vv0.74.a4.5d951a9b74287-blast_functional.tab`

 - `Panopea-generosa-vv0.74.a4.5d951bcf45b4b-diamond_functional.tab`

 3. Extract e-values for any matches.

 4. Print out tab-delimited table of _P.generosa_ gene IDs, gene names, and both BLAST results e-values, if present.

Jupyter Notebook:

- GitHub: [20210226_pgen_methylation_gene_IDs.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20210226_pgen_methylation_gene_IDs.ipynb)

- nbviewer: [20210226_pgen_methylation_gene_IDs.ipynb](https://nbviewer.jupyter.org/github/RobertsLab/code/blob/master/notebooks/sam/20210226_pgen_methylation_gene_IDs.ipynb)

<iframe src="https://nbviewer.jupyter.org/github/RobertsLab/code/blob/master/notebooks/sam/20210226_pgen_methylation_gene_IDs.ipynb" width="100%" height="1000" scrolling="yes"></iframe>

---

#### RESULTS



Tab-delimited:

```
gene_ID          gene_name  BLASTp_evalue  DIAMOND_evalue
PGEN_.00g104080  Baz2b      1.05e-98       5.4e-102
PGEN_.00g104170  Baz2b      3.09e-96       1.2e-109
PGEN_.00g116950  mbd5       6.40e-21       2.8e-20
PGEN_.00g186870  ctcf       1.25e-116
PGEN_.00g192900  UHRF1      2.32e-19
PGEN_.00g202750  mbd2       9.46e-82       2.6e-63
PGEN_.00g209890  mbd2       4.37e-19       9.2e-09
PGEN_.00g209900  mbd4       3.14e-32       8.0e-29
PGEN_.00g243700  egr1       6.24e-58       2.2e-23
PGEN_.00g249090  egr1       4.19e-18       2.6e-06
PGEN_.00g283000  dnmt1      5.03e-10
PGEN_.00g283010  dnmt1      0.0            7.3e-224
```

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
