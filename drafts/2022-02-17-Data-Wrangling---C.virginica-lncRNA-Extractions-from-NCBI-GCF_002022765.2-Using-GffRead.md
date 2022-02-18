---
layout: post
title: Data Wrangling - C.virginica lncRNA Extractions from NCBI GCF_002022765.2 Using GffRead
date: '2022-02-17 14:47'
tags: 
  - gffread
  - samtools
  - jupyter
  - Crassostrea virginica
  - lncRNA
categories: 
  - Miscellaneous
---
Continuing to work on our [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) project examining the [effects of OA on female and male gonads]() (GitHub repo), Steven tasked me with [parsing out long, non-coding RNAs](https://github.com/RobertsLab/resources/issues/1375) (GitHub Issue). To do so, I relied on [the NCBI genome and associated files/annotations](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/022/765/GCF_002022765.2_C_virginica-3.0/). I used [GffRead](https://github.com/gpertea/gffread), [GFFutils](https://gffutils.readthedocs.io/en/v0.12.0/index.html), and [samtools](http://www.htslib.org/). The process was documented in the followng Jupyter Notebook:

- [20220217-cvir-lncRNA_subsetting.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20220217-cvir-lncRNA_subsetting.ipynb) (GitHub)

- [20220217-cvir-lncRNA_subsetting.ipynb](https://nbviewer.ipython.org/github/RobertsLab/code/blob/master/notebooks/sam/20220217-cvir-lncRNA_subsetting.ipynb) (NBviewer)



<iframe src="https://nbviewer.ipython.org/github/RobertsLab/code/blob/master/notebooks/sam/20220217-cvir-lncRNA_subsetting.ipynb" width="100%" height="1000" scrolling="yes"></iframe>

---

#### RESULTS

Output folder:

- [20220217-cvir-lncRNA_subsetting/](https://gannet.fish.washington.edu/Atumefaciens/20220217-cvir-lncRNA_subsetting/)

  - [GCF_002022765.2_C_virginica-3.0_lncRNA.bed](https://gannet.fish.washington.edu/Atumefaciens/20220217-cvir-lncRNA_subsetting/GCF_002022765.2_C_virginica-3.0_lncRNA.bed) (640K)

    - MD5: `28de37c9ee1308ac1175397d16b3aafe`

  - [GCF_002022765.2_C_virginica-3.0_lncRNA.fa](https://gannet.fish.washington.edu/Atumefaciens/20220217-cvir-lncRNA_subsetting/GCF_002022765.2_C_virginica-3.0_lncRNA.fa) (25M)

    - MD5: `7fac9e7191915f763cc7f5d22838ac25`

  - [GCF_002022765.2_C_virginica-3.0_lncRNA.fa.fai](https://gannet.fish.washington.edu/Atumefaciens/20220217-cvir-lncRNA_subsetting/GCF_002022765.2_C_virginica-3.0_lncRNA.fa.fai) (180K)

    - MD5: `1b43db284950abc07afb5f50164fb264`

  - [GCF_002022765.2_C_virginica-3.0_lncRNA.gff](https://gannet.fish.washington.edu/Atumefaciens/20220217-cvir-lncRNA_subsetting/GCF_002022765.2_C_virginica-3.0_lncRNA.gff) (2.1M)

    - MD5: `00755b8c80166cdec94b09f231ef440a`

  - [GCF_002022765.2_C_virginica-3.0_lncRNA.gtf](https://gannet.fish.washington.edu/Atumefaciens/20220217-cvir-lncRNA_subsetting/GCF_002022765.2_C_virginica-3.0_lncRNA.gtf) (1.3M)

    - MD5: `dedab056acd679cf4eab83629882ee10`
