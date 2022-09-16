---
layout: post
title: RNAseq Alignments - P.generosa Alignments and Alternative Transcript Identification Using Hisat2 and StringTie on Mox
date: '2022-09-14 07:14'
tags: 
  - Panopea generosa
  - geoduck
  - mox
  - hisat2
  - StringTie
  - alignment
  - RNAseq
categories: 
  - Miscellaneous
---
As part of [identifying long non-coding RNA (lncRNA) in Pacific geoduck](https://github.com/RobertsLab/resources/issues/1434)(GitHub Issue), one of the first things that I wanted to do was to gather all of our geoduck RNAseq data and align it to our geoduck genome. In addition to the alignments, some of the examples I've been following have also utilized expression levels as one aspect of the lncRNA selection criteria, so I figured I'd get this info as well.

[Trimmed RNAseq data from 20220908](https://robertslab.github.io/sams-notebook/2022/09/08/FastQ-Trimming-Geoduck-RNAseq-Data-Using-fastp-on-Mox.html) was aligned to our [_Panopea generosa_ (Pacific geoduck)](http://en.wikipedia.org/wiki/Geoduck) genome assembly, [Panopea-generosa-v1.0.fa](https://gannet.fish.washington.edu/Atumefaciens/20191105_swoose_pgen_v074_renaming/Panopea-generosa-v1.0.fa) (FastA; 914MB), using [`HISAT2`](https://daehwankimlab.github.io/hisat2/). Alternative transcripts and expression values were determined using [`StringTie`](https://ccb.jhu.edu/software/stringtie/). These were run on Mox.


---

#### RESULTS

Output folder:

- []()

