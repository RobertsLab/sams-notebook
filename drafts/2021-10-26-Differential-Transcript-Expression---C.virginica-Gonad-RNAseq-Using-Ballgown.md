---
layout: post
title: Differential Transcript Expression - C.virginica Gonad RNAseq Using Ballgown
date: '2021-10-21 07:17'
tags: 
  - Crasssostrea virginica
  - Eastern oyster
  - gonad
  - RNAseq
  - ballgown
  - DEG
  - DET
  - expression
categories: 
  - Miscellaneous
---
In preparation for differential transcript analysis, I previously ran our RNAseq data through [`StringTie`](https://ccb.jhu.edu/software/stringtie/) on [20210726](https://robertslab.github.io/sams-notebook/2021/07/26/Transcript-Identification-and-Quantification-C.virginia-RNAseq-With-NCBI-Genome-GCF_002022765.2-Using-StringTie-on-Mox.html) to identify and quantify transcripts. Identification of differentially expressed transcripts (DETs) and genes (DEGs) will be performed using [`ballgown`](https://github.com/alyssafrazee/ballgown). This notebook entry will be different than most others, as this notebook entry will simply serve as a "landing page" to access/review the analysis; as the analysis will evolve over time and won't exist as a single computing job with a definitive endpoint.

I'll just update this post as things go on, primarily with just a focus on important/interesting details/results.

The analysis is part of the following GitHub repo:

- [https://github.com/epigeneticstoocean/2018_L18-adult-methylation](https://github.com/epigeneticstoocean/2018_L18-adult-methylation)

Analysis is taking place via the following R Markdown file:

- [`ballgown_analysis.Rmd`](https://github.com/epigeneticstoocean/2018_L18-adult-methylation/blob/main/code/ballgown_analysis.Rmd)

The `ballgown_analysis.Rmd` is designed to be maximally reproducible and includes code to download all the necessary data files needed to run the full analysis. With that being said, it will _not_ run properly without the directory structure that comes with the GitHub repo linked above. Additionally, that repo contains an R Project, which `ballgown_analysis.Rmd` essentially relies on in order to manage file/directory locations. So, it would be best to clone [https://github.com/epigeneticstoocean/2018_L18-adult-methylation](https://github.com/epigeneticstoocean/2018_L18-adult-methylation) and then run the `ballgown_analysis.Rmd`

Finally, one of the goals of this project is to identify how DNA methylation (more specifically, how differentially methylated loci) might impact expression of alternative transcripts.

---

Some information/guide to how [`ballgown`](https://github.com/alyssafrazee/ballgown) works "behind the scenes".

1. Pairwise (two-group) differential transcript/gene expression analysis.

  - Outputs will be table of differentially expressed transcripts or genes.

  - Outputs will _not_ indicate which group the DETs/DEGs belong to. Requires "manual" separation based on value in the fold change (`fc`) column.

    - [Fold change (`fc`) will be in reference to to group that comes first alphanumerically (e.g. groups 0 and 1; 0 would be considered the reference group). Up-regulated transcripts/genes in the first group (e.g. group 0) will have an `fc` value < 1, while up-regulated transcripts/genes in the second group will have an `fc` value > 1.](https://support.bioconductor.org/p/77144/#77369) (links to developer explanation on BioConductor forums)

2. Multigroup (i.e. > 2 groups) differential transcript/gene expression analysis.

  - Cannot use fold change (`fc`) as a means to determine differences.

  - [Will identify DETs/DEGs, but cannot determine which factor (group) is driving this.](https://support.bioconductor.org/p/77144/#77369) (links to developer explanation on BioConductor forums)

### Comparison of FPKM values across all libraries, sorted by `sex`:

<embed src="https://drive.google.com/viewerng/
viewer?embedded=true&url=https://github.com/epigeneticstoocean/2018_L18-adult-methylation/raw/main/figures/fpkm_f-vs-m_boxplot.pdf" width="500" height="500">

