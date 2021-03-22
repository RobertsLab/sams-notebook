---
author: kubu4
comments: true
date: 2017-09-18 22:02:49+00:00
layout: post
slug: genome-assembly-olympia-oyster-pacbio-minimapminiasmracon-3
title: Genome Assembly - Olympia oyster PacBio minimap/miniasm/racon
wordpress_id: 2715
author:
  - kubu4
categories:
  - Miscellaneous
---

In this [GitHub Issue](https://github.com/RobertsLab/project-olympia.oyster-genomic/issues/29), Steven had suggested I try out the minimap/miniasm/racon pipeline for assembling our Olympia oyster PacBio data.

I followed the pipeline described by this paper: [https://matzlab.weebly.com/uploads/7/6/2/2/76229469/racon.pdf](http://matzlab.weebly.com/uploads/7/6/2/2/76229469/racon.pdf).

This notebook entry just contains the racon execution. This produced this assembly:

[https://owl.fish.washington.edu/Athaliana/201709_oly_pacbio_assembly_minimap_asm_racon/20170918_oly_pacbio_racon1_consensus.fasta](http://owl.fish.washington.edu/Athaliana/201709_oly_pacbio_assembly_minimap_asm_racon/20170918_oly_pacbio_racon1_consensus.fasta)

All intermediate files generated from this pipeline are here:

[https://owl.fish.washington.edu/Athaliana/201709_oly_pacbio_assembly_minimap_asm_racon/](http://owl.fish.washington.edu/Athaliana/201709_oly_pacbio_assembly_minimap_asm_racon/)

I'll put together a TL;DR post that provides an overview of the pipeline and an assessment of the final assembly.

Previously ran [minimap](https://robertslab.github.io/sams-notebook/2017/09/07/genome-assembly-olympia-oyster-pacbio-minimapminiasmracon.html)
 and then [miniasm](https://robertslab.github.io/sams-notebook/2017/09/18/genome-assembly-olympia-oyster-pacbio-minimapminiasmracon-2.html).

Jupyter Notebook (GitHub): [20170918_docker_pacbio_oly_racon0.5.0.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20170918_docker_pacbio_oly_racon0.5.0.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=746136fffd23a4c07396158cda484b1db0004314&enc;_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f373436313336666666643233613463303733393631353863646134383462316462303030343331342f6a7570797465725f6e62732f73616d2f32303137303931385f646f636b65725f70616362696f5f6f6c795f7261636f6e302e352e302e6970796e62&nwo;=sr320%2FLabDocs&path;=jupyter_nbs%2Fsam%2F20170918_docker_pacbio_oly_racon0.5.0.ipynb&repository;_id=13746500&repository;_type=Repository#558632bf-feb4-41fc-ab2c-2ac0f88eae59" width="100%" height="2000" scrolling="yes"></iframe>
