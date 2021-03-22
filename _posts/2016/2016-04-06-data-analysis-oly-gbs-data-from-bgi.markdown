---
author: kubu4
comments: true
date: 2016-04-06 23:33:10+00:00
layout: post
slug: data-analysis-oly-gbs-data-from-bgi
title: Data Analysis - Oly GBS Data from BGI Using Stacks
wordpress_id: 2082
author:
  - kubu4
categories:
  - Genotype-by-sequencing at BGI
tags:
  - BGI
  - GBS
  - genotype-by-sequencing
  - ipython notebook
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
  - stacks
---

UPDATE (20160418) : I'm posting this more for posterity, as Stacks continually locked up at both the "ustacks" and "cstacks" stages. These processes would take days to run (on the full 96 samples) and then the processes would become "stuck" (viewed via the `top` command in OS X).

Have moved on to trying PyRAD in the meantime.

Need to get the [GBS from BGI data analyzed.](https://github.com/RobertsLab/project-olympia.oyster-genomic/wiki/Genotype-by-sequencing-November-2015)

[Installed Stacks (and its dependencies on Hummingbird earlier today)(2016/04/06/software-install-samtools-0-1-19-and-stacks-1-37.html).

Below is the Jupyter (iPython) notebook I ran to perform this analysis.

Jupyter (iPython) Notebook: [20160406_Oly_GBS_STACKS.ipynb](https://eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160406_Oly_GBS_STACKS.ipynb)

Jupyter Notebook Viewer: [20160406_Oly_GBS_STACKS](https://nbviewer.jupyter.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160406_Oly_GBS_STACKS.ipynb)
<iframe src="https://nbviewer.jupyter.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160406_Oly_GBS_STACKS.ipynb" width="100%" height="2000" scrolling="yes"></iframe>
