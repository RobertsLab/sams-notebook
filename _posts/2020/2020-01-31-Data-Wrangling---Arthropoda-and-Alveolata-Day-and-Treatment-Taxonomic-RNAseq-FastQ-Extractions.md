---
layout: post
title: Data Wrangling - Arthropoda and Alveolata Day and Treatment Taxonomic RNAseq FastQ Extractions
date: '2020-01-31 08:33'
tags:
  - hematodinium
  - Tanner crab
  - Chionoecetes bairdi
  - MEGAN6
categories:
  - Miscellaneous
---
After using MEGAN6 to [extract _Arthropoda_ and _Alveolata_ reads from our RNAseq data on 20200114](https://robertslab.github.io/sams-notebook/2020/01/14/RNAseq-Reads-Extractions-C.bairdi-Taxonomic-Reads-Extractions-with-MEGAN6-on-swoose.html), I had then extracted taxonomic-specific reads and aggregated each into basic Read 1 and Read 2 FastQs to simplify [transcriptome assembly for _C.bairdi_](https://robertslab.github.io/sams-notebook/2020/01/22/Transcriptome-Assembly-C.bairdi-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html) and [for _Hematodinium_](https://robertslab.github.io/sams-notebook/2020/01/22/Transcriptome-Assembly-Hematodinium-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html). That was fine and all, but wasn't fully thought through.

For gene expression analysis, I need the FastQs based on infection status and sample days. So, I need to modify the read extraction procedure to parse reads based on those conditions. I could've/should've done this originally, as I could've just assembled the transcriptome from the FastQs I'm going to generate now. Oh well.

For reference, these include RNAseq data using a newly established "shorthand": 2019)

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

- [20200131_swoose_cbai_megan_day-treatment_read_extractions.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20200131_swoose_cbai_megan_day-treatment_read_extractions.ipynb)

---

#### RESULTS

Output folders:

- [20200131.C_bairdi_megan_reads](https://gannet.fish.washington.edu/Atumefaciens/20200131.C_bairdi_megan_reads/)

- [20200131.Hematodinium_megan_reads/](https://gannet.fish.washington.edu/Atumefaciens/20200131.Hematodinium_megan_reads/)


We now have two distinct sets of RNAseq reads from _C.bairdi_ (_Arhtropoda_) and _Hematodinium_ (_Alveolata_), split by infection status and sample day! Will get some gene expression analysis going.

Also of note, and this is a nice bit of confirmation, there are no reads present in the _Hematodinium_ extractions in either of the uninfected samples (D12 or D26). So, the only comparisons to be performed for them will be comparing D12 vs D26.
