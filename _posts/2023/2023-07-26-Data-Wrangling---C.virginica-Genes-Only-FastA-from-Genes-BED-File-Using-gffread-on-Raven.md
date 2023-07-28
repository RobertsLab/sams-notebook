---
layout: post
title: Data Wrangling - C.virginica Genes Only FastA from Genes BED File Using gffread on Raven
date: '2023-07-26 07:32'
tags: 
  - Crassostrea virginica
  - gffread
  - raven
  - jupyter
categories: 
  - CEABIGR
---
I've been reviewing some of the [CEABIGR](https://github.com/sr320/ceabigr) (GitHub repo) data I've generated; specifically transcript count data/calcs. As part of that, I feel like we need/should annotate the transcripts to be able to make some more informed conclusions. [Steven had previously performed annotations](https://sr320.github.io/annotation/) (Notebook), as well as [Yaamini](https://github.com/RobertsLab/resources/issues/1660) (GitHub Issue). However, there are shortcomings to both of the approaches each one utilized. Steven's annotation relied only on coding sequences (CDS), while Yaamini's utilized only mRNAs.

In order to get a more robust annotation for _all_ transcripts/genes (including long, non-coding RNAs (lncRNAs)), I opted to extract all gene sequences (as FastA) for subsequent BLASTx and gene ontology (GO) annotation. In order to extract FastA, I used [gffread](https://ccb.jhu.edu/software/stringtie/gff.shtml#gffread) and the NCBI [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) genome, `GCF_002022765.2_C_virginica-3.0_genomic.fna`, along with the genes BED file `C_virginica-3.0_Gnomon_genes.bed` (available in [Genomic Resources Handbook page](https://robertslab.github.io/resources/Genomic-Resources/)). All work was run on Raven in the following Jupyter Notebook:

- [20230726-cvir-genes_bed-to-fasta.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20230726-cvir-genes_bed-to-fasta.ipynb) (GitHub)

- [20230726-cvir-genes_bed-to-fasta.ipynb](https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230726-cvir-genes_bed-to-fasta.ipynb) (NB Viewer)


<iframe src="https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230726-cvir-genes_bed-to-fasta.ipynb" width="100%" height="2000" scrolling="yes"></iframe>

---

#### RESULTS

Now, on to BLASTing.

Output folder:

- [20230726-cvir-genes_bed-to-fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-cvir-genes_bed-to-fasta/)

  #### FastA

  - [GCF_002022765.2_C_virginica-3.0-genes.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-cvir-genes_bed-to-fastaGCF_002022765.2_C_virginica-3.0-genes.fasta) (408M)

    - MD5: `a0546fd42642673d80b3071089a6711b`

  #### FastA Index

  - [GCF_002022765.2_C_virginica-3.0-genes.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20230726-cvir-genes_bed-to-fastaGCF_002022765.2_C_virginica-3.0-genes.fasta.fai) (1.5M)

    - MD5: `e69ecc217c2e695a6dab7e599984d592`