---
layout: post
title: Sample Submission - Tanner Crab Infected vs Uninfected RNAseq
date: '2019-05-21 11:51'
tags:
  - tanner crab
  - RNAseq
  - RNA
  - Chionoecetes bairdi
categories:
  - Tanner Crab RNAseq
  - Samples Submitted
---
After [reviewing our options for sample pooling](https://robertslab.github.io/sams-notebook/2019/05/14/Library-Decisions-C.bairdi-RNAs-for-Library-Pools.html), we decided to do a comparison of Infected vs. Uninfected crabs.

I pooled equal amounts of RNA from each individual in a given set (e.g. Day 9 Infected) to achieve 1000ng. Samples were concentrated using the Friedman Lab SpeedVac to target the "required" concentration specified by the sequencing facility (60ng/uL - [UW’s Northwest Genomics Center](https://nwgc.gs.washington.edu/)).

I put "required" in quotes because, it turns out, that the amount of total RNA _and_ the concentration are not actually _required_! Here's an email exchange when I asked if there was any wiggle room:

>Hi Sam,
>
Thank you for your questions. 1000ng is our "ideal" amount with a built-in 2nd run along the way just in case. We have received some samples with their volume too low to work with (regardless of concentration), but we can take how much ever you can give us.

I also tried to get them to commit to an absolute minimum for input RNA, but the correspondent just kind of talked around the question. Regardless, I submitted the sample manifest (see below) and they accepted it with samples below the "required" concentration and minimum amount of input RNA...

Samples will be sequenced on the NovaSeq S2 200 cycle flow cell with ~50M reads per sample.

NOTE: Used all of the following samples:

- 6279_13_9

- 6102_18_9

- 6115_33_9

- 6271_295_12

- 6212_485_26

Here's the manifest sample sheet I submitted:

| UDF/Investigator Sample Name | UDF/Replicate Sample Id | UDF/Organism        | UDF/Gender | UDF/Race | UDF/Concentration (ng\/uL) | UDF/Total Volume (uL) |
|------------------------------|-------------------------|---------------------|------------|----------|----------------------------|-----------------------|
|                              |                         |                     |            |          |                            |                       |
|                              |                         |                     |            |          |                            |                       |
| D9_infected                  |                         | Chionoecetes bairdi |            |          | 75                         | 10                    |
| D9_uninfected                |                         | Chionoecetes bairdi |            |          | 81                         | 10                    |
| D12_infected                 |                         | Chionoecetes bairdi |            |          | 57                         | 10                    |
| D12_uninfected               |                         | Chionoecetes bairdi |            |          | 74                         | 10                    |
| D26_infected                 |                         | Chionoecetes bairdi |            |          | 59                         | 10                    |
| D26_uninfected               |                         | Chionoecetes bairdi |            |          | 70                         | 10                    |


---

#### UPDATE 20190610

Sample QC came back. One sample failed QC (D26_infected), but I've told them to proceed with sequencing of all samples.

QC summary table supplied by NWGC (Google Sheet):

- [roberts_grc_rnaseq_2_QCResults_20190610](https://drive.google.com/file/d/0B2S_90rPaQMzNmVQZm51T0VjalBuWFMzR1NiMVJpUXdWdWsw/view?usp=sharing)

| Sample Note | NWGC Sample ID | Investigator Sample ID | Volume (ul) | Concentration (ng/ul) | Mass (ng) | QC Validation Pass/Fail |
|-------------|----------------|------------------------|-------------|-----------------------|-----------|-------------------------|
|             | 329772         | D9_infected            | 6.98        | 112.02                | 1005.95   | Pass                    |
|             | 329773         | D9_uninfected          | 8.18        | 114.42                | 1164.75   | Pass                    |
|             | 329774         | D12_infected           | 11.72       | 88.51                 | 1214.42   | Pass                    |
|             | 329775         | D12_uninfected         | 10.71       | 107.38                | 1364.77   | Pass                    |
| low mass    | 329776         | D26_infected           | 11.22       | 58.11                 | 768.25    | Fail                    |
|             | 329777         | D26_uninfected         | 11.11       | 97.32                 | 1275.92   | Pass                    |
