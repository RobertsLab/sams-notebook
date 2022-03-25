---
layout: post
title: Data Wrangling - P.generosa Genomic Feature FastA Creation
date: '2022-03-24 14:56'
tags: 
  - Panopea generosa
  - Pacific geoduck
  - jupyter
  - jupyter notebook
  - gffutils
  - bedtools
categories: 
  - Miscellaneous
---
Steven wanted me to [generate FastA files](https://github.com/RobertsLab/resources/issues/1439) (GitHub Issue) for [_Panopea generosa_ (Pacific geoduck)](http://en.wikipedia.org/wiki/Geoduck) coding sequences (CDS), genes, and mRNAs. One of the primary needs, though, was to have an ID that could be used for downstream table joining/mapping. I ended up using a combination of [GFFutils](https://gffutils.readthedocs.io/en/v0.12.0/index.html) and [`bedtools getfasta`](https://bedtools.readthedocs.io/en/latest/content/tools/getfasta.html). I took advantage of being able to create a custom `name` column in BED files to generate the desired FastA description line having IDs that could identify, and map, CDS, genes, and mRNAs across FastAs and GFFs.

This was all documented in a Jupyter Notebook:

GitHub:

- [20220324-pgen-gffs_to_fastas.ipynb](https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20220324-pgen-gffs_to_fastas.ipynb)

NB Viewer:

- [20220324-pgen-gffs_to_fastas.ipynb](https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20220324-pgen-gffs_to_fastas.ipynb)

<iframe src="https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20220324-pgen-gffs_to_fastas.ipynb" width="100%" height="2000" scrolling="yes"></iframe>


---

#### RESULTS

Output folder:

- [20220324-pgen-gffs_to_fastas/](https://gannet.fish.washington.edu/Atumefaciens/20220324-pgen-gffs_to_fastas/)

  - MD5 checksums for all files (text):

    - [checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20220324-pgen-gffs_to_fastas/checksums.md5) (4.0K)

  - FastA files and FastA index files:

    - [Panopea-generosa-v1.0.a4.CDS.fasta](https://gannet.fish.washington.edu/Atumefaciens/20220324-pgen-gffs_to_fastas/Panopea-generosa-v1.0.a4.CDS.fasta) (67M)

      - MD5: `fb192eab0aefd5d3ba5bebef2a012f15`

    - [Panopea-generosa-v1.0.a4.CDS.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20220324-pgen-gffs_to_fastas/Panopea-generosa-v1.0.a4.CDS.fasta.fai) (26M)

      - MD5: `f2266a449290ea0383d2eb98eb3ed426`

    - [Panopea-generosa-v1.0.a4.gene.fasta](https://gannet.fish.washington.edu/Atumefaciens/20220324-pgen-gffs_to_fastas/Panopea-generosa-v1.0.a4.gene.fasta) (362M)

      - MD5: `7c956b1c27d14bd91959763403f81265
    588d18f5fe0e4f2259a25586349fc244`

    - [Panopea-generosa-v1.0.a4.gene.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20220324-pgen-gffs_to_fastas/Panopea-generosa-v1.0.a4.gene.fasta.fai) (2.4M)

      - MD5: `588d18f5fe0e4f2259a25586349fc244`

    - [Panopea-generosa-v1.0.a4.mRNA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20220324-pgen-gffs_to_fastas/Panopea-generosa-v1.0.a4.mRNA.fasta) (475M)

      - MD5: `1823be75694cf70f0ea6f1abc072ba16
    e120b4c1d3bb0917868e72cd22507bbc`

    - [Panopea-generosa-v1.0.a4.mRNA.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20220324-pgen-gffs_to_fastas/Panopea-generosa-v1.0.a4.mRNA.fasta.fai) (3.4M)

      - MD5: `e120b4c1d3bb0917868e72cd22507bbc`

---

CDS FastA description lines look like this:

- `>PGEN_.00g000010.m01.CDS01|PGEN_.00g000010.m01|PGEN_.00g000010::Scaffold_01:2-125`

Explanation for CDS:

- `PGEN_.00g000010.m01.CDS01`: Unique sequence ID.
- `PGEN_.00g000010.m01`: "Parent" ID. Corresponds to unique _mRNA_ ID.
- `PGEN_.00g000010`: "Parent" ID. Corresponds to unique _gene_ ID.
- `Scaffold_01`: Originating scaffold.
- `2-125`: Sequence coordinates from scaffold mentioned above.

mRNA FastA description looks like this:

- `PGEN_.00g000030.m01|PGEN_.00g000030::Scaffold_01:49248-52578`

Explanation for mRNA:

- `PGEN_.00g000030.m01`: Unique sequence ID.
- `PGEN_.00g000030`: "Parent" ID. Corresponds to unique _gene_ ID.
- `Scaffold_01`: Originating scaffold.
- `49248-52578`: Sequence coordinates from scaffold mentioned above.

