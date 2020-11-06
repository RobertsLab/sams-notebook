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

- [20201106_ssalar_multiqc_fastp-hisat2/](https://gannet.fish.washington.edu/Atumefaciens/20201106_ssalar_multiqc_fastp-hisat2/)

##### [`MultiQC`](https://multiqc.info/) report (HTML)

- [20201106_ssalar_multiqc_fastp-hisat2/multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20201106_ssalar_multiqc_fastp-hisat2/multiqc_report.html)

A couple of notes:

1. The `[`fastp`](https://github.com/OpenGene/fastp)` trimming results are reported with sample names with a `_1`. This is an unfortunate mistake with name parsing. The results are comprised of both Read 1 and Read 2 FastQ data; not just Read 1.

2. The [`HISAT2`](https://daehwankimlab.github.io/hisat2/) results also suffer from a poor filename that ends with `.err`. Despite the name, these files actually contain the alignment summary data.
