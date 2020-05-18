---
layout: post
title: Data Wrangling - Arthropoda and Alveolata D26 Pool RNAseq FastQ Extractions
date: '2020-05-18 10:36'
tags:
  - hematodinium
  - Tanner crab
  - Chionoecetes bairdi
  - jupyter
  - MEGAN6
  - seqtk
categories:
  - Miscellaneous
---
After using MEGAN6 to [extract _Arthropoda_ and _Alveolata_ reads from our RNAseq data on 20200114](https://robertslab.github.io/sams-notebook/2020/01/14/RNAseq-Reads-Extractions-C.bairdi-Taxonomic-Reads-Extractions-with-MEGAN6-on-swoose.html), I had then extracted taxonomic-specific reads and aggregated each into basic Read 1 and Read 2 FastQs to simplify [transcriptome assembly for _C.bairdi_](https://robertslab.github.io/sams-notebook/2020/01/22/Transcriptome-Assembly-C.bairdi-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html) and [for _Hematodinium_](https://robertslab.github.io/sams-notebook/2020/01/22/Transcriptome-Assembly-Hematodinium-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html). That was fine and all, but wasn't fully thought through.

For completeness, I realized that I had _not_ run this taxonomic extraction on the 2018 RNAseq data.

For reference, these _only_ include RNAseq data using a newly established "shorthand": 2018)

As a reminder, the reason I'm doing this is that I realized that the FastA headers were incomplete and did not distinguish between paired reads. Here's an example:

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

Anyway, here's a brief rundown of the approach:

1. Create list of unique read headers from MEGAN6 FastA files.

2. Use list with `seqtk` program to pull out corresponding FastQ reads from the trimmed FastQ R1 and R2 files.

The entire procedure is documented in a Jupyter Notebook below.

Jupyter notebook (GitHub):

- [20200518_swoose_cbai_megan_read_extractions.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20200518_swoose_cbai_megan_read_extractions.ipynb)

---

#### RESULTS

Output folders:

- [20200518.C_bairdi_megan_reads](https://gannet.fish.washington.edu/Atumefaciens/20200518.C_bairdi_megan_reads/)

- [20200518.Hematodinium_megan_reads/](https://gannet.fish.washington.edu/Atumefaciens/20200518.Hematodinium_megan_reads/)


We now have two distinct sets of RNAseq reads from _C.bairdi_ (_Arhtropoda_) and _Hematodinium_ (_Alveolata_).

I'll use these to supplement/update our existing species-specific transcriptomes, since it takes very little time/effort to generate them and run them through the assembly/annotation pipeline.
