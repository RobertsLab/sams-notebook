---
author: kubu4
comments: true
date: 2016-12-02 06:47:37+00:00
layout: post
slug: data-analysis-continued-o-lurida-fst-analysis-from-gbs-data
title: Data Analysis - Continued O.lurida Fst Analysis from GBS Data
wordpress_id: 2374
author:
  - kubu4
categories:
  - Genotype-by-sequencing at BGI
  - Olympia oyster reciprocal transplant
---

Continued t[he analysis I started the other day](https://robertslab.github.io/sams-notebook/2016/11/17/data-analysis-initial-o-lurida-fst-determination-from-gbs-data.html). Still following [Katherine Silliman's notebook](https://github.com/ksil91/2016_Notebook/blob/master/2bRAD%20Subset%20Population%20Structure%20Analysis.ipynb) for guidance.

Quick summary of this analysis:




    
  * Mean Fst comparing all populations = 0.139539326187024

    
  * Mean Fst HL vs NF = 0.143075552548742

    
  * Mean Fst HL vs SN = 0.155234939276722

    
  * Mean Fst NF vs SN = 0.117889300124951



NOTE: Mean Fst values were calculated after replacing negative Fst values with 0. Thus, the means are higher than they would be had the raw data been used. I followed Katherine's notebook and she doesn't explicitly explain why she does this, nor what the potential implications are for interpreting the data. Will have to discus her rationale behind this with her.

Jupyter notebook: [20161201_docker_oly_vcf_analysis_R.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20161201_docker_oly_vcf_analysis_R.ipynb)
<iframe src="https://render.githubusercontent.com/view/ipynb?commit=662b23afba3893bc401598945369542b71051859&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f363632623233616662613338393362633430313539383934353336393534326237313035313835392f6a7570797465725f6e62732f73616d2f32303136313230315f646f636b65725f6f6c795f7663665f616e616c797369735f522e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20161201_docker_oly_vcf_analysis_R.ipynb&repository_id=13746500#1267c9cf-b545-4b76-a1e3-fd6cdad77557" width="100%" height="2000" scrolling="yes"></iframe>
