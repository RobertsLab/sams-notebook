---
layout: post
title: Data Wrangling - Arthropoda and Alveolata Taxonomic RNAseq FastQ Extractions
date: '2020-01-22 13:45'
tags:
  - arthropoda
  - alveolata
  - hematodinium
  - Chionoecetes bairdi
  - Tanner crab
  - seqtk
  - FastA
  - FastQ
  - MEGAN6
  - taxonomy
categories:
  - Tanner Crab RNAseq
---
After using MEGAN6 to [extract _Arthropoda_ and _Alveolata_ reads from our RNAseq data on 20200114](https://robertslab.github.io/sams-notebook/2020/01/14/RNAseq-Reads-Extractions-C.bairdi-Taxonomic-Reads-Extractions-with-MEGAN6-on-swoose.html) (for reference, these include RNAseq data using a newly established "shorthand": 2018, 2019), I realized that the FastA headers were incomplete and did not distinguish between paired reads. Here's an example:

R1 FastQ header:

`@A00147:37:HG2WLDMXX:1:1101:5303:1000 1:N:0:AGGCGAAG+AGGCGAAG`

R2 FastQ header:

`@A00147:37:HG2WLDMXX:1:1101:5303:1000 2:N:0:AGGCGAAG+AGGCGAAG`

However, the reads extracted via MEGAN have FastA headers like this:

```
>A00147:37:HG2WLDMXX:1:1101:5303:1000
SEQUENCE1
>A00147:37:HG2WLDMXX:1:1101:5303:1000
SEQUENCE2
```

Those are a set of paired reads, but there's no way to distinguish between R1/R2. This may not be an issue, but I'm not sure how downstream programs (i.e. Trinity) will handle duplicate FastA IDs as inputs. To avoid any headaches, I've decided to parse out the corresponding FastQ reads which have the full header info.

Here's a brief rundown of the approach:

1. Create list of unique read headers from MEGAN6 FastA files.

2. Use list with `seqtk` program to pull out corresponding FastQ reads from the trimmed FastQ R1 and R2 files.

The entire procedure is documented in a Jupyter Notebook below.

Jupyter notebook (GitHub):

- [20200122_swoose_cbai_megan_read_extractions.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20200122_swoose_cbai_megan_read_extractions.ipynb)

---

#### RESULTS

Output folders:

- [20200122.C_bairdi_megan_reads](https://gannet.fish.washington.edu/Atumefaciens/20200122.C_bairdi_megan_reads/)

- [20200122.Hematodinium_megan_reads/](https://gannet.fish.washington.edu/Atumefaciens/20200122.Hematodinium_megan_reads/)


We now have to distinct sets of RNAseq reads to create separate transcriptome assemblies from _C.bairdi_ (_Arhtropoda_) and _Hematodinium_ (_Alveolata_)! Will get _de novo_ assemblies with Trinity going on Mox.
