---
author: kubu4
comments: true
date: 2017-11-14 02:55:14+00:00
layout: post
slug: genome-assembly-olympia-oyster-illumina-pacbio-using-pb-jelly-wplatanus-assembly
title: Genome Assembly -  Olympia Oyster Illumina & PacBio Using PB Jelly w/Platanus
  Assembly
wordpress_id: 2914
author:
  - kubu4
categories:
  - Olympia Oyster Genome Sequencing
tags:
  - assembly
  - Illumina
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
  - PacBio
  - PB Jelly
---

[Sean had previously attempted to run PB Jelly, but ran into some issues running on Hyak](https://genefish.wordpress.com/2017/05/04/lots-of-moving-files-and-output-stuff/), so I decided to try this on [Emu](https://robertslab.github.io/sams-notebook/2017/10/30/software-installation-pb-jelly-suite-and-blasr-on-emu.html).





  * [PB Jelly Documentation](https://sourceforge.net/p/pb-jelly/wiki/Home/)



Here's a brief rundown of how this was run:



  * Default PB Jelly settings (including default settings for blasr).


  * Illumina reference FASTA: [Sean's Platanus kmer=22 assembly](https://owl.fish.washington.edu/scaphapoda/Sean/Oly_Platanus_Assembly_Kmer-22/Oly_Out__contig.fa)


  * PacBio reads for mapping


  * [Protocol.xml file needed for PB Jelly to run](https://owl.fish.washington.edu/Athaliana/20171113_oly_pbjelly/Protocol.xml)



See the Jupyter Notebook for full details of run (see Results section below).



#### Results:



Output folder: [https://owl.fish.washington.edu/Athaliana/20171113_oly_pbjelly/](http://owl.fish.washington.edu/Athaliana/20171113_oly_pbjelly/)

This completed very quickly (like, just a couple of hours). I also didn't experience the woes of multimillion temp file production that [killed Sean's attempt at running this on Mox (Hyak)(https://genefish.wordpress.com/2017/05/04/lots-of-moving-files-and-output-stuff/).

However, it doesn't seem to have produced an assembly!

Looking through the output, it seems as though it didn't produce an assembly because there weren't any gaps to fill in the reference. This makes sense (in regards to the lack of gaps in the reference Illumina assembly) because I used the Platanus contig FASTA file (i.e. not a scaffolds file). I didn't realize PB Jelly was just designed for gap filling. Guess I'll give this another go using the BGI scaffold FASTA file and see what we get.

Jupyter Notebook (GitHub): [20171113_emu_pbjelly_22mer_plat.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20171113_emu_pbjelly_22mer_plat.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=59a6f41c902a9a1c813ccbc69ef11d49e3251a4f&enc;_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f353961366634316339303261396131633831336363626336396566313164343965333235316134662f6a7570797465725f6e62732f73616d2f32303137313131335f656d755f70626a656c6c795f32326d65725f706c61742e6970796e62&nwo;=sr320%2FLabDocs&path;=jupyter_nbs%2Fsam%2F20171113_emu_pbjelly_22mer_plat.ipynb&repository;_id=13746500&repository;_type=Repository#451b7b1c-53c5-4b62-9576-2bd9961bb52e" width="100%" height="2000" scrolling="yes"></iframe>
