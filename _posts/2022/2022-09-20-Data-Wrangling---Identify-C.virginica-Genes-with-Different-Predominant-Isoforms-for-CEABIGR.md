---
layout: post
title: Data Wrangling - Identify C.virginica Genes with Different Predominant Isoforms for CEABIGR
date: '2022-09-20 16:52'
tags: 
  - Crassostrea virginica
  - Eastern oyster
  - jupyter
  - ceabigr
categories: 
  - CEABIGR
---
During today's discussion, Yaamini recommended we generate a list of genes with different predominant isoforms between females and males, while also adding a column with a binary indicator (e.g. `0` or `1`) to mark those genes which were _not_ different (`0`) or _were_ different (`1`) between sexes. Steven had already generated files identifying predominant isoforms in each sex:

- [predom_iso-FEMALE.txt](https://github.com/sr320/ceabigr/blob/main/output/42-predominant-isoform/predom_iso-FEMALE.txt) (GitHub)

- [predom_iso-MALE.txt](https://github.com/sr320/ceabigr/blob/main/output/42-predominant-isoform/predom_iso-MALE.txt)


I wrangled the data in a Jupyter Notebook:

- [20220920-cvir-ceabigr-predominant_isoform-female_male.ipynb](https://github.com/sr320/ceabigr/blob/main/code/20220920-cvir-ceabigr-predominant_isoform-female_male.ipynb) (GitHub)

- [20220920-cvir-ceabigr-predominant_isoform-female_male.ipynb](https://nbviewer.org/github/sr320/ceabigr/blob/main/code/20220920-cvir-ceabigr-predominant_isoform-female_male.ipynb) (NBviewer)

---

#### RESULTS

Output files are available in the [ceabigr repo](https://github.com/sr320/ceabigr/tree/main/output/42-predominant-isoform).

Identified 4090 genes which had different predominant isoforms between sexes.

