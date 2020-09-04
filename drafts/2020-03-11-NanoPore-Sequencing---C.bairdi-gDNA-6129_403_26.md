---
layout: post
title: NanoPore Sequencing - C.bairdi gDNA 6129_403_26
date: '2020-03-11 08:43'
tags:
  - nanopore
  - Tanner crab
  - sequencing
  - Chionoecetes bairdi
  - DNA
categories:
  - Miscellaneous
---
After getting [high quality gDNA from _Hematodinium_-infected _C.bairdi_ hemolymph on 2020210](https://robertslab.github.io/sams-notebook/2020/02/10/DNA-Isolation,-Quantification,-and-Gel-C.bairdi-gDNA-Sample-6129_403_26.html) we decided to run some of the sample on the NanoPore MinION, since the flowcells have a very short shelf life. Additionally, the results from this will also help inform us on whether this sample might worth submitting for PacBio sequencing. And, of course, this provides us with additional sequencing data to complement our [previous NanoPore runs from 20200109](https://robertslab.github.io/sams-notebook/2020/01/09/NanoPore-Sequencing-C.bairdi-gDNA-Sample-20102558-2729.html).

The sample DNA was prepared according to [the protocol for the Rapid Sequencing Kit (SQK-RAD004)](https://github.com/RobertsLab/resources/blob/master/protocols/Commercial_Protocols/Nanopore_rapid-sequencing-sqk-rad004-RSE_9046_v1_revM_14Aug2019-minion.pdf) and run on a FLO-MIN106 (ID: FAL86873) flowcell. Data acquisition was set to run _without_ basecalling for a period of 48hrs. This will make sure the raw Fast5 output files will be preserved (not sure if they're saved or not when basecalling is enabled), but will require conversion to FastQ at a later date.


---

#### RESULTS

Output folder:

- [20200311_cbai_nanopore_6129_403_26/](https://gannet.fish.washington.edu/Atumefaciens/20200311_cbai_nanopore_6129_403_26/)

Fast5 directory:

- [20200311_cbai_nanopore_6129_403_26/cbai_6129_403_26/20200311_1343_MN29908_FAL86873_d8db260e/fast5/](https://gannet.fish.washington.edu/Atumefaciens/20200311_cbai_nanopore_6129_403_26/cbai_6129_403_26/20200311_1343_MN29908_FAL86873_d8db260e/fast5/)

Run report (PDF):

- [20200311_cbai_nanopore_6129_403_26/cbai_6129_403_26/20200311_1343_MN29908_FAL86873_d8db260e/d8db260e-6ed1-43ce-8d8e-c03a376d4cb1--report.pdf](https://gannet.fish.washington.edu/Atumefaciens/20200311_cbai_nanopore_6129_403_26/cbai_6129_403_26/20200311_1343_MN29908_FAL86873_d8db260e/d8db260e-6ed1-43ce-8d8e-c03a376d4cb1--report.pdf)
