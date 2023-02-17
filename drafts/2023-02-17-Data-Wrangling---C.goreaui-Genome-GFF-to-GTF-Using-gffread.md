---
layout: post
title: Data Wrangling - C.goreaui Genome GFF to GTF Using gffread
date: '2023-02-17 11:39'
tags: 
  - gffread
  - Cladocopium goreaui
  - endoysymbiont
  - GFF
  - GTF
  - jupyter
categories: 
  - E5
---
As part of getting [these three coral species genome files](https://github.com/RobertsLab/resources/issues/1571) (GitHub Issue) added to our [Lab Handbook Genomic Resources page](https://robertslab.github.io/resources/Genomic-Resources/), I also need to get the coral endosymbiont sequence. After talking with Danielle Becker in Hollie Putnam's Lab at Univ. of Rhode Island, she pointed me to the _Cladocopium goreaui_ genome from [Chen et. al, 2022](https://doi.org/10.48610/fba3259) available [here](https://espace.library.uq.edu.au/view/UQ:fba3259). Access to the genome requires agreeing to some licensing provisions (primarily the requirment to cite the publication whenever the genome is used), so I will _not_ be providing any public links to the file. In order to index the _Cladocopium goreaui_  genome file (`Cladocopium_goreaui_genome_fa`) using [`HISAT2`](https://daehwankimlab.github.io/hisat2/) for downstream isoform analysis using [`StringTie`](https://ccb.jhu.edu/software/stringtie/) and `ballgown`, I need a corresponding GTF to also identify exon/intro splice sites. Since a GTF file is not available, but a GFF file is, I needed to convert the GFF to GTF. Used `gffread` to do this on my computer. Process is documented in Jupyter Notebook linked below.

Jupyter Notebook (GitHub):

https://github.com/RobertsLab/code/blob/master/notebooks/sam/20230217-cgor-gff_to_gtf.ipynb

Jupyter Notebook (NBviewier):

https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230217-cgor-gff_to_gtf.ipynb


<iframe src="https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230217-cgor-gff_to_gtf.ipynb" width="100%" height="1000" scrolling="yes"></iframe>

---

#### RESULTS

Output folder:

- [20230217-cgor-gff_to_gtf](https://gannet.fish.washington.edu/Atumefaciens/20230217-cgor-gff_to_gtf)

  #### GTF

  - [20230217-cgor-gff_to_gtf/Pver_genome_assembly_v1.0.gtf](https://gannet.fish.washington.edu/Atumefaciens/20230217-cgor-gff_to_gtf/Cladocopium_goreaui_genes_gff3.gtf) (197MB)

  - MD5 checkum: `97e69a850faf2e6d9b60df828ad02671`


---

#### RESULTS

Output folder:

- []()

