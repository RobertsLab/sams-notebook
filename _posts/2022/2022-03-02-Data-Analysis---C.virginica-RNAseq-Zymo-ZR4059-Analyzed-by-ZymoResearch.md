---
layout: post
title: Data Analysis - C.virginica RNAseq Zymo ZR4059 Analyzed by ZymoResearch
date: '2022-03-02 13:59'
tags: 
  - Crassostrea virginica
  - Eastern oyster
  - ZymoResearch
  - MultiQC
  - RNAseq
categories: 
  - Miscellaneous
---
After realizing that the [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) RNAseq data had relatively low alignment rates (see [this notebook entry from 20220224](https://robertslab.github.io/sams-notebook/2022/02/24/Trimming-Additional-20bp-from-C.virginica-Gonad-RNAseq-with-fastp-on-Mox.html) for a bit more background), I contacted ZymoResearch to see if they had any insight on what might be happening. I suspected rRNA contamination. ZymoResearch was kind enough to run the RNAseq data through their pipeline and provided us. This notebook entry provides a brief overview and thoughts on the report.


---

#### RESULTS

Output folder:

- [20220302-cvir-RNAseq-gonad-zymo_multiqc/](https://gannet.fish.washington.edu/Atumefaciens/20220302-cvir-RNAseq-gonad-zymo_multiqc/)

  - Interactive MultiQC Report (HTML - will render in web browser):

    - [zr4059_multiqc_report_with_alignment.html](https://gannet.fish.washington.edu/Atumefaciens/20220302-cvir-RNAseq-gonad-zymo_multiqc/zr4059_multiqc_report_with_alignment.html)

    - The ZymoResearch explanation of their reports is here:

https://github.com/Zymo-Research/service-pipeline-documentation/blob/master/docs/how_to_use_RNAseq_report.md


<iframe src="https://gannet.fish.washington.edu/Atumefaciens/20220302-cvir-RNAseq-gonad-zymo_multiqc/zr4059_multiqc_report_with_alignment.html" width="100%" height="1000" scrolling="yes"></iframe>




The big takeaway here is that all of the _male_ samples (samples names ending with an `M`) have the following issues:

- significant amounts of gDNA

  - characterized by significant quantities of reads mapping to introns; see RSeQC section of report
  - characterized by significant quantities of reads mapping to sense strand; see Infer Experiment section of report

- possible contaminating sequence

  - characterized by two peaks in GC content; see Per Sequence GC Content section of report

So, with all of that in mind, I'm wondering how gDNA contamination would impact:

1. Differential gene expression?
2. Transcriptome assembly?

Keeping in mind we have an annotated genome that was used for aligning RNAseq. Will differential expression analysis take this into account and only deal with reads falling into regions annotated as RNA/CDS/exon/etc and ignore reads falling into intronic/intergenic regions? Same question applies for genome-guided transcriptome assembly (I'll actually hit up the Trinity developer(s) to see their thoughts).

Or, do we have to filter the data ourselves to ensure that downstream analyses are only using reads aligning in RNA/CDS/exon/etc?

I'd like to assume that downstream analysis will utilize only data which aligns to the parts of the genome that one would expect to generate transcripts, but we know what happens when we assume - we break the Golden Rule of Bioinformatics!

On a side note, that MultiQC report is pretty boss! I always forget about all of the modules available! Also, it looks like they used an RNAseq Nextflow pipeline to handle all of that data processing (including some differential gene expression) - definitely pretty slick!

Also, in case someone revisits this post in the future (i.e. me!), I have most of this in [GitHub Discussion](https://github.com/RobertsLab/resources/discussions/1421) which, hopefully, will be updated with input from others on the topic. That may be easier to reference instead of relying on me to update this single notebook entry if/when new information comes to light.