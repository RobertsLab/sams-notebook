---
author: kubu4
comments: true
date: 2016-12-01 04:24:23+00:00
layout: post
slug: computing-an-excercuse-in-futility
title: Computing - An Excercise in Futility
wordpress_id: 2369
author:
  - kubu4
categories:
  - Miscellaneous
tags:
  - jupyter notebook
  - R
---

Trying to continue my [Oly GBS analsyis from the other day](https://robertslab.github.io/sams-notebook/2016/11/17/data-analysis-initial-o-lurida-fst-determination-from-gbs-data.html) and follow along with [Katherine Silliman's notebook](https://github.com/ksil91/2016_Notebook/blob/master/2bRAD%20Subset%20Population%20Structure%20Analysis.ipynb)

However, I hit a major snag: I can't seem to run R in my Jupyter notebook! This is a major pain, since the notebook needs to be able to switch between languages; that's the beauty of using these notebooks.

Below, is a documentation of my torments today.

Currently, I'm creating a new Docker image that uses the Debian Apt repository to install R version 3.1.1. Going through Apt instead of installing from source (as I had been previously done in the Dockerfile) should install all the necessary dependencies for R and get resolve some of the error messages I'm seeing.

Otherwise, the last resort will be to use R outside of the notebook and document that process separately.

Anyway, this is the kind of stuff that is immensely time consuming and frustrating that most people don't realize goes on with all of this computing stuff...

Notebook: [20161129_docker_R_magics_failure.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20161129_docker_R_magics_failure.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=5c8ec3567111f8b13a7fdfca4f5c8a0cb2dbd0a0&enc;_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f356338656333353637313131663862313361376664666361346635633861306362326462643061302f6a7570797465725f6e62732f73616d2f32303136313132395f646f636b65725f525f6d61676963735f6661696c7572652e6970796e62&nwo;=sr320%2FLabDocs&path;=jupyter_nbs%2Fsam%2F20161129_docker_R_magics_failure.ipynb&repository;_id=13746500#408ba287-eb47-4bac-a308-27902e0a68f2" width="100%" height="2000" scrolling="yes"></iframe>
