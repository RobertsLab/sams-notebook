---
layout: post
title: Sequence Extractions - C.bairdi Transcriptomes v2.0 and v3.0 Excluding Alveolata with MEGAN6 on Swoose
date: '2020-06-05 09:40'
tags:
  - Chionoecetes bairdi
  - Tanner crab
  - MEGAN6
  - transcriptome
  - taxonomy
  - swoose
categories:
  - Miscellaneous
---
Continuing to try to identify the best [_C.bairdi_ transcriptome](https://github.com/RobertsLab/resources/wiki/Genomic-Resources#transcriptomes), we decided to extract all non-dinoflagellate sequences from `cbai_transcriptome_v2.0` (RNAseq shorthand: 2018, 2019, 2020-GW, 2020-UW) and `cbai_transcriptome_v3.0` (RNAseq shorthand: 2018, 2019, 2020-UW). Both of these transcriptomes were assembled _without_ any taxonomic filter applied. [DIAMOND BLASTx and conversion to MEGAN6 RMA6 files was performed yesterday (20200604)](https://robertslab.github.io/sams-notebook/2020/06/04/Transcriptome-Annotation-C.bairdi-Transcriptomes-v2.0-and-v3.0-with-DIAMOND-BLASTx-on-Mox.html).

Will import RMA6 files into MEGAN6 and extract all _non_Alveolata_ (dinoflagellates) sequences to create new transcriptomes. The new transcriptomes will be named `cbai_transcriptome_v2.1` and `cbai_transcriptome_v3.1`. I'll also extract _only Alveolata_ sequences to generate a _Hematodinium sp._ transcriptome.


---

#### RESULTS

Output folder:

- [20200605_cbai_v2.0_v3.0_megan_seq_extractions](https://gannet.fish.washington.edu/Atumefaciens/20200605_cbai_v2.0_v3.0_megan_seq_extractions/)

- [20200605_cbai_v2.0_v3.0_megan_seq_extractions/megan_log.txt](https://gannet.fish.washington.edu/Atumefaciens/20200605_cbai_v2.0_v3.0_megan_seq_extractions/megan_log.txt)

---

##### _C.bairdi_ Transcritpomes:

- [cbai_transcriptome_v2.1.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200605_cbai_v2.0_v3.0_megan_seq_extractions/cbai_transcriptome_v2.1.fasta) (241MB)

- [cbai_transcriptome_v3.1.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200605_cbai_v2.0_v3.0_megan_seq_extractions/cbai_transcriptome_v3.1.fasta) (139MB)

---

##### _Hematodinium sp._ Transcriptomes:

- [hemat_transcriptome_v2.1.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200605_cbai_v2.0_v3.0_megan_seq_extractions/hemat_transcriptome_v2.1.fasta) (65MB)

- [hemat_transcriptome_v3.1.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200605_cbai_v2.0_v3.0_megan_seq_extractions/hemat_transcriptome_v3.1.fasta) (65MB)

---

Screenshots of taxonomic trees in MEGAN6 used to extract sequences for each new transcriptome:

#### `cbai_transcriptome_v2.0 MEGAN non-Alveolota taxonomic tree`

![cbai_transcriptome_v2.0 MEGAN non-alveolota taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200605_cbai_v2.0_megan_non-alveolata_seq_extractions.png?raw=true)

---


#### `cbai_transcriptome_v3.0 MEGAN non-Alveolota taxonomic tree`

![cbai_transcriptome_v3.0 MEGAN non-alveolota taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200605_cbai_v3.0_megan_non-alveolata_seq_extractions.png?raw=true)

---

#### `hemat_transcriptome_v2.0 MEGAN Alveolata only taxonomic tree`

![hemat_transcriptome_v2.0 MEGAN Alveolata only taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200605_cbai_v2.0_megan_alveolata_seq_extractions.png?raw=true)

---

#### `hemat_transcriptome_v3.0 MEGAN Alveolata only taxonomic tree`

![hemat_transcriptome_v3.0 MEGAN Alveolata only taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200605_cbai_v3.0_megan_alveolata_seq_extractions.png?raw=true)


The transcriptomes will be added to our [Genomic Resources wiki](https://github.com/RobertsLab/resources/wiki/Genomic-Resources). Next up is to run BUSCO and generate BUSCO comparisons to previous transcriptome assemblies.
