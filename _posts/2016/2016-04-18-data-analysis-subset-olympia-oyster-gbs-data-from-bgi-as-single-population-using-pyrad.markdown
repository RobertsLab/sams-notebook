---
author: kubu4
comments: true
date: 2016-04-18 22:52:38+00:00
layout: post
slug: data-analysis-subset-olympia-oyster-gbs-data-from-bgi-as-single-population-using-pyrad
title: Data Analysis - Subset Olympia Oyster GBS Data from BGI as Single Population
  Using PyRAD
wordpress_id: 2088
author:
  - kubu4
categories:
  - Genotype-by-sequencing at BGI
tags:
  - .vcf
  - IGV
  - ipython notebook
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
  - pyrad
  - SNPs
---

Attempting to get some sort of analysis of the _Ostrea lurida_ [GBS data from BGI](https://github.com/RobertsLab/project-olympia.oyster-genomic/wiki/Genotype-by-sequencing-November-2015), particularly since [the last run at it using Stacks](https://robertslab.github.io/sams-notebook/2016/04/06/data-analysis-oly-gbs-data-from-bgi.html) crashed (literally) and burned (not literally).

Katherine Silliman at UIC recommended using [PyRAD](https://dereneaton.com/software/pyrad/).

I've taken the [example Jupyter notebook from the PyRAD website](https://nbviewer.ipython.org/gist/dereneaton/1f661bfb205b644086cc/PE-GBS_empirical.ipynb) and passed a subset of the 96 individuals through it.

In this instance, the subset of individuals were all analyzed as a single population. I have another Jupyter notebook running on a different computer that will separate the three populations that are present in this subset.

Overall, I don't fully understand the results. However, this seems to be the quickest assessment of the data (from the *.snps file generated):

28 individuals, 36424 loci, 72251 snps

Additionally, I did run into an issue when I tried to visualize the data (using the *.vcf file generated) in IGV (see screen cap below). [I've posted the issue to the pyrad GitHub repo](https://github.com/dereneaton/pyrad/issues/29) in hopes of getting it resolved.

![](https://eagle.fish.washington.edu/Arabidopsis/20160419_IGV_pyrad_vcf_index_error.jpg)(http://eagle.fish.washington.edu/Arabidopsis/20160419_IGV_pyrad_vcf_index_error.jpg)



One last thing. This might be obvious to most, but I discovered that trying to do all this computation over the network (via a mounted server share) is significantly slower than performing these operations on th efiles when they're stored locally. Somewhere in the notebook you'll notice that I copy all of the working directory from the server (Owl) to the local machine (Hummingbird). Things proceeded very quickly after doing that. Didn't realize this would have so much impact on speed!!

Jupyter Notebook: [20160418_pyrad_oly_PE-GBS.ipynb](https://eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160418_pyrad_oly_PE-GBS.ipynb)

NBviewer: [20160418_pyrad_oly_PE-GBS](https://nbviewer.jupyter.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160418_pyrad_oly_PE-GBS.ipynb)
<iframe src="https://nbviewer.jupyter.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160418_pyrad_oly_PE-GBS.ipynb" width="100%" height="2000" scrolling="yes"></iframe>
