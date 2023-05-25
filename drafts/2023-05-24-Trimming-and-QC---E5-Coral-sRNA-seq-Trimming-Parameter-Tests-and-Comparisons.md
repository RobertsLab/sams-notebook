---
layout: post
title: Trimming and QC - E5 Coral sRNA-seq Trimming Parameter Tests and Comparisons
date: '2023-05-24 11:47'
tags: 
  - trimming
  - flexbar
  - E5
  - sRNAseq
  - jupyter
categories: 
  - E5
---
In preparation for [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) and trimming of the [E5 coral sRNA-seq data](https://robertslab.github.io/sams-notebook/2023/05/17/Data-Management-E5-Coral-RNA-seq-and-sRNA-seq-Reorganizing-and-Renaming.html), I noticed that my "default" trimming settings didn't produce the results I expected. Specifically, since these are sRNAs and the [NEBNext® Multiplex Small RNA Library Prep Set for Illumina](https://www.neb.com/-/media/nebus/files/manuals/manuale7300_e7330_e7560_e7580.pdf?rev=d0964a2e637843b1afcb9f7d666d07b2&hash=5B733FC9B41103A865143C75D0F3FC5D) (PDF) protocol indicates that the sRNAs should be ~21 - 30bp, it seemed odd that I was still ending up with read lengths of 150bp. So, I tried a couple of quick trimming comparisons on just a single pair of sRNA FastQs to use as examples to get feeback on how trimming should proceed.

Trimming was done with the [`flexbar`](https://github.com/seqan/flexbar). As an aside, I might begin using this trimmer instead of [`fastp`](https://github.com/OpenGene/fastp) going forward. [`fastp`](https://github.com/OpenGene/fastp) has some odd "quirks" in it's order of operations that sometimes require two rounds of trimming. Also, it's annoying that [`fastp`](https://github.com/OpenGene/fastp) limits the number of threads to 16; [`flexbar`](https://github.com/seqan/flexbar) has no such limitation. Perhaps this is moot, as I'm not sure if there's truly a performance increase or not. The biggest trade off, though, is that [`fastp`](https://github.com/OpenGene/fastp) automatically generates HTML reports for trimming, which include pre- and post-trimming plots/data. These are very useful and are also interpreted by [`MultiQC`](https://multiqc.info/)...

This was all done on Raven using a Jupyter Notebook.

Jupyter Notebook (GitHub):

- [20230524-E5-coral-sRNAseq_trimmings_comparisons.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20230524-E5-coral-sRNAseq_trimmings_comparisons.ipynb)

Jupyter Notebook (NB Viewer):

- [20230524-E5-coral-sRNAseq_trimmings_comparisons.ipynb](https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230524-E5-coral-sRNAseq_trimmings_comparisons.ipynb)

<iframe src="https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230524-E5-coral-sRNAseq_trimmings_comparisons.ipynb" width="100%" height="1000" scrolling="yes"></iframe>


---

#### RESULTS

Output folder:

- []()

