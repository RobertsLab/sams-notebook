---
layout: post
title: RNAseq Reads Extractions - C.bairdi Taxonomic Reads Extractions with MEGAN6 on swoose
date: '2020-04-19 12:10'
tags:
  - Tanner crab
  - MEGAN6
  - taxonomy
  - swoose
  - Jupyter
  - Hematodinium
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
After [receiving our final set of RNAseq data from NWGSC earlier today](https://robertslab.github.io/sams-notebook/2020/04/13/Data-Received-C.bairdi-RNAseq-from-NWGSC.html), I need to trim and check trimmed reads with FastQC/MultiQC.

`fastp` trimming was run on Mox, followed by MultiQC.

FastQC on trimmed reads were run Mox, followed by MultiQC.

SBATCH script (GitHub):

- [20200318_cbai_RNAseq_fastp_trimming.sh]()

```shell

```



---

#### RESULTS

Run time was just under three hours:

![fastp runtime screencap]()

NOTE: Although the job indicates "FAILED", this was simply due to a MultiQC failing (path to MultiQC was incorrect). Trimming proceeded/completed properly.

Output folder:

- []()

fastp MultiQC report (HTML):

- []()

Individual fastp reports are also available (HTML). An example is below.



FastQC MultiQC report (HTML):

- []()
