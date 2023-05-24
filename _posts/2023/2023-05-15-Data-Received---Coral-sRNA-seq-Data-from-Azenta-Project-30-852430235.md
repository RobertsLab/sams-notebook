---
layout: post
title: Data Received - Coral sRNA-seq Data from Azenta Project 30-852430235
date: '2023-05-15 13:12'
tags: 
  - 30-852430235
  - sRNA-seq
  - Azenta
  - coral
  - Putnam
categories: 
  - Data Received
---
Small RNA-seq (sRNA-seq) data was made available from the coral E5 Azenta project 30-852430235. Sample sheet is below.

NOTE: Two samples (` POR-71-S1-TP2`, `POR-76-S1-TP2`) were unable to be sequenced due to failed library prep. This [was acknowledged and approved on 20230511 in this GitHub Issue](https://github.com/RobertsLab/resources/issues/1632#issuecomment-1544480844).

| Sample Name*   | Species/Strain*       |
|----------------|-----------------------|
| POR-73-S1-TP2  | Porites evermanni     |
| POR-79-S1-TP2  | Porites evermanni     |
| POR-82-S1-TP2  | Porites evermanni     |
| POC-47-S1-TP2  | Pocillopora meandrina |
| POC-48-S1-TP2  | Pocillopora meandrina |
| POC-50-S1-TP2  | Pocillopora meandrina |
| POC-53-S1-TP2  | Pocillopora meandrina |
| POC-57-S1-TP2  | Pocillopora meandrina |
| ACR-140-S1-TP2 | Acropora pulchra      |
| ACR-145-S1-TP2 | Acropora pulchra      |
| ACR-150-S1-TP2 | Acropora pulchra      |
| ACR-173-S1-TP2 | Acropora pulchra      |
| ACR-178-S1-TP2 | Acropora pulchra      |

Retrieval of data via sFTP took literally all day. Connection between Owl and Azenta servers was spotty at best, with frequent disconnects leading to partial downloads of files. Additionally, after all files had been downloaded, many failed MD5 checksum verification.


---

#### RESULTS

I will _not_ be linking the output folder in this post, as these files will require a bit or reorganization to help keep them straight. I will create new notebook post(s) detailing the final resting spots for these files.

![Screencap showing successful MD5 checksum verifications for all downloaded sRNA-seq data.](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20230515-coral-sRNAseq-checksums-screenshot.png?raw=true)

