---
author: kubu4
comments: true
date: 2016-12-15 22:46:19+00:00
layout: post
slug: data-management-integrity-check-of-final-bgi-olympia-oyster-geoduck-data
title: Data Management - Integrity Check of Final BGI Olympia Oyster & Geoduck Data
wordpress_id: 2403
author:
  - kubu4
categories:
  - Geoduck Genome Sequencing
  - Olympia Oyster Genome Sequencing
tags:
  - array
  - bash
  - BGI
  - checksum
  - geoduck
  - jupyter notebook
  - md5
  - olympia oyster
  - Ostrea lurida
  - ostrich
  - Panopea generosa
  - parameter substitution
---

After completing the downloads of these files from BGI, I needed to verify that the downloaded copies matched the originals. Below is a Jupyter Notebook detailing how I verified file integrity via MD5 checksums. It also highlights the importance of doing this check when working with large sequencing files (or, just large files in general), as a few of them had mis-matching MD5 checksums!

Although the notebook is embedded below, it might be easier viewing via the notebook link (hosted on GitHub).

At the end of the day, I had to re-download some files, but all the MD5 checksums match and these data are ready for analysis:

[Final _Ostrea lurida_ genome files](https://owl.fish.washington.edu/O_lurida_genome_assemblies_BGI/20161201/cdts-hk.genomics.cn/Ostrea_lurida/)

[Final _Panopea generosa_ genome files](https://owl.fish.washington.edu/P_generosa_genome_assemblies_BGI/20161201/cdts-hk.genomics.cn/Panopea_generosa/)

Jupyter Notebook: [20161214_docker_BGI_data_integrity_check.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20161214_docker_BGI_data_integrity_check.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=7f2c53f35e54deb21c89f7a634316d5806699d87&enc;_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f376632633533663335653534646562323163383966376136333433313664353830363639396438372f6a7570797465725f6e62732f73616d2f32303136313231345f646f636b65725f4247495f646174615f696e746567726974795f636865636b2e6970796e62&nwo;=sr320%2FLabDocs&path;=jupyter_nbs%2Fsam%2F20161214_docker_BGI_data_integrity_check.ipynb&repository;_id=13746500#6a812626-7d26-46c9-98b0-73f5a8e136b3" width="100%" height="2000" scrolling="yes"></iframe>
