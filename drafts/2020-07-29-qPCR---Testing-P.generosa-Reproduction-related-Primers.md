---
layout: post
title: qPCR - Testing P.generosa Reproduction-related Primers
date: '2020-07-29 09:23'
tags:
  - geoduck
  - Panopea generosa
  - qPCR
  - CFX Connect
  - BioRad
  - 2x SsoFast Eva Green
categories:
  - Miscellaneous
---
[Ran some qPCRs on some other primers on 20200723](https://robertslab.github.io/sams-notebook/2020/07/23/qPCR-Testing-P.generosa-Reproduction-related-Primers.html) and then [Shelly has asked me to test some additional qPCR primers](https://github.com/RobertsLab/resources/issues/970) that might have acceptable melt curves and be usable as normalizing genes.


| SRID | Primer_name  |
|------|--------------|
| 1771 | TIF3s12_FWD  |
| 1770 | TIF3s12_REV  |
| 1759 | TIF3s8_FWD-1 |
| 1758 | TIF3s8_REV-1 |
| 1757 | TIF3s8_FWD-2 |
| 1756 | TIF3s8_REV-2 |

NOTE: I accidentally ran the qPCR with the `TIF3s8_FWD/REV-2` set, which we know is bad. So, had to perform another qPCR run with `TIF3s8_FWD/REV-1`. Doh!



Used pooled cDNA, created by combining 2uL from each of the following:

- 11-08 1H ([made by me from 20191125](https://robertslab.github.io/sams-notebook/2019/11/26/Reverse-Transcription-P.generosa-DNased-Hemolypmh-and-Hemocyte-RNA-from-20191125.html))
- 11-08 2H ([made by me from 20191125](https://robertslab.github.io/sams-notebook/2019/11/26/Reverse-Transcription-P.generosa-DNased-Hemolypmh-and-Hemocyte-RNA-from-20191125.html))
- 57H ([made by me from 20191125](https://robertslab.github.io/sams-notebook/2019/11/26/Reverse-Transcription-P.generosa-DNased-Hemolypmh-and-Hemocyte-RNA-from-20191125.html))
- 11/15 Chew (made by Kaitlyn, no date on tube)
- 11/21 Star (made by Kaitlyn, no date on tube)

I also used [geoduck gDNA (162ng/uL; from 20170105)](https://robertslab.github.io/sams-notebook/2017/01/05/dna-isolation-geoduck-gdna-for-illumina-initiated-sequencing-project.html) as a potential positive control, and/or as confirmation that these primers will not amplify gDNA.

All qPCR reactions were run in duplicate. See qPCR Report (Results section below) for plate layout, cycling params, etc.


Used the same master mix calcs from 20200723:

- [20200723_qPCR_geoduck_primer_tests](https://docs.google.com/spreadsheets/d/1DiZT-APed-cS99TYjaNbN5sc1bbdyokUit8zfvUuqjs/edit?usp=sharing) (Google Sheet)


---

#### RESULTS

qPCR Reports (PDF):

- [sam_2020-07-29_05-36-56_BR006896.pdf](https://owl.fish.washington.edu/Athaliana/qPCR_data/qPCR_reports/sam_2020-07-29_05-36-56_BR006896.pdf) (`TIF3s8_FWD/REV-2` and `TIF3s12_FWD/REV`)

- [sam_2020-07-29_06-54-35_BR00689.pdf](https://owl.fish.washington.edu/Athaliana/qPCR_data/qPCR_reports/sam_2020-07-29_06-54-35_BR00689.pdf) (`TIF3s8_FWD/REV-1`)

CFX Data Files (PCRD):

- [sam_2020-07-29_05-36-56_BR006896.pcrd](https://owl.fish.washington.edu/scaphapoda/qPCR_data/cfx_connect_data/sam_2020-07-29_05-36-56_BR006896.pcrd) (`TIF3s8_FWD/REV-2` and `TIF3s12_FWD/REV`)

- [sam_2020-07-29_06-54-35_BR006896.pcrd](https://owl.fish.washington.edu/scaphapoda/qPCR_data/cfx_connect_data/sam_2020-07-29_06-54-35_BR006896.pcrd) (`TIF3s8_FWD/REV-1`)

CFX Results Files (CSV):

- [sam_2020-07-29_05-36-56_BR006896-Quantification-Cq-Results.csv](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-07-29_05-36-56_BR006896-Quantification-Cq-Results.csv) (`TIF3s8_FWD/REV-2` and `TIF3s12_FWD/REV`)

- [sam_2020-07-29_06-54-35_BR00689_Quantification-Cq-Results.csv](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-07-29_06-54-35_BR00689_Quantification-Cq-Results.csv) (`TIF3s8_FWD/REV-1`)
