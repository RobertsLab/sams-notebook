---
layout: post
title: Data Received - C.gigas Diploid-Triploid pH Treatments Ctenidia WGBS from ZymoResearch
date: '2020-12-05 14:06'
tags:
  - wgbs
  - BSseq
  - bisuflite
  - Crassostrea gigas
  - Pacific oyster
  - triploid
  - diploid
  - pH
  - Hawes
categories:
  - Data Received
---
Today we received the whole genome bisulfite sequencing (WGBS) from the [24 _C.gigas_ diploid-triploid samples subjected to different pH that were submitted 20200824](https://robertslab.github.io/sams-notebook/2020/08/24/Sample-Submitted-C.gigas-Diploid-Triploid-pH-Treatments-Ctenidia-to-ZymoResearch-for-WGBS.html. The lengthy turnaround time was due to a bad lot of reagents, which forced them Zymo to find a different manufacturer in order to generate libraries.

Sequencing consisted of WGBS 150bp paired end (PE) reads for each library. All files were downloaded to the [`C_gigas` folder on Owl](https://owl.fish.washington.edu/nightingales/C_gigas/)(Synology server). MD5 checksums were confirmed:

![screencap of md5 checksum verification](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201205_cgig_md5-verification_zr3644-fastqs.png?raw=true)

Principal spreadsheet for this project was updated (Google Sheet):

- [20200816_hawaii_ploidy_samples](https://drive.google.com/file/d/1wd0iHe78s_1u7NYa9HUlRIOX59QpAtXA/view?usp=sharing)

Have added files to our high-throughput sequencing database (Google Sheet):

- [nightingales](https://b.link/nightingales)

Next up:

- [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)

- Submit to NCBI sequence read archive (SRA).



| Zymo_ID   | Sample_ID | Ploidy   | pH_treatment |
|-----------|-----------|----------|--------------|
| zr3644_1  | 2N_HI_5   | diploid  | high         |
| zr3644_2  | 2N_HI_8   | diploid  | high         |
| zr3644_3  | 2N_HI_9   | diploid  | high         |
| zr3644_4  | 2N_HI_10  | diploid  | high         |
| zr3644_5  | 2N_HI_11  | diploid  | high         |
| zr3644_6  | 2N_HI_12  | diploid  | high         |
| zr3644_7  | 2N_LOW_1  | diploid  | low          |
| zr3644_8  | 2N_LOW_2  | diploid  | low          |
| zr3644_9  | 2N_LOW_3  | diploid  | low          |
| zr3644_10 | 2N_LOW_4  | diploid  | low          |
| zr3644_11 | 2N_LOW_5  | diploid  | low          |
| zr3644_12 | 2N_LOW_6  | diploid  | low          |
| zr3644_13 | 3N_HI_2   | triploid | high         |
| zr3644_14 | 3N_HI_3   | triploid | high         |
| zr3644_15 | 3N_HI_5   | triploid | high         |
| zr3644_16 | 3N_HI_8   | triploid | high         |
| zr3644_17 | 3N_HI_10  | triploid | high         |
| zr3644_18 | 3N_HI_11  | triploid | high         |
| zr3644_19 | 3N_LOW_6  | triploid | low          |
| zr3644_20 | 3N_LOW_7  | triploid | low          |
| zr3644_21 | 3N_LOW_8  | triploid | low          |
| zr3644_22 | 3N_LOW_10 | triploid | low          |
| zr3644_23 | 3N_LOW_11 | triploid | low          |
| zr3644_24 | 3N_LOW_12 | triploid | low          |
