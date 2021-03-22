---
author: kubu4
comments: true
date: 2017-09-07 21:39:38+00:00
layout: post
slug: genome-assembly-olympia-oyster-pacbio-minimapminiasmracon
title: Genome Assembly - Olympia oyster PacBio minimap/miniasm/racon
wordpress_id: 2708
author:
  - kubu4
categories:
  - Olympia Oyster Genome Sequencing
tags:
  - jupyter notebook
  - minimap
  - olympia oyster
  - Ostrea lurida
  - PacBio
---

In this [GitHub Issue](https://github.com/RobertsLab/project-olympia.oyster-genomic/issues/29), Steven had suggested I try out the minimap/miniasm/racon pipeline for assembling our Olympia oyster PacBio data.

I followed the pipeline described by this paper: [https://matzlab.weebly.com/uploads/7/6/2/2/76229469/racon.pdf](http://matzlab.weebly.com/uploads/7/6/2/2/76229469/racon.pdf).

This notebook entry just contains the initial minimap execution. Followed up with [miniasm](https://robertslab.github.io/sams-notebook/2017/09/18/genome-assembly-olympia-oyster-pacbio-minimapminiasmracon-2.html) and then [racon](https://robertslab.github.io/sams-notebook/2017/09/18/genome-assembly-olympia-oyster-pacbio-minimapminiasmracon-3.html).

Jupyter Notebook (GitHub): [20170907_docker_pacbio_oly_minimap2.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20170907_docker_pacbio_oly_minimap2.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=33abe7f3db5d3aac87c98dd48bcdaa1872be634c&enc;_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f333361626537663364623564336161633837633938646434386263646161313837326265363334632f6a7570797465725f6e62732f73616d2f32303137303930375f646f636b65725f70616362696f5f6f6c795f6d696e696d6170322e6970796e62&nwo;=sr320%2FLabDocs&path;=jupyter_nbs%2Fsam%2F20170907_docker_pacbio_oly_minimap2.ipynb&repository;_id=13746500&repository;_type=Repository#61497852-239b-4522-a605-98e28586af59" width="100%" height="2000" scrolling="yes"></iframe>
