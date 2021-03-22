---
author: kubu4
comments: true
date: 2016-11-17 22:11:35+00:00
layout: post
slug: data-management-tracking-o-lurida-fastq-file-corruption
title: Data Management - Tracking O.lurida FASTQ File Corruption
wordpress_id: 2349
author:
  - kubu4
categories:
  - Olympia Oyster Genome Sequencing
tags:
  - BGI
  - checksum
  - docker
  - jupyter notebook
  - md5
  - olympia oyster
  - Ostrea lurida
---

**UPDATE 20170104 - [These two corrupt files have been replaced with non-corrupt files](https://robertslab.github.io/sams-notebook/2017/01/04/data-management-replacement-of-corrupt-bgi-oly-genome-fastq-files.html).**



* * *





Sean identified an issue with one of the original FASTQ files provided to use by BGI. Additionally, Steven had (unknowingly) identified the same corrupt file, as well as a second corrupt file in the set of FASTQ files. The issue is discussed here: [https://github.com/sr320/LabDocs/issues/334](https://github.com/sr320/LabDocs/issues/334)

Steven noticed the two files when he ran the program FASTQC and two files generated no output (but no error message!).

The two files in question are:





  * 151118_I137_FCH3KNJBBXX_L5_wHAXPI023905-96_1.fq.gz


  * 151114_I191_FCH3Y35BCXX_L2_wHAMPI023991-66_2.fq.gz



This post is an attempt to document where things went wrong, but having glanced through this data a bit already, it won't provide any answers.

[I originally downloaded the data on 20160127](https://robertslab.github.io/sams-notebook/2016/01/27/data-received-ostrea-lurida-genome-sequencing-files-from-bgi.html) to my home folder on Owl (this is detailed in the Jupyter notebook in that post) and generated/compared MD5 checksum values. The values matched at that time.

So, let's investigate a bit further...

Launch Docker container


    
    <code>docker run - p 8888:8888 -v /Users/sam/data/:/data -v /Users/sam/owl_home/:/owl_home -v /Users/sam/owl_web/:owl_web -v /Users/sam/gitrepos/LabDocs/jupyter_nbs/sam/:/jupyter_nbs -it 0ba43904567e</code>



The command allows access to Jupyter Notebook over port 8888 and makes my Jupyter Notebook GitHub repo and my data files accessible to the Docker container.

Once the container was started, started Jupyter Notebook with the following command inside the Docker container:

`jupyter notebook`

This command is configured in the Docker container to launch a Jupyter Notebook without a browser on port 8888.

Jupyter notebook file: [20161117_docker_oly_genome_fastq_corruption.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20161117_docker_oly_genome_fastq_corruption.ipynb)

I've embedded the notebook below, but it's much easier to view (there are many lengthy commands/filenames that wrap lines in the embedded version below) the actual file linked above.

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=2f6c1b43d4dba60c7a4f3e6dd34d9e2d2eb1f85a&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f326636633162343364346462613630633761346633653664643334643965326432656231663835612f6a7570797465725f6e62732f73616d2f32303136313131375f646f636b65725f6f6c795f67656e6f6d655f66617374715f636f7272757074696f6e2e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20161117_docker_oly_genome_fastq_corruption.ipynb&repository_id=13746500#746552b3-d20c-491b-870f-542a2a412baf" width="100%" height="2000" scrolling="yes"></iframe>
