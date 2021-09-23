---
layout: post
title: RNA Isolation and Quantification - C.bairdi Hemocyte Pellets in RNAlater Troubleshooting
date: '2020-01-23 09:59'
tags:
  - Chionoecetes bairdi
  - Tanner crab
  - RNA
  - DNased RNA
  - Quick DNA-RNA Microprep
  - Qubit3.0
  - Qubit hsRNA assay
categories:
  - Tanner Crab RNAseq
---
[After the failure to obtain RNA from _any_ _C.bairdi_ hemocytes pellets (out of 24 samples processed) on 20200117](https://robertslab.github.io/sams-notebook/2020/01/17/RNA-Isolation-and-Quantification-C.bairdi-Hemolymph-Pellets-in-RNAlater.html), I decided to isolate RNA from just a subset of that group to determine if I screwed something up last time or something. Also, I am testing two different preparations of the kit-supplied DNase I: one Kaitlyn prepped and a fresh preparation that I made. Admittedly, I'm not doing the "proper" testing by trying the different DNase preps on the same exact sample, but it'll do. I just want to see if I get some RNA from these samples this time...

Isolated RNA from the following 4 hemolymph pellet samples:

- 6128_112_9 (Kaitlyn DNase)
- 6204_114_9 (Kaitlyn DNase)
- 6141_123_9 (Sam DNase)
- 6245_126_9 (Sam DNase)

Isolated RNA using the [Quick DNA/RNA Microprep Kit](https://github.com/RobertsLab/resources/blob/master/protocols/Commercial_Protocols/ZymoResearch_quick-dna-rna_microprep_plus_kit_20190411.pdf) (ZymoResearch; PDF) according to the manufacturer's protocol for liquids/cells in RNAlater.

- Used 35uL from each RNAlater/hemocyte slurry.

- Mixed with equal volume of H<sub>2</sub>O (35uL).

- Retained DNA on the Zymo-Spin IC-XM columns for isolation after RNA isolation.

- Performed on-column DNase step.

- RNA was eluted in 15uL H<sub>2</sub>O

RNA was quantified on the Roberts Lab Qubit 3.0 using the RNA High Sensitivity Assay (Invitrogen), using 2uL of each sample.

---

#### RESULTS

Qubit restuls (Google Sheet):

- [20200123_qubit_cbai_RNA](https://docs.google.com/spreadsheets/d/1Ka90NEt3kHtSU0dSBCZYAiQQL-u3O5c1Y56rqG-Luz8/edit?usp=sharing)

| Sample ID  | [RNA] (ng/uL) | Total (ng) |
|------------|---------------|------------|
| 6128_112_9 | 17.1          | 222.3      |
| 6204_114_9 | 5.37          | 69.81      |
| 6141_123_9 | 13.1          | 170.3      |
| 6245_126_9 | 17.2          | 223.6      |


Well, well, well! The isolation worked this time! Not sure what went wrong last time. Ugh. However, I'm stoked that things worked and will now plow ahead with the remainder of the samples (again)!
