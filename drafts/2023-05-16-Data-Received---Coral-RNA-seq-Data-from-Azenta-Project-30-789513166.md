---
layout: post
title: Data Received - Coral RNA-seq Data from Azenta Project 30-789513166
date: '2023-05-16 07:15'
tags: 
  - 30-789513166
  - RNA-seq
  - Azenta
  - coral
  - Putnam
categories: 
  - Data Received
---
Small RNA-seq (sRNA-seq) data was made available from the coral E5 Azenta project 30-789513166. Sample sheet:

| Sample Name*   | Species/Strain*       |
|----------------|-----------------------|
| POR-71-S1-TP2  | Porites evermanni     |
| POR-73-S1-TP2  | Porites evermanni     |
| POR-76-S1-TP2  | Porites evermanni     |
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

![Screencap showing successful MD5 checksum verifications for all downloaded RNA-seq data.](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20230516-coral-sRNAseq-checksums-screenshot.png?raw=true)

