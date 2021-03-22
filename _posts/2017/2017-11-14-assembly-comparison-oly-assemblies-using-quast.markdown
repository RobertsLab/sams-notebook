---
author: kubu4
comments: true
date: 2017-11-14 21:52:56+00:00
layout: post
slug: assembly-comparison-oly-assemblies-using-quast
title: Assembly Comparison - Oly Assemblies Using Quast
wordpress_id: 2925
author:
  - kubu4
categories:
  - Olympia Oyster Genome Sequencing
tags:
  - assembly
  - olympia oyster
  - Ostrea lurida
  - QUAST
---

I ran [Quast](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwi95amNgr_XAhUD5mMKHW2rBokQFggoMAA&url=http%3A%2F%2Fbioinf.spbau.ru%2Fquast&usg=AOvVaw0OyuiM-DifNnfgvPWp7eZC) to compare all of our [current Olympia oyster genome assemblies](https://github.com/RobertsLab/project-olympia.oyster-genomic/wiki/Genome-Assemblies/944271d96a4dc5d3ab12ffea92f0584682ddd115).

See Jupyter Notebook in Results section for Quast execution.



#### Results:



Output folder: [https://owl.fish.washington.edu/Athaliana/quast_results/results_2017_11_14_12_30_25/](http://owl.fish.washington.edu/Athaliana/quast_results/results_2017_11_14_12_30_25/)

Heatmapped table of results: [https://owl.fish.washington.edu/Athaliana/quast_results/results_2017_11_14_12_30_25/report.html](http://owl.fish.washington.edu/Athaliana/quast_results/results_2017_11_14_12_30_25/report.html)

Very enlightening!



##### BEST OF:



Largest Contig: redundans_sjw_02 (322,397bp)
Total Length: soap_bgi_01 & pbjelly_sjw_01 (697,528,655bp)
Total Length (>=50,000bp): redundans_sjw_03 (17,006,058bp)
N50: redundans_sjw_03 (17,679bp)

Interesting tidbit: The pbjelly_sjw_01 assembly is _EXACTLY_ the same as the soap_bgi_01. [Looking at the output messages from that PB Jelly assembly](https://robertslab.github.io/sams-notebook/2017/11/14/genome-assembly-olympia-oyster-illumina-pacbio-using-pb-jelly-wbgi-scaffold-assembly.html), one can see why. The messages indicate that no gaps were filled on the BGI scaffold reference! That means the PB Jelly output is just the BGI scaffold reference assembly!

Jupyter Notebook (GitHub): [20171114_swoose_oly_assembly_comparisons_quast.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20171114_swoose_oly_assembly_comparisons_quast.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=44b604d7e596db34cba3d653659a5cfe35a96d0f&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f343462363034643765353936646233346362613364363533363539613563666533356139366430662f6a7570797465725f6e62732f73616d2f32303137313131345f73776f6f73655f6f6c795f617373656d626c795f636f6d70617269736f6e735f71756173742e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20171114_swoose_oly_assembly_comparisons_quast.ipynb&repository_id=13746500&repository_type=Repository#918509d6-4e5d-418d-8ebe-1593f5dc8483" width="100%" height="2000" scrolling="yes"></iframe>
