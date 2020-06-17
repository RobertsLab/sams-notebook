---
layout: post
title: Metagenomics - Taxonomic Diversity from Geoduck Water with BLASTp and Krona plots
date: '2019-03-25 15:15'
tags:
  - metagenomics
  - Panopea generosa
  - geoduck
  - blastp
  - krona
  - plot
categories:
  - Miscellaneous
---
We're working on getting the metagenomics sequencing project written up as a manuscript and Steven asked me to provide an overview of the taxonomic makeup of our metagenome assembly in this [GitHub Issue](https://github.com/RobertsLab/resources/issues/547).

I previously assembled all of the sequencing data in to a single assembly (i.e. did not assemble by experimental treatments):

- [Megahit assembly notebook](https://robertslab.github.io/sams-notebook/2019/01/02/Metagenome-Assembly-P.generosa-Water-Sample-HiSeqX-Data-Using-Megahit.html).

Subsequently, I ran some gene prediction software to help refine the assembly in to a more conservative representation, in hopes of getting a more realistic view of biologically relevant DNA (i.e. analyzing sequenced DNA that actually has putative functions, as opposed to random eDNA that may have been floating around in the water):

- [MetaGeneMark gene prediction notebook](https://robertslab.github.io/sams-notebook/2019/01/03/Gene-Prediction-HiSeqX-Metagenomics-from-Geoduck-Water-Using-MetaGeneMark-on-Mox.html)


For getting taxonomic info, I took the MetaGeneMark proteins FastA file and ran BLASTp against the NCBI SwissProt database (v5) to get taxonomic IDs. See this
Jupyter Notebook (GitHub):

- [20190321_swoose_metagnomics_pgen_blastp_ncbi-sp-v5-db.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20190321_swoose_metagnomics_pgen_blastp_ncbi-sp-v5-db.ipynb)

This was followed up by using [Krona](https://github.com/marbl/Krona/wiki) to plot the data in an interactive fashion, according to NCBI taxonomic ID abundance (see Results below).

Here's how the sample names breakdown:

| Sample | Develomental Stage (days post-fertilization) | pH Treatment |
|--------|-------------------------|--------------|
| MG1    | 13                      | 8.2          |
| MG2    | 17                      | 8.2          |
| MG3    | 6                       | 7.1          |
| MG5    | 10                      | 8.2          |
| MG6    | 13                      | 7.1          |
| MG7    | 17                      | 7.1          |

---

#### RESULTS

Output folder:

- [20190321_metagenomics_pgen_blastp/](http://gannet.fish.washington.edu/Atumefaciens/20190321_metagenomics_pgen_blastp/)


- Interactive Krona plots (HTML):

- [20190321_metagenomics_pgen_blastp/krona_megahit_MGM_blastp.html](http://gannet.fish.washington.edu/Atumefaciens/20190321_metagenomics_pgen_blastp/krona_megahit_MGM_blastp.html)

As a brief overview, the initial [Megahit assembly](https://robertslab.github.io/sams-notebook/2019/01/02/Metagenome-Assembly-P.generosa-Water-Sample-HiSeqX-Data-Using-Megahit.html) generated:

- 2,276,153 contigs.

[MetaGeneMark](https://robertslab.github.io/sams-notebook/2019/01/03/Gene-Prediction-HiSeqX-Metagenomics-from-Geoduck-Water-Using-MetaGeneMark-on-Mox.html) predicted:

- 3,296,610 genes.

BLASTp resulted in:

- 1,346,325 SwissProt matches

The Krona plot provides a pretty nice way to view the breakdown of the data and, as such, I won't provide a written summary of how it all shakes out.

Next, for curiosity sake, I'll run BLASTn and see how things compare.
