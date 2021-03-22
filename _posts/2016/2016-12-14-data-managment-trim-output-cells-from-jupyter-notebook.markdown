---
author: kubu4
comments: true
date: 2016-12-14 19:00:04+00:00
layout: post
slug: data-managment-trim-output-cells-from-jupyter-notebook
title: Data Managment - Trim Output Cells from Jupyter Notebook
wordpress_id: 2386
author:
  - kubu4
categories:
  - Miscellaneous
tags:
  - jupyter notebook
---

Last week [I downloaded the final BGI data files and assemblies for Olympia oyster and geoduck genome sequencing projects](https://robertslab.github.io/sams-notebook/2016/12/14/data-management-download-final-bgi-genome-assembly-files.html). However, the output from the download command made the Jupyter Notebook files too large to view and/or upload to GitHub. So, I had to trim the output cells from that notebook in order to render it usable/viewable.

The notebook below details how I did that and also examines the original version of that jumbo notebook to give some idea of what the command outputs were, for posterity.

Jupyter Notebook: [20161214_docker_notebook_trimming.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20161214_docker_notebook_trimming.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=7985418a2f3fa9af6b3c11e7a8d4bb2ab0981ded&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f373938353431386132663366613961663662336331316537613864346262326162303938316465642f6a7570797465725f6e62732f73616d2f32303136313231345f646f636b65725f6e6f7465626f6f6b5f7472696d6d696e672e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20161214_docker_notebook_trimming.ipynb&repository_id=13746500#092d7320-7f8b-48b1-abb8-bf0891f709a2" width="100%" height="2000" scrolling="yes"></iframe>
