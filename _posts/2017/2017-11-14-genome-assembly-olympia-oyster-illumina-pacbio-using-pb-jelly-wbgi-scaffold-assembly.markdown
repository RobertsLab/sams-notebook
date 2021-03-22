---
author: kubu4
comments: true
date: 2017-11-14 19:05:37+00:00
layout: post
slug: genome-assembly-olympia-oyster-illumina-pacbio-using-pb-jelly-wbgi-scaffold-assembly
title: Genome Assembly -  Olympia Oyster Illumina & PacBio Using PB Jelly w/BGI Scaffold
  Assembly
wordpress_id: 2920
author:
  - kubu4
categories:
  - Olympia Oyster Genome Sequencing
tags:
  - assembly
  - BGI
  - Illumina
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
  - PacBio
  - PB Jelly
---

[Yesterday, I ran PB Jelly using Sean's Platanus assembly](https://robertslab.github.io/sams-notebook/2017/11/13/genome-assembly-olympia-oyster-illumina-pacbio-using-pb-jelly-wplatanus-assembly.html), but that didn't produce an assembly because [PB Jelly](https://sourceforge.net/p/pb-jelly/wiki/Home/) was expecting gaps in the Illumina reference assembly (i.e. scaffolds, not contigs).

Re-ran this using the [BGI Illumina scaffolds FASTA](https://owl.fish.washington.edu/O_lurida_genome_assemblies_BGI/20161201/cdts-hk.genomics.cn/Ostrea_lurida/Ostrea_lurida.fa).





  * [PB Jelly Documentation](https://sourceforge.net/p/pb-jelly/wiki/Home/)



Here's a brief rundown of how this was run:



  * Default PB Jelly settings (including default settings for blasr).


  * Illumina reference FASTA: [BGI Illumina scaffolds FASTA](https://owl.fish.washington.edu/O_lurida_genome_assemblies_BGI/20161201/cdts-hk.genomics.cn/Ostrea_lurida/Ostrea_lurida.fa)


  * PacBio reads for mapping


  * [Protocol.xml file needed for PB Jelly to run](https://owl.fish.washington.edu/Athaliana/20171114_oly_pbjelly/Protocol.xml)



See the Jupyter Notebook for full details of run (see Results section below).



#### Results:



Output folder: [https://owl.fish.washington.edu/Athaliana/20171114_oly_pbjelly/](http://owl.fish.washington.edu/Athaliana/20171114_oly_pbjelly/)

Output FASTA file: [https://owl.fish.washington.edu/Athaliana/20171114_oly_pbjelly/jelly.out.fasta](http://owl.fish.washington.edu/Athaliana/20171114_oly_pbjelly/jelly.out.fasta)

OK! This seems to have worked (and it was quick, like less than an hour!), as it actually produced a FASTA file! Will run QUAST with this and some assemblies to compare assembly stats. Have added this assembly to our [Olympia oyster genome assemblies table](https://github.com/RobertsLab/project-olympia.oyster-genomic/wiki/Genome-Assemblies).

Jupyter Notebook (GitHub): [20171114_emu_pbjelly_BGI_scaffold.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20171114_emu_pbjelly_BGI_scaffold.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=97a28b38b6bbbd989a77ea69d172e6c0e4dd4ef0&enc;_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f393761323862333862366262626439383961373765613639643137326536633065346464346566302f6a7570797465725f6e62732f73616d2f32303137313131345f656d755f70626a656c6c795f4247495f73636166666f6c642e6970796e62&nwo;=sr320%2FLabDocs&path;=jupyter_nbs%2Fsam%2F20171114_emu_pbjelly_BGI_scaffold.ipynb&repository;_id=13746500&repository;_type=Repository#f3ad29ab-37d8-49b9-8e4b-7a2b3b25a19d" width="100%" height="2000" scrolling="yes"></iframe>
