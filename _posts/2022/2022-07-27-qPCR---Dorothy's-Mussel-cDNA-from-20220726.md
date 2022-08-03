---
layout: post
title: qPCR - Dorothys Mussel cDNA from 20220726
date: '2022-07-27 15:36'
tags: 
  - qPCR
  - mussel
  - cDNA
categories: 
  - Miscellaneous
---
Ran qPCRs on Dorothy's mussel gill cDNA [from 20220726](https://robertslab.github.io/sams-notebook/2022/07/26/RNA-Isolation-and-Quantification-Dorothy-Mussel-Gill-Samples.html) using the following primers:

| SRID | Primer name        |
|------|--------------------|
| 1821 | Mg_MT10_F          |
| 1820 | Mg_MT10_R          |
| 1819 | Mg_MT20_F          |
| 1818 | Mg_MT20_R          |
| 1817 | Mg_small HSP24.1_F |
| 1816 | Mg_small HSP24.1_R |
| 1815 | Mg_SQSTM1_F        |
| 1814 | Mg_SQSTM1_R        |
| 1813 | Mg_HSC70_F         |
| 1812 | Mg_HSC70_R         |
| 1811 | Mg_HSP90_F         |
| 1810 | Mg_HSP90_R         |
| 1809 | Mg_ferritin_F      |
| 1808 | Mg_ferritin_R      |
| 1807 | Mg_GADD45 gamma_F  |
| 1806 | Mg_GADD45 gamma_R  |

`Mg_GADD45_gamma_F/R` primers were run in triplicate. After discussion with Steven, it was determined that duplicates would be sufficient for the time being, so all other primers were run in duplicate.

All reactions were run with 2x Sso Fast EVAgreen Master Mix (BioRad) using with the following master mix calcs (Google Sheet):

- [20220727 - qPCR Calcs Dorothy Mussel Gill cDNA](https://docs.google.com/spreadsheets/d/1tF5WOptVVdNRjEhjoS5WA6jcSIMiNNmDf9jsBcncUKI/edit?usp=sharing)

All reactions were run in white, low profile PCR plates, using optically clear adhesive film on a CFX Connect thermal cycler (BioRad). See RESULTS below for cycling params.

---

#### RESULTS

`Mg_ferritin` did not produce any amplification. Will likely re-run just to ensure there wasn't an error when creating the master mix (i.e. forgot to add primer(s)?).

The plate with `Mg_HSC70` and `Mg_small HSP24.1` should be reviewed to examine melt curves, as it appears there is some non-specific amplification occurring.

Additionally, it appears that `Mg_HSC70` is expressed highly and stably. As such, this might be a good candidate for a normalizing gene despite our interest in its response to heat stress.



#### Output folders:

Mg_GADD45 gamma

  - CFX Data File (Requires CFX Maestro software)
  
    - [sam_2022-07-27 10-02-05_BR006896.pcrd](https://owl.fish.washington.edu/scaphapoda/qPCR_data/cfx_connect_data//sam_2022-07-27%2010-02-05_BR006896.pcrd)

  - qPCR Data (CSV)

    - [sam_2022-07-27-10-02-05_BR006896-Quantification_Cq_Results.csv](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2022-07-27-10-02-05_BR006896-Quantification_Cq_Results.csv)

  - qPCR Report (PDF)

    - [sam_2022-07-27 11-15-14_BR006896.pdf](https://owl.fish.washington.edu/Athaliana/qPCR_data/qPCR_reports/sam_2022-07-27%2011-15-14_BR006896.pdf)

  Mg_HSC70 & Mg_small HSP24.1
  
  - CFX Data File (Requires CFX Maestro software)
  
    - [sam_2022-07-27 11-15-14_BR006896.pcrd](https://owl.fish.washington.edu/scaphapoda/qPCR_data/cfx_connect_data//sam_2022-07-27%2011-15-14_BR006896.pcrd)

  - qPCR Data (CSV)

    - [sam_2022-07-27-11-15-14_BR006896-Quantification_Cq_Results.csv](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2022-07-27-11-15-14_BR006896-Quantification_Cq_Results.csv)

  - qPCR Report (PDF)

    - [sam_2022-07-27-12-31-17_BR006896.pdf](https://owl.fish.washington.edu/Athaliana/qPCR_data/qPCR_reports/sam_2022-07-27-12-31-17_BR006896.pdf)

  Mg_MT10 & Mg_MT20
  
  - CFX Data File (Requires CFX Maestro software)
  
    - [sam_2022-07-27 12-31-17_BR006896.pcrd](https://owl.fish.washington.edu/scaphapoda/qPCR_data/cfx_connect_data//sam_2022-07-27%2012-31-17_BR006896.pcrd)

  - qPCR Data (CSV)

    - [sam_2022-07-27-12-31-17_BR006896-Quantification_Cq_Results.csv](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2022-07-27-12-31-17_BR006896-Quantification_Cq_Results.csv)

  - qPCR Report (PDF)

    - [sam_2022-07-27-13-23-11_BR006896.pdf](https://owl.fish.washington.edu/Athaliana/qPCR_data/qPCR_reports/sam_2022-07-27-13-23-11_BR006896.pdf)

Mg_HSP90 & Mg_SQSMT1
  
  - CFX Data File (Requires CFX Maestro software)
  
    - [sam_2022-07-27 13-23-11_BR006896.pcrd](https://owl.fish.washington.edu/scaphapoda/qPCR_data/cfx_connect_data//sam_2022-07-27%2013-23-11_BR006896.pcrd)

  - qPCR Data (CSV)

    - [sam_2022-07-27-13-23-11_BR006896-Quantification_Cq_Results.csv](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2022-07-27-13-23-11_BR006896-Quantification_Cq_Results.csv)

  - qPCR Report (PDF)

    - [sam_2022-07-27-14-17-42_BR006896.pdf](https://owl.fish.washington.edu/Athaliana/qPCR_data/qPCR_reports/sam_2022-07-27-14-17-42_BR006896.pdf)

Mg_ferritin
  
  - CFX Data File (Requires CFX Maestro software)
  
    - [sam_2022-07-27 14-17-42_BR006896.pcrd](https://owl.fish.washington.edu/scaphapoda/qPCR_data/cfx_connect_data//sam_2022-07-27%2014-17-42_BR006896.pcrd)

  - qPCR Data (CSV)

    - [sam_2022-07-27-14-17-42_BR006896-Quantification_Cq_Results.csv](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2022-07-27-14-17-42_BR006896-Quantification_Cq_Results.csv)

