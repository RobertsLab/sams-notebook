---
layout: post
title: Trimming - Ronits C.gigas Ploidy WGBS 10bp 5 and 3 Prime Ends Using fastp and MultiQC on Mox
date: '2020-12-02 16:19'
tags:
  - WGBS
  - BSseq
  - mox
  - fastp
  - multiqc
  - Crassostrea gigas
  - Pacific oyster
categories:
  - Miscellaneous
---
[Steven asked me to trim](https://github.com/RobertsLab/resources/issues/1039) (GitHub Issue) Ronit's WGBS sequencing data we [received on 20201110](https://robertslab.github.io/sams-notebook/2020/11/10/Data-Received-C.gigas-Ploidy-WGBS-from-Ronits-Project-via-ZymoResearch.html), according to [`Bismark`](https://github.com/FelixKrueger/Bismark) guidelines for [libraries made with the ZymoResearch Pico MethylSeq Kit](https://github.com/FelixKrueger/Bismark/blob/master/Docs/README.md#ix-notes-about-different-library-types-and-commercial-kits).

I trimmed the files using [`fastp`](https://github.com/OpenGene/fastp).

The trimming trims adapters and 10bp from _both_ the 5' and 3' ends of each read.

I [previously ran a trimming where I trimmed only from the 5' end](https://robertslab.github.io/sams-notebook/2020/11/30/Trimming-Ronits-C.gigas-Ploidy-WGBS-Using-fastp-and-MultiQC-on-Mox.html). Reading the [`Bismark`](https://github.com/FelixKrueger/Bismark) documentation more carefully, the documentation suggests that a user "should probably perform 3' trimming". So, I'm doing that here.

Job was run on Mox.

SBATCH script (GitHub):

- []()

---

#### RESULTS

Runtime was actually faster than just the 10bp 5' trimming from the other day; just over 2hrs:

![fastp runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201202_cgig_fastp-10bp-5-3-prime_ronit-ploidy-wgbs_runtime.png?raw=true)

Output folder:

- []()
