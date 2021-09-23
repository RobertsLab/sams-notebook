---
layout: post
title: Data Received - C.bairdi RNAseq Day9-12-26 Infected-Uninfected
date: '2019-10-24 09:56'
tags:
  - tanner crab
  - RNAseq
  - Chionoecetes bairdi
categories:
  - Tanner Crab RNAseq
  - Data Received
---
Previously, we "received" this data, but it turns out it was incomplete ([see 20191003](https://robertslab.github.io/sams-notebook/2019/10/03/Data-Received-C.bairdi-RNAseq-Day9-12-26-Infected-Uninfected.html)).

Today, we _finally_ received _all_ the RNAseq data (>50M reads per samples) back from NWGC that we submitted on [20190521](https://robertslab.github.io/sams-notebook/2019/05/21/Sample-Submission-Tanner-Crab-Infected-vs-Uninfected-RNAseq.html)!

The second round of data is _in addition_ to the data we received on [20191003](https://robertslab.github.io/sams-notebook/2019/10/03/Data-Received-C.bairdi-RNAseq-Day9-12-26-Infected-Uninfected.html). So, to simplify some of the data management and downstream processing of these files, I decided to concatenate the two sets of file. Concatenation is documented in this Jupyter Notebook (GitHub):

- [20191024_swoose_cbai_fastq_concatenation.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20191024_swoose_cbai_fastq_concatenation.ipynb)

Here's a table with the library names and the FastQ naming schemes.


| NWGC Sample ID | Investigator Sample ID |
|----------------|------------------------|
| ~~329772~~         | ~~D9_infected~~            |
| ~~329773~~         | ~~D9_uninfected~~          |
| 329774         | D12_infected           |
| 329775         | D12_uninfected         |
| 329776         | D26_infected           |
| 329777         | D26_uninfected         |

The two samples with strikeouts  above failed sequencing. See the previous post from [20191003](https://robertslab.github.io/sams-notebook/2019/10/03/Data-Received-C.bairdi-RNAseq-Day9-12-26-Infected-Uninfected.html) about data delivery for all the info on those two samples.

---

Here's the list of FastQ files:

- 329774_S1_L001_R1_001.fastq.gz

- 329774_S1_L001_R2_001.fastq.gz

- 329774_S1_L002_R1_001.fastq.gz

- 329774_S1_L002_R2_001.fastq.gz

- 329775_S2_L001_R1_001.fastq.gz

- 329775_S2_L001_R2_001.fastq.gz

- 329775_S2_L002_R1_001.fastq.gz

- 329775_S2_L002_R2_001.fastq.gz

- 329776_S3_L001_R1_001.fastq.gz

- 329776_S3_L001_R2_001.fastq.gz

- 329776_S3_L002_R1_001.fastq.gz

- 329776_S3_L002_R2_001.fastq.gz

- 329777_S4_L001_R1_001.fastq.gz

- 329777_S4_L001_R2_001.fastq.gz

- 329777_S4_L002_R1_001.fastq.gz

- 329777_S4_L002_R2_001.fastq.gz


All files have been added to nightingales/C_bairdi:

- [nightingales/C_bairdi](https://owl.fish.washington.edu/nightingales/C_bairdi/)

Will update nightingales/C_bairdi/readme.txt and [Nightingales Google sheet](http://b.link/nightingales)
