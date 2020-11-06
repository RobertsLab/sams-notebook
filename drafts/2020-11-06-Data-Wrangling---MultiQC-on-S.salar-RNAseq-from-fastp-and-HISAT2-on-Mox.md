---
layout: post
title: Data Wrangling - MultiQC on S.salar RNAseq from fastp and HISAT2 on Mox
date: '2020-11-06 05:01'
tags:
  - multiqc
  - fastp
  - hisat2
  - Salmo salar
  - RNAseq
  - mox
categories:
  - Miscellaneous
---
In [Shelly's GitHub Issue](https://github.com/RobertsLab/resources/issues/1016) for this _S.salar_ project, she also requested a [`MultiQC`](https://multiqc.info/) report for the [trimming (completed on 20201029)](https://robertslab.github.io/sams-notebook/2020/10/29/Trimming-Shelly-S.salar-RNAseq-Using-fastp-and-MultiQC-on-Mox.html) and the [genome alignments (completed on 20201103)](https://robertslab.github.io/sams-notebook/2020/11/03/RNAseq-Alignments-Trimmed-S.salar-RNAseq-to-GCF_000233375.1_ICSASG_v2_genomic.fa-Using-Hisat2-on-Mox.html).

I ran [`MultiQC`](https://multiqc.info/) on Mox using a build node and no script, since the command is so simple (e.g. multiqc .) and so quick.


---

#### RESULTS

Output folder:

- []()
