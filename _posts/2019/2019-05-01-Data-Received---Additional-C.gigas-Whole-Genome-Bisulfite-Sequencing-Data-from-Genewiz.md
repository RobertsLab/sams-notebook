---
layout: post
title: Data Received - Additional C.gigas Whole Genome Bisulfite Sequencing Data from Genewiz
date: '2019-05-01 11:06'
tags:
  - Crassostrea gigas
  - Pacific oyster
  - BSseq
  - bisulfite sequencing
  - genewiz
categories:
  - Miscellaneous
---
The [FastQC analysis](https://robertslab.github.io/sams-notebook/2019/04/15/FastQC-WGBS-Sequencing-Data-from-Genewiz-Received-20190408.html) of the intitial data we received from Genewiz ([on 20190408](https://robertslab.github.io/sams-notebook/2019/04/08/Data-Management-Whole-Genome-Bisulfite-Sequencing-Data-from-Genewiz-Received.html))showed consistent failures in the "Per Tile Sequence Quality" for all of Roberto's _Crassostrea gigas_ sequencing. After discussing with Genewiz, they offered to generate an additional 25% reads for each of those libraries.

The data became available today. The additional reads were appended to the previous sequencing results, so the filenames remain the same as before.

Data was downloaded to `owl/nightingales/C_gigas`:

http://owl.fish.washington.edu/nightingales/C_gigas/

Roberto's samples match the following filename pattern:

`[035]*.gz`


Will generate new FastQC analysis for these files. Since the additional data was simply appended to the previous data, I fully expect the "Per Tile Sequence Quality" to fail again. However, this additional data should help compensate for data loss we will experience after quality trimming.

---

#### Updated sequencing report:

| Table 2.1 Sample Sequencing Statistics |               |                  |          |                |                    |               |
|----------------------------------------|---------------|------------------|----------|----------------|--------------------|---------------|
|                                        |               |                  |          |                |                    |               |
| GENEWIZ NGS Data Report                |               |                  |          |                |                    |               |
|                                        |               |                  |          |                |                    |               |
| Project                                | Sample ID     | Barcode Sequence | # Reads  | Yield (Mbases) | Mean Quality Score | % Bases >= 30 |
| 30_183897003                           | Tank2-025-026 | GCCAAT           | 66223383 | 19867          | 37.04              | 87.98         |
| 30_183897003                           | 0502          | CAGATC           | 62707839 | 18813          | 35.43              | 82.96         |
| 30_183897003                           | 5201          | ACAGTG           | 60125207 | 18037          | 35.67              | 83.78         |
| 30_183897003                           | 3503          | CCGTCC           | 59836967 | 17951          | 35                 | 81.35         |
| 30_183897003                           | 5902          | AGTTCC           | 64657824 | 19397          | 35.43              | 83.09         |
| 30_183897003                           | 5202          | AGTCAA           | 54986647 | 16496          | 35.45              | 83.07         |
| 30_183897003                           | 3501          | TGACCA           | 59575535 | 17873          | 35.57              | 83.51         |
| 30_183897003                           | YRVL          | TGACCA           | 66590575 | 19977          | 37.05              | 87.99         |
| 30_183897003                           | 3502          | CTTGTA           | 62881856 | 18864          | 35.51              | 83.18         |
| 30_183897003                           | 5903          | GTGAAA           | 54173403 | 16252          | 37.06              | 88.07         |
| 30_183897003                           | 0503          | ATGTCA           | 60779896 | 18234          | 35.24              | 82.18         |
| 30_183897003                           | YRVA          | CGATGT           | 67542867 | 20263          | 37.1               | 88.14         |
| 30_183897003                           | Tank3-15-16   | ACAGTG           | 49500297 | 14850          | 36.96              | 87.73         |
| 30_183897003                           | 0501          | CGATGT           | 69631899 | 20890          | 35.42              | 83.2          |
| 30_183897003                           | 5203          | GTCCGC           | 63065336 | 18920          | 35.12              | 81.9          |
| 30_183897003                           | 5901          | GCCAAT           | 72859227 | 21858          | 35.42              | 82.92         |
