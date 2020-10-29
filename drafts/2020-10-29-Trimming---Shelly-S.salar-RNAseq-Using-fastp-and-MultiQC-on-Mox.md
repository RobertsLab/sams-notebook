---
layout: post
title: Trimming - Shelly S.salar RNAseq Using fastp and MultiQC on Mox
date: '2020-10-29 10:11'
tags:
  - Salmo salar
  - fastp
  - Atlantic slamon
  - RNAseq
  - trimming
  - mox
  - MultiQC
categories:
  - Miscellaneous
---



---

#### RESULTS

Cumulative runtime for `fastp` and `MultiQC` was very fast; ~18mins:

![Cumulative runtime for `fastp` and `MultiQC`](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201029_ssal_RNAseq_fastp_trimming_runtime.png?raw=true)

NOTE: Despite the "FAILED" indication, the script ran to completion. The last command in the script is a redundant file removal step, which triggered the script "failure". Left the command in the SBATCH script above for reproducibility.

Output folder:

- []()
