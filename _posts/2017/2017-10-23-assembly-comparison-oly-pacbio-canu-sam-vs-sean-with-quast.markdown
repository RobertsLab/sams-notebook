---
author: kubu4
comments: true
date: 2017-10-23 19:38:50+00:00
layout: post
slug: assembly-comparison-oly-pacbio-canu-sam-vs-sean-with-quast
title: 'Assembly Comparison - Oly PacBio Canu: Sam vs. Sean with Quast'
wordpress_id: 2817
author:
  - kubu4
categories:
  - Miscellaneous
---

[I recently finished an assembly of our Olympia oyster PacBio data using Canu](https://robertslab.github.io/sams-notebook/2017/10/18/genome-assembly-olympia-oyster-pacbio-canu-v1-6.html) and thought it would be interesting to compare to [Sean's Canu assembly](https://genefish.wordpress.com/2017/06/19/seans-notebook-canu-run-finished/).

Granted, this isn't a totally true comparison because I think Sean's assembly is further "polished" using Pilon or something like that, but the Quast analysis is so quick (like < 60 seconds), that it can't hurt.

See the Jupyter Notebook below for the full deets on running Quast.

Results:

Quast output folder: [https://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_23_18_01_25/](http://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_23_18_01_25/)

Interactive report: [https://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_23_18_01_25/report.html](http://owl.fish.washington.edu/Athaliana/quast_results/results_2017_10_23_18_01_25/report.html)

![](https://owl.fish.washington.edu/Athaliana/20171023_quast_sbcanu_sjwcanu.png)(http://owl.fish.washington.edu/Athaliana/20171023_quast_sbcanu_sjwcanu.png)

Jupyter Notebook (GitHub): [20171023_docker_oly_pacbio_canu_comparisons.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20171023_docker_oly_pacbio_canu_comparisons.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=192e1931156bbcef82aaa2bc19869d4dddd7f19b&enc;_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f313932653139333131353662626365663832616161326263313938363964346464646437663139622f6a7570797465725f6e62732f73616d2f32303137313032335f646f636b65725f6f6c795f70616362696f5f63616e755f636f6d70617269736f6e732e6970796e62&nwo;=sr320%2FLabDocs&path;=jupyter_nbs%2Fsam%2F20171023_docker_oly_pacbio_canu_comparisons.ipynb&repository;_id=13746500&repository;_type=Repository#21d2dd23-a18b-410c-88c5-1c5ac7067a2b" width="100%" height="2000" scrolling="yes"></iframe>
