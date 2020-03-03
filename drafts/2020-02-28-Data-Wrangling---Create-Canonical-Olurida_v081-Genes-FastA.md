---
layout: post
title: Data Wrangling - Create Canonical Olurida_v081 Genes FastA
date: '2020-02-28 13:53'
tags:
  - jupyter notebook
  - v081
  - Ostrea lurida
  - Olympia oyster
  - FastA
  - GFF
categories:
  - Miscellaneous
---
I finally had some time to tackle [this GitHub Issue](https://github.com/RobertsLab/resources/issues/835) and create a canonical genes FastA file using the MAKER IDs, instead of the original contig IDs from our Olympia oyster genome assembly - [https://owl.fish.washington.edu/halfshell/genomic-databank/Olurida_v081.fa](https://owl.fish.washington.edu/halfshell/genomic-databank/Olurida_v081.fa.fai) (FastA; 1.1GB).

Everything was documented in a Jupyter Notebook (see link below), but here's the skinny on how I did it:

1. Pull existing FastA-formatted sequences from the [fully annotated GFF](https://owl.fish.washington.edu/halfshell/genomic-databank/Olurida_v081_genome_snap02.all.renamed.putative_function.domain_added.gff) (GFF; 2.9GB; MAKER appended the FastAs to the end of the GFF).

2. Use ['bedTools fastaFromBed'](https://bedtools.readthedocs.io/en/latest/content/tools/getfasta.html) to create FastA for all genes using gene GFF coordinates and generate unique FastA headers for each sequence.

3. Use `sed` to do a substitution using the MAKER IDs and the `bedTools fastaFromBed` IDs.

Jupyter Notebook (GitHub):

- [20200228_swoose_olur_v081_fasta_renaming.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20200228_swoose_olur_v081_fasta_renaming.ipynb)

---

#### RESULTS

Output folder:

- []()
