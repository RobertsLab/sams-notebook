---
author: kubu4
comments: true
date: 2017-11-30 23:46:29+00:00
layout: post
slug: genome-assembly-olympia-oyster-illumina-pacbio-using-pb-jelly-wbgi-scaffold-assembly-2
title: Genome Assembly – Olympia Oyster Illumina & PacBio Using PB Jelly w/BGI Scaffold
  Assembly
wordpress_id: 3043
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
  - pbjelly
  - QUAST
---

[After another attempt to fix PB Jelly](https://robertslab.github.io/sams-notebook/2017/11/30/troubleshooting-pb-jelly-install-on-emu-continued.html), I ran it again.

We'll see how it goes this time...

Re-ran this using the [BGI Illumina scaffolds FASTA](https://owl.fish.washington.edu/O_lurida_genome_assemblies_BGI/20161201/cdts-hk.genomics.cn/Ostrea_lurida/Ostrea_lurida.fa).





  * [PB Jelly Documentation](https://sourceforge.net/p/pb-jelly/wiki/Home/)



Here's a brief rundown of how this was run:



  * Default PB Jelly settings (including default settings for blasr).


  * Illumina reference FASTA: [BGI Illumina scaffolds FASTA](https://owl.fish.washington.edu/O_lurida_genome_assemblies_BGI/20161201/cdts-hk.genomics.cn/Ostrea_lurida/Ostrea_lurida.fa)


  * PacBio reads for mapping


  * [Protocol.xml file needed for PB Jelly to run](https://owl.fish.washington.edu/Athaliana/20171130_oly_pbjelly/Protocol.xml)



See the Jupyter Notebook for full details of run (see Results section below).



#### Results:



Output folder: [https://owl.fish.washington.edu/Athaliana/20171130_oly_pbjelly/](http://owl.fish.washington.edu/Athaliana/20171130_oly_pbjelly/)

Output FASTA file: [https://owl.fish.washington.edu/Athaliana/20171130_oly_pbjelly/jelly.out.fasta](http://owl.fish.washington.edu/Athaliana/20171130_oly_pbjelly/jelly.out.fasta)

Quast assessment of output FASTA:

<table >

<tr >
  Assembly
  jelly.out
</tr>

<tbody >
<tr >
  
<td ># contigs (>= 0 bp)
</td>
  
<td >696946
</td>
</tr>
<tr >
  
<td ># contigs (>= 1000 bp)
</td>
  
<td >159429
</td>
</tr>
<tr >
  
<td ># contigs (>= 5000 bp)
</td>
  
<td >68750
</td>
</tr>
<tr >
  
<td ># contigs (>= 10000 bp)
</td>
  
<td >35320
</td>
</tr>
<tr >
  
<td ># contigs (>= 25000 bp)
</td>
  
<td >7048
</td>
</tr>
<tr >
  
<td ># contigs (>= 50000 bp)
</td>
  
<td >894
</td>
</tr>
<tr >
  
<td >Total length (>= 0 bp)
</td>
  
<td >1253001795
</td>
</tr>
<tr >
  
<td >Total length (>= 1000 bp)
</td>
  
<td >1140787867
</td>
</tr>
<tr >
  
<td >Total length (>= 5000 bp)
</td>
  
<td >932263178
</td>
</tr>
<tr >
  
<td >Total length (>= 10000 bp)
</td>
  
<td >691523275
</td>
</tr>
<tr >
  
<td >Total length (>= 25000 bp)
</td>
  
<td >261425921
</td>
</tr>
<tr >
  
<td >Total length (>= 50000 bp)
</td>
  
<td >57741906
</td>
</tr>
<tr >
  
<td ># contigs
</td>
  
<td >213264
</td>
</tr>
<tr >
  
<td >Largest contig
</td>
  
<td >194507
</td>
</tr>
<tr >
  
<td >Total length
</td>
  
<td >1180563613
</td>
</tr>
<tr >
  
<td >GC (%)
</td>
  
<td >36.57
</td>
</tr>
<tr >
  
<td >N50
</td>
  
<td >12433
</td>
</tr>
<tr >
  
<td >N75
</td>
  
<td >5983
</td>
</tr>
<tr >
  
<td >L50
</td>
  
<td >26241
</td>
</tr>
<tr >
  
<td >L75
</td>
  
<td >60202
</td>
</tr>
<tr >
  
<td ># N's per 100 kbp
</td>
  
<td >6580.58
</td>
</tr>
</tbody>
</table>

Have added this assembly to our [Olympia oyster genome assemblies table](https://github.com/RobertsLab/project-olympia.oyster-genomic/wiki/Genome-Assemblies).

This took an insanely long time to complete (nearly six weeks)!!! After some internet searching, I've found a pontential solution to this and have initiated another PB Jelly run to see if it will run faster. Regardless, it'll be interesting to see how the results compare from two independent runs of PB Jelly.

Jupyter Notebook (GitHub): [20171130_emu_pbjelly.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20171130_emu_pbjelly.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=87d65add8efa1d529de364017472839a7f2236c3&enc;_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f383764363561646438656661316435323964653336343031373437323833396137663232333663332f6a7570797465725f6e62732f73616d2f32303137313133305f656d755f70626a656c6c792e6970796e62&nwo;=sr320%2FLabDocs&path;=jupyter_nbs%2Fsam%2F20171130_emu_pbjelly.ipynb&repository;_id=13746500&repository;_type=Repository#656df5c8-43b5-49d3-8f01-ce6dba13ae6d" width="100%" height="2000" scrolling="yes"></iframe>
