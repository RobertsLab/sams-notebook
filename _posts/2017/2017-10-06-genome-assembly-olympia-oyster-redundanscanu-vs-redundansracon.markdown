---
author: kubu4
comments: true
date: 2017-10-06 23:28:31+00:00
layout: post
slug: genome-assembly-olympia-oyster-redundanscanu-vs-redundansracon
title: Genome Assembly - Olympia oyster Redundans/Canu vs. Redundans/Racon
wordpress_id: 2767
author:
  - kubu4
categories:
  - Olympia Oyster Genome Sequencing
tags:
  - assembly
  - canu
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
  - QUAST
  - racon
  - redundans
---

Decided to compare the Redundans using Canu as reference and Redundans using Racon as reference. Both reference assemblies were just our PacBio data.

Jupyter notebook (GitHub): [20171005_docker_oly_redundans.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20171005_docker_oly_redundans.ipynb)

Notebook is also embedded at the end of this post.





  * Redundans/Canu assembly (scaffolded assembly; FASTA): [https://owl.fish.washington.edu/Athaliana/20171004_redundans/scaffolds.reduced.fa](http://owl.fish.washington.edu/Athaliana/20171004_redundans/scaffolds.reduced.fa)



  * Racon PacBio assembly (contigs: FASTA): [https://owl.fish.washington.edu/Athaliana/201709_oly_pacbio_assembly_minimap_asm_racon/20170918_oly_pacbio_racon1_consensus.fasta](http://owl.fish.washington.edu/Athaliana/201709_oly_pacbio_assembly_minimap_asm_racon/20170918_oly_pacbio_racon1_consensus.fasta)






Results:





  * Redundans/Racon Output folder: [https://owl.fish.washington.edu/Athaliana/20171005_redundans/](http://owl.fish.washington.edu/Athaliana/20171005_redundans/)



  * Redundans/Racon assembly (scaffolded assembly; FASTA): [https://owl.fish.washington.edu/Athaliana/20171005_redundans/scaffolds.reduced.fa](http://owl.fish.washington.edu/Athaliana/20171005_redundans/scaffolds.reduced.fa)



  * QUAST output folder (default settings): [https://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_06_22_21_06/](http://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_06_22_21_06/)



  * QUAST output folder (--scaffolds setting): [https://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_06_22_27_26/](http://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_06_22_27_26/)






It should be noted that the paired reads for each of the BGI mate-pair Illumina data did not assemble, [just like last time I used them](https://robertslab.github.io/sams-notebook/2017/10/05/genome-assembly-olympia-oyster-redundans-with-illumina-pacbio.html):





  * 160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCABDLAAPEI-62_2.fq.gz


  * 160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCACDTAAPEI-75_2.fq.gz


  * 160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCABDLAAPEI-62_2.fq.gz


  * 160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCACDTAAPEI-75_2.fq.gz


  * 160103_I137_FCH3V5YBBXX_L5_WHOSTibkDCAADWAAPEI-74_2.fq.gz


  * 160103_I137_FCH3V5YBBXX_L6_WHOSTibkDCAADWAAPEI-74_2.fq.gz



Redundans with Canu is better, suggesting that the Canu assembly is the better of the two PacBio assemblies (which we had already suspected).

QUAST comparison using default settings:

Interactive link:[https://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_06_22_21_06/report.html](http://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_06_22_21_06/report.html)

![](https://owl.fish.washington.edu/Athaliana/20171005_%20quast_redundans_01.png)(http://owl.fish.washington.edu/Athaliana/20171005_%20quast_redundans_01.png)

QUAST comparison using --scaffolds setting:

Interactive link: [https://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_06_22_27_26/report.html](http://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_06_22_27_26/report.html)

![](https://owl.fish.washington.edu/Athaliana/20171005_%20quast_redundans_02.png)(http://owl.fish.washington.edu/Athaliana/20171005_%20quast_redundans_02.png)

<iframe src="https://nbviewer.jupyter.org/github/sr320/LabDocs/blob/master/jupyter_nbs/sam/20171005_docker_oly_redundans.ipynb" width="100%" height="2000" scrolling="yes"></iframe>
