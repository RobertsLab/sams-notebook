---
author: kubu4
comments: true
date: 2017-10-05 22:30:33+00:00
layout: post
slug: genome-assembly-olympia-oyster-redundans-with-illumina-pacbio
title: Genome Assembly - Olympia Oyster Redundans with Illumina + PacBio
wordpress_id: 2759
author:
  - kubu4
categories:
  - Olympia Oyster Genome Sequencing
tags:
  - canu
  - Illumina
  - jupyter notebook
  - Ostrea
  - PacBio
  - QUAST
  - redundans
---

Redundans should assemble both Illumina and PacBio data, so let's do that.

Sean had previously performed this - twice actually:





  * [Redundans 1](https://genefish.wordpress.com/2017/05/24/oly-genome-redundans-run-finished/)



  * [Redundans 2](https://genefish.wordpress.com/2017/06/08/seans-notebook-oly-genome-re-assembly-try-2/)






It wasn't entirely clear how he had run Redundans the first time and the second time he used his [Platinus contig FASTA file](https://genefish.wordpress.com/2017/06/02/oly-assembly-try-2-its-yuuuuuuge/) as the necessary reference assembly when running Redundans.

Since he had produced [a good looking assembly from PacBio data using Canu](https://robertslab.github.io/sams-notebook/2017/10/03/assembly-comparisons-olympia-oyster-genome-assemblies.html), I decided to give Redundans a rip using that assembly.

I then compared all three Redundans runs using QUAST.

Jupyter notebook (GitHub): [20171004_docker_oly_redundans.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20171004_docker_oly_redundans.ipynb)

Notebook is also embedded at the bottom of this notebook entry (but, it should be easier to view at the link provided above).





  * Sean's Canu assembly (FASTA): [https://owl.fish.washington.edu/scaphapoda/Sean/Oly_Canu_Output/oly_pacbio_.contigs.fasta](http://owl.fish.washington.edu/scaphapoda/Sean/Oly_Canu_Output/oly_pacbio_.contigs.fasta)


  * Sean's first Redundans assembly (scaffolded assembly; FASTA): [https://owl.fish.washington.edu/scaphapoda/Sean/Oly_Redundans_Output/scaffolds.reduced.fa](http://owl.fish.washington.edu/scaphapoda/Sean/Oly_Redundans_Output/scaffolds.reduced.fa)


  * Sean's second Redundans assembly (scaffolded assembly; FASTA): [https://owl.fish.washington.edu/scaphapoda/Sean/Oly_Redundans_Output_Try_2/scaffolds.reduced.fa](http://owl.fish.washington.edu/scaphapoda/Sean/Oly_Redundans_Output_Try_2/scaffolds.reduced.fa)



  * Redundans Output folder: [https://owl.fish.washington.edu/Athaliana/20171004_redundans/](http://owl.fish.washington.edu/Athaliana/20171004_redundans/)



  * Redundans assembly (scaffolded assembly; FASTA): [https://owl.fish.washington.edu/Athaliana/20171004_redundans/scaffolds.reduced.fa](http://owl.fish.washington.edu/Athaliana/20171004_redundans/scaffolds.reduced.fa)


  * Quast Output folder (default settings): [https://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_05_14_21_50/](http://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_05_14_21_50/)


  * Quast Output folder (--scaffolds option): [https://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_05_14_28_51/](http://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_05_14_28_51/)





Of note, is that Redundans didn't find any alignments for the paired reads for each of the BGI mate-pair Illumina data:





  * 160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCABDLAAPEI-62_2.fq.gz


  * 160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCACDTAAPEI-75_2.fq.gz


  * 160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCABDLAAPEI-62_2.fq.gz


  * 160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCACDTAAPEI-75_2.fq.gz


  * 160103_I137_FCH3V5YBBXX_L5_WHOSTibkDCAADWAAPEI-74_2.fq.gz


  * 160103_I137_FCH3V5YBBXX_L6_WHOSTibkDCAADWAAPEI-74_2.fq.gz



First, I ran QUAST with the default settings:

Interactive link: [https://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_05_14_21_50/report.html](http://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_05_14_21_50/report.html)

![](https://owl.fish.washington.edu/Athaliana/20171005_oly_assemblies_01.png)(http://owl.fish.washington.edu/Athaliana/20171005_oly_assemblies_01.png)

Using that Canu assembly with Redundans certainly seems to results in a better assembly.

Decided to run QUAST with the --scaffolds option to see what happened:

Interactive link: [https://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_05_14_28_51/report.html](http://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_05_14_28_51/report.html)

![](https://owl.fish.washington.edu/Athaliana/20171005_oly_assemblies_02.png)(http://owl.fish.washington.edu/Athaliana/20171005_oly_assemblies_02.png)

The scaffolds with the "Ns" removed from them are appended with "_broken" - meaning the scaffolds were broken apart into contigs. Things are certainly cleaner when using the `--scaffolds` option, however, as far as I can tell, QUAST doesn't actually generate a FASTA file with the "_broken" scaffolds!

<iframe src="https://nbviewer.jupyter.org/github/sr320/LabDocs/blob/master/jupyter_nbs/sam/20171004_docker_oly_redundans.ipynb" width="100%" height="2000" scrolling="yes"></iframe>
