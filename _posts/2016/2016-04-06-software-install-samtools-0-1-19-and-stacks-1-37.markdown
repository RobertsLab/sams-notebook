---
author: kubu4
comments: true
date: 2016-04-06 23:28:23+00:00
layout: post
slug: software-install-samtools-0-1-19-and-stacks-1-37
title: Software Install - samtools-0.1.19 and stacks-1.37
wordpress_id: 2070
author:
  - kubu4
categories:
  - Computer Servicing
tags:
  - ipython notebook
  - jupyter notebook
  - samtools
  - software install
  - stacks
---

Getting ready to analyze our _Ostrea lurida_ genotype-by-sequencing data and wanted to use the Stacks software.

We have an existing version of Stacks on Hummingbird (the Apple server blade I will be running this analysis on), but I figured I might as well install the latest version (stacks-1.37).

Additionally, Stacks requires samtools-0.1.19 to run, which we did NOT have installed.

I tracked all of this in the Jupyter (iPython) notebook below.

Due to permissions issues during installation, I frequently had to leave the Jupyter notebook to run "sudo" in bash. As such, the notebook is messy, but does outline the necessary steps to get these two programs installed.

Jupyter notebook: [20160406_STACKS_install.ipynb](https://eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160406_STACKS_install.ipynb)

NBviewer: [20160406_STACKS_install.ipynb](https://nbviewer.jupyter.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160406_STACKS_install.ipynb)
<iframe src="https://nbviewer.jupyter.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160406_STACKS_install.ipynb" width="100%" height="2000" scrolling="yes"></iframe>
