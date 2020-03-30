---
layout: post
title: RNAseq Reads Extractions - C.bairdi Taxonomic Reads Extractions with MEGAN6 on swoose
date: '2020-03-30 09:03'
tags:
  - Tanner crab
  - MEGAN6
  - taxonomy
  - swoose
  - Chionoecetes bairdi
  - Jupyter
categories:
  - Miscellaneous
---
[I previously annotated reads and converted them to the MEGAN6 format RMA6 on 20200318](https://robertslab.github.io/sams-notebook/2020/03/18/Transcriptome-Annotation-C.bairdi-Using-DIAMOND-BLASTx-on-Mox-and-MEGAN6-Meganizer-on-swoose.html).

I'll use the MEGAN6 GUI to "Open" the RMA6 file. Once the file loads, you get a nice looking taxonomic tree! From here, you can select any part of the taxonomic tree by right-clicking on the desired taxonomy and "Extract reads...". Here, you have the option to include "Summarized reads". This option allows you to extract just the reads that are part of the exact classification you've selected or all those within and "below" the classification you've selected (i.e. summarized reads).

Extracted reads will be generated as FastA files.

Example:

If you select _Arthropoda_ and _do not_ check the box for "Summarized Reads" you will _only get reads classified as Arthropoda_! You will not get any reads with more specific taxonomies. However, if you select _Arthropoda_ and you _do_ check the box for "Summarized Reads", you will get all reads classified as _Arthropoda_ _AND_ all reads in more specific taxonomic classifications, down to the species level.

I will extract reads from two phyla:

- _Arthropoda_ (for crabs)

- _Alveolata_ (for _Hematodinium_)

After read extractions using MEGAN6, I'll need to extract the actual reads from the trimmed FastQ files. This will actually entail extracting all trimmed reads from two different sets of RNAseq:

- [20191218_cbai_fastp_RNAseq_trimming/](https://gannet.fish.washington.edu/Atumefaciens/20191218_cbai_fastp_RNAseq_trimming/)

- [20200318_cbai_RNAseq_fastp_trimming/](https://gannet.fish.washington.edu/Atumefaciens/20200318_cbai_RNAseq_fastp_trimming/)

It's a bit convoluted, but I realized that the FastA headers were incomplete and did not distinguish between paired reads. Here's an example:

R1 FastQ header:

`@A00147:37:HG2WLDMXX:1:1101:5303:1000 1:N:0:AGGCGAAG+AGGCGAAG`

R2 FastQ header:

`@A00147:37:HG2WLDMXX:1:1101:5303:1000 2:N:0:AGGCGAAG+AGGCGAAG`

However, the reads extracted via MEGAN have FastA headers like this:

```
>A00147:37:HG2WLDMXX:1:1101:5303:1000
SEQUENCE1
>A00147:37:HG2WLDMXX:1:1101:5303:1000
SEQUENCE2
```

Those are a set of paired reads, but there's no way to distinguish between R1/R2. This may not be an issue, but I'm not sure how downstream programs (i.e. Trinity) will handle duplicate FastA IDs as inputs. To avoid any headaches, I've decided to parse out the corresponding FastQ reads which have the full header info.

Here's a brief rundown of the approach:

1. Create list of unique read headers from MEGAN6 FastA files.

2. Use list with `seqtk` program to pull out corresponding FastQ reads from the trimmed FastQ R1 and R2 files.

This aspect of read extractions/concatenations is documented in the following Jupyter notebook (GitHub):

- [20200330_swoose_cbai_megan_read_extractions.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20200330_swoose_cbai_megan_read_extractions.ipynb)


---

#### RESULTS

OUTPUT FOLDERS

Initial reads extracted as FastAs:

- [20200323_cbai_MEGAN_read_extractions/](https://gannet.fish.washington.edu/Atumefaciens/20200323_cbai_MEGAN_read_extractions/)

FastQ _C.bairdi_ read extractions:

- [20200330.C_bairdi_megan_reads/](https://gannet.fish.washington.edu/Atumefaciens/20200330.C_bairdi_megan_reads)

FastQ _Hematodinium_ read extractions:

- [20200330.Hematodinium_megan_reads](https://gannet.fish.washington.edu/Atumefaciens/20200330.Hematodinium_megan_reads)


#### Taxonomic Trees

##### 113

![113 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_113.png?raw=true)

---

##### 118

![118 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_118.png?raw=true)

---

##### 127

![127 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_127.png?raw=true)

---

##### 132

![132 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_132.png?raw=true)

---

##### 151

![151 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_151.png?raw=true)

---

##### 173

![173 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_173.png?raw=true)

---

##### 178

![178 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_178.png?raw=true)

---

##### 221

![221 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_221.png?raw=true)

---

##### 222

![222 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_222.png?raw=true)

---

##### 254

![254 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_254.png?raw=true)

---

##### 272

![272 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_272.png?raw=true)

---

##### 280

![280 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_280.png?raw=true)

---

##### 294

![294 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_294.png?raw=true)

---

##### 334

![334 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_334.png?raw=true)

---

##### 349

![349 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_349.png?raw=true)

---

##### 359

![359 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_359.png?raw=true)

---

##### 425

![425 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_425.png?raw=true)

---

##### 427

![427 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_427.png?raw=true)

---

##### 445

![445 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_445.png?raw=true)

---

##### 463

![463 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_463.png?raw=true)

---

##### 481

![481 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_481.png?raw=true)

---

##### 485

![485 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_485.png?raw=true)

---

##### 72

![72 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_72.png?raw=true)

---

##### 73

![73 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200323_cbai_MEGAN_read_extractions_73.png?raw=true)

---
