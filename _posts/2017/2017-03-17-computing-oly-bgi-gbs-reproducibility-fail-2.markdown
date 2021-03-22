---
author: kubu4
comments: true
date: 2017-03-17 21:41:55+00:00
layout: post
slug: computing-oly-bgi-gbs-reproducibility-fail-2
title: Computing – Oly BGI GBS Reproducibility; fail?
wordpress_id: 2520
author:
  - kubu4
categories:
  - Genotype-by-sequencing at BGI
tags:
  - BGI
  - GBS
  - genotype-by-sequencing
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
---

OK, so things have improved since [the last attempt at getting this BGI script to run](https://robertslab.github.io/sams-notebook/2017/03/14/computing-oly-bgi-gbs-reproducibility-fail-but-less-so-than-last-time.html) and demultiplex the raw data.

I played around with the index.lst file format (based on the error I received last time, it seemed like a good possibility that the file formatting was incorrect) and actually got the script to run to completion! Granted, it took over 16hrs (!!), but it completed!

See the Jupyter notebook link below.



Results:

Well, although the script finished and kicked out all the demultiplexed FASTQ files, the contents of the FASTQ files don't match (the read counts differ between these results and the BGI files) the original set of demultiplexed files. I'm not entirely sure if this is to be expected or not, since the script allows for a single nucleotide mismatch when demultiplexing. Is it possible that the mismatch could be interpreted slightly differently each time this is run? I'm not certain.

Theoretically, you should get the same results every time...

Maybe I'll re-run this again over the weekend and see how the results compare to this run and the original BGI demultiplexing...

Jupyter notebook (GitHub): [20170314_docker_Oly_BGI_GBS_demultiplexing_reproducibility.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20170314_docker_Oly_BGI_GBS_demultiplexing_reproducibility.ipynb)



Jupyter notebook (may be easier to view in GitHub link above):

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=a3710bb2d9037c6cde450935925a8d4b93ac373b&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f613337313062623264393033376336636465343530393335393235613864346239336163333733622f6a7570797465725f6e62732f73616d2f32303137303331345f646f636b65725f4f6c795f4247495f4742535f64656d756c7469706c6578696e675f726570726f6475636962696c6974792e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20170314_docker_Oly_BGI_GBS_demultiplexing_reproducibility.ipynb&repository_id=13746500#a44f4c41-cea7-4c17-a424-674573cb686c" width="100%" height="2000" scrolling="yes"></iframe>
