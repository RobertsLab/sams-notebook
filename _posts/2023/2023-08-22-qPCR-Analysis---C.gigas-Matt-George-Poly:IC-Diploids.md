---
layout: post
title: qPCR Analysis - C.gigas Matt George Poly:IC Diploids
date: '2023-08-22 18:56'
tags: 
  - qPCR
  - CFX Connect
  - Crassostrea gigas
  - diploid
  - Pacific oyster
categories: 
  - Miscellaneous
---
Ran a "quick and dirty" qPCR analysis for the qPCR's I'd previously run:

- [20230726](https://robertslab.github.io/sams-notebook/2023/07/26/qPCR-C.gigas-polyIC.html)

- [20230817](https://robertslab.github.io/sams-notebook/2023/08/17/qPCR-C.gigas-PolyIC-Diploid-MgCl2.html)

All analyses are documented in the following R Project:

- [20230822-cgig-polyIC-qPCR](https://github.com/RobertsLab/code/tree/master/r_projects/sam/20230822-cgig-polyIC-qPCR) (GitHub)

Here's a brief overview of what was done:

1. Select only diploid samples (currently, only have control/injected groups for diploids - not triploids)
2. Normalize to actin by calculating delta Cq.
  - This was done for the sake of time. Actin and GAPDH (the other normalizing gene run) shows evidence of a treatment effect. Actin was selected over GAPDH due to smaller range between mean Cqs of Control/Injected.
3. Run t-test to determine p-values between control/injected withing each actin-normalized gene.
4. Box plot all delta Cq values.
5. Calculate 2^<sup>(-delta delta Cq)</sup> (subtract Control delta Cq from Injected delta Cq) to determine fold change in expression for each gene.
6. Plot fold change in expression as bar plots. Values >1 indicate increase in relative expression. Values <1 indicate decrease in relative expression.



---

#### RESULTS

## Box Plots (delta Cq)

Box plots of delta Cq (i.e. normalize to Actin). T-test identified only a single gene (marked with orange asterisk) as significantly different between Control/Injected: DICER

![boxplots comparing 6 different genes - orange asterisk above Cg_DICER indicates statistically different between Control and Injected](https://github.com/RobertsLab/code/blob/master/r_projects/sam/20230822-cgig-polyIC-qPCR/output/01-qPCR-analysis/figures/diploid.delta-Cq.boxplots.jpg?raw=true)

---

## Fold Change (2<sup>-(ddCq)</sup>)

Fold change in gene expression of Injected individuals, relative to control samples.

![Bar plots showing fold change for each gene. Value > 1 means "upregulated"; value < 1 means "downregulated".](https://github.com/RobertsLab/code/blob/master/r_projects/sam/20230822-cgig-polyIC-qPCR/output/01-qPCR-analysis/figures/diploid.delta-delta-Cq.fold-change.barplots.jpg?raw=true)

