---
layout: post
title: RNA Isolation and Quantification - C.bairdi Hemolymph Pellets in RNAlater
date: '2020-01-17 14:44'
tags:
  - Tanner crab
  - RNA isolation
  - RNA quantification
  - Qubit
  - Chionoecetes bairdi
categories:
  - Tanner Crab RNAseq
---
TL;DR - Recovered absolutely no RNA from any sample! However, [I did recover DNA from each sample](https://robertslab.github.io/sams-notebook/2020/01/17/DNA-Isolation-and-Quantification-C.bairdi-Hemolymph-Pellets-in-RNAlater.html).


Isolated RNA from the following 23 hemolymph pellet samples:

-  6128_112_9
-  6204_114_9
-  6141_123_9
-  6245_126_9
-  6240_134_9
-  6260_136_9
-  6257_138_9
-  6259_139_9
-  6258_140_9
-  6255_143_9
-  6256_146_9
-  6265_155_9
-  6266_156_9
-  6261_164_9
-  6120_165_9
-  6251_167_9
-  6262_168_9
-  6243_173_9
-  6263_179_9
-  6264_180_9
-  6200_208_12
-  6204_252_12
-  6190_256_12

Isolated RNA using the [Quick DNA/RNA Microprep Kit](https://github.com/RobertsLab/resources/blob/master/protocols/Commercial_Protocols/ZymoResearch_quick-dna-rna_microprep_plus_kit_20190411.pdf) (ZymoResearch; PDF) according to the manufacturer's protocol for liquids/cells in RNAlater.

- Used 35uL from each RNAlater/hemocyte slurry.

- Mixed with equal volume of H<sub>2</sub>O (35uL).

- Retained DNA on the Zymo-Spin IC-XM columns for isolation after RNA isolation.

- Performed on-column DNase step.

- RNA was eluted in 15uL H<sub>2</sub>O

RNA was quantified on the Roberts Lab Qubit 3.0 using the RNA High Sensitivity Assay (Invitrogen), using 2uL of each sample.

---

#### RESULTS

Qubit results (Google Sheet):

- [20200117_qubit_cbai_RNA](https://docs.google.com/spreadsheets/d/1e4jrYEv5deHTEYwihof7CRzfuP8hArA8qCwRXtLjPEQ/edit?usp=sharing)

Well, none of these samples appear to have _any_ RNA in them! [The last time I did this, I started with 70uL of each sample](https://robertslab.github.io/sams-notebook/2019/04/30/RNA-Isolation-and-Quantification-C.bairdi-Hemolymph-Pellet-in-RNAlater.html) and had yields high enough that cutting the sample volume in half should still have yielded ample RNA. This makes me think I screwed something up, particularly since [I obtained DNA from each of the samples](https://robertslab.github.io/sams-notebook/2020/01/17/DNA-Isolation-and-Quantification-C.bairdi-Hemolymph-Pellets-in-RNAlater.html). However, I've reviewed all the steps and don't see anything obvious that I forgot/screwed up.

I could re-quantify these using a higher volume, but I think it's pointless. Samples that are too low for quantification on the Qubit are <1ng/uL. So, even if I were to increase the quantification volume to 5uL (i.e. 2.5x the volume I used initially), at _best_, the concentrations only be 2.5ng/uL. And, the the remaining volume of sample would be ~5uL; yielding 7.5ng of RNA in _total_. As such, I've discarded the samples and will attempt to re-isolate RNA from them.
