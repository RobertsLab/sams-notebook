---
author: kubu4
comments: true
date: 2018-01-16 18:50:08+00:00
layout: post
slug: assembly-comparisons-oly-assemblies-using-quast
title: Assembly Comparisons – Oly Assemblies Using Quast
wordpress_id: 3045
author:
  - kubu4
categories:
  - Olympia Oyster Genome Sequencing
tags:
  - assembly
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
  - QUAST
---

I ran [Quast](https://quast.sourceforge.net/quast.html) to compare all of our [current Olympia oyster genome assemblies](https://github.com/RobertsLab/project-olympia.oyster-genomic/wiki/Genome-Assemblies/8f8c0a46e4f0c15db5174d11f024c4f6dabf3170).

See Jupyter Notebook in Results section for Quast execution.



#### Results:



Output folder: [https://owl.fish.washington.edu/Athaliana/quast_results/results_2018_01_16_10_08_35/](http://owl.fish.washington.edu/Athaliana/quast_results/results_2018_01_16_10_08_35/)

Heatmapped table of results: [https://owl.fish.washington.edu/Athaliana/quast_results/results_2018_01_16_10_08_35/report.html](http://owl.fish.washington.edu/Athaliana/quast_results/results_2018_01_16_10_08_35/report.html)

Very enlightening!

After all the difficulties with PB Jelly, it has produced the most large contigs. However, it does also have the highest quantity and rate of N's of all the assemblies produced to date.



##### BEST OF:



# contigs (>= 50000 bp): pbjelly_sjw_01 (894)
Largest Contig: redundans_sjw_02 (322,397bp)
Total Length: pbjelly_sjw_01 (1,180,563,613bp)
Total Length (>=50,000bp): pbjelly_sjw_01 (57,741,906bp)
N50: redundans_sjw_03 (17,679bp)

Jupyter Notebook (GitHub): [20180116_swoose_oly_assembly_comparisons_quast.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20180116_swoose_oly_assembly_comparisons_quast.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=111eb149014b1a3203ba67bcb00a35c6f118f2dc&enc;_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f313131656231343930313462316133323033626136376263623030613335633666313138663264632f6a7570797465725f6e62732f73616d2f32303138303131365f73776f6f73655f6f6c795f617373656d626c795f636f6d70617269736f6e735f71756173742e6970796e62&nwo;=sr320%2FLabDocs&path;=jupyter_nbs%2Fsam%2F20180116_swoose_oly_assembly_comparisons_quast.ipynb&repository;_id=13746500&repository;_type=Repository#2f75a41a-a3f6-4a2a-bae1-dfa4454611e7" width="100%" height="2000" scrolling="yes"></iframe>
