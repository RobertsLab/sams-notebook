---
author: kubu4
comments: true
date: 2016-08-17 02:21:37+00:00
layout: post
slug: data-analysis-faststructure-population-analysis-of-oly-gbs-pyrad-output
title: Data Analysis - fastStructure Population Analysis of Oly GBS PyRAD Output
wordpress_id: 2251
author:
  - kubu4
categories:
  - Genotype-by-sequencing at BGI
tags:
  - fastStructure
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
  - Structure
---

After some basal readings about what Fst is (see notebook below for a definition and reference), I decided to try to use [fastStructure](https://rajanil.github.io/fastStructure/) to analyze the PyRAD output from [20160727](https://robertslab.github.io/sams-notebook/2016/07/27/data-analysis-pyrad-analysis-of-olympia-oyster-gbs-data.html).

The quick, TL;DR: after spending a bunch of time installing the program, it doesn't handle the default Structure file (.str); requires some companion file types that PyRAD doesn't output.

I've put this here for posterity and background reference on Fst...

Will proceed with using the full blown [Structure](https://pritchardlab.stanford.edu/structure_software/release_versions/v2.3.4/html/install.html) program to try to glean some info from these three populations.



Jupyter Notebook: [20160816_oly_gbs_fst_calcs.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20160816_oly_gbs_fst_calcs.ipynb)
<iframe src="https://render.githubusercontent.com/view/ipynb?commit=6956f592ce6e844065162990a870b80e4cd1eb3a&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f363935366635393263653665383434303635313632393930613837306238306534636431656233612f6a7570797465725f6e62732f73616d2f32303136303831365f6f6c795f6762735f6673745f63616c63732e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20160816_oly_gbs_fst_calcs.ipynb&repository_id=13746500#22ec9b01-07ae-4ba4-9c5e-a71afb9d8a59" width="100%" height="2000" scrolling="yes"></iframe>


