---
layout: post
title: qPCR - Testing P.generosa Reproduction-related Primers
date: '2020-07-23 09:40'
tags:
  - qPCR
  - CFX
  - BioRad
  - Panopea generosa
  - geoduck
categories:
  - Miscellaneous
---
[Shelly has asked me to test some qPCR primers](https://github.com/RobertsLab/resources/issues/864) related to geoduck reproduction.


Table of SRIDs and primer name (sorted by primer name):

| SRID | Primer_Name |
|------|-------------|
| 1769 | APLP_FWD    |
| 1768 | APLP_REV    |
| 1761 | GSK3B_FWD   |
| 1760 | GSK3B_REV   |
| 1763 | NFIP1_FWD   |
| 1762 | NFIP1_REV   |
| 1745 | RPL5_FWD    |
| 1744 | RPL5_REV    |
| 1747 | SPTN1_FWD   |
| 1746 | SPTN1_REV   |
| 1773 | TIF3s6b_FWD |
| 1772 | TIF3s6b_REV |

Used pooled cDNA, created by combining 2uL from each of the following:

- 11-08 1H ([made by me from 20191125](https://robertslab.github.io/sams-notebook/2019/11/26/Reverse-Transcription-P.generosa-DNased-Hemolypmh-and-Hemocyte-RNA-from-20191125.html))
- 11-08 2H ([made by me from 20191125](https://robertslab.github.io/sams-notebook/2019/11/26/Reverse-Transcription-P.generosa-DNased-Hemolypmh-and-Hemocyte-RNA-from-20191125.html))
- 57H ([made by me from 20191125](https://robertslab.github.io/sams-notebook/2019/11/26/Reverse-Transcription-P.generosa-DNased-Hemolypmh-and-Hemocyte-RNA-from-20191125.html))
- 11/15 Chew (made by Kaitlyn, no date on tube)
- 11/21 Star (made by Kaitlyn, no date on tube)

I also used [geoduck gDNA (162ng/uL; from 20170105)](https://robertslab.github.io/sams-notebook/2017/01/05/dna-isolation-geoduck-gdna-for-illumina-initiated-sequencing-project.html) as a potential positive control, and/or as confirmation that these primers will not amplify gDNA.

All qPCR reactions were run in duplicate. See qPCR Report (Results section below) for plate layout, cycling params, etc.


Master mix calcs are here:

- [20200723_qPCR_geoduck_primer_tests](https://docs.google.com/spreadsheets/d/1DiZT-APed-cS99TYjaNbN5sc1bbdyokUit8zfvUuqjs/edit?usp=sharing) (Google Sheet)


---

#### RESULTS

qPCR Report (PDF):

- [sam_2020-07-23_09-33-48_BR006896.pdf](https://owl.fish.washington.edu/Athaliana/qPCR_data/qPCR_reports/sam_2020-07-23_09-33-48_BR006896.pdf)

CFX Data File (PCRD):

- [sam_2020-07-23%2009-33-48_BR006896.pcrd](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-07-23%2009-33-48_BR006896.pcrd)


CFX Results File (CSV):

- [sam_2020-07-23_09-33-48_BR006896-Quantification-Cq-Results.csv](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-07-23_09-33-48_BR006896-Quantification-Cq-Results.csv)


#### Amplifcation plots

![Amplifcation plots](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-07-23%2009-33-48_amp_plots.png)

#### Melt curves
![Melt curves](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-07-23%2009-33-48_melt_plots.png)
