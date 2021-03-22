---
author: kubu4
comments: true
date: 2016-12-30 21:38:38+00:00
layout: post
slug: data-management-geoduck-rrbs-data-integrity-verification
title: Data Management - Geoduck RRBS Data Integrity Verification
wordpress_id: 2430
author:
  - kubu4
categories:
  - Miscellaneous
tags:
  - geoduck
  - jupyter notebook
  - md5
  - Panopea generosa
  - RRBS
---

[Yesterday, I downloaded the Illumina FASTQ files provided by Genewiz](https://robertslab.github.io/sams-notebook/2016/12/29/data-received-geoduck-rrbs-sequencing-data.html) for Hollie Putnam's reduced representation bisulfite geoduck libraries. However, Genewiz had not provided a checksum file at the time.

I received the checksum file from Genewiz and have verified that the data is intact. Verification is described in the Jupyter notebook below.

Data files are located here: [owl/web/nightingales/P_generosa](https://owl.fish.washington.edu/nightingales/P_generosa/)

Jupyter notebook (GitHub): [20161230_docker_geoduck_RRBS_md5_checks.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20161230_docker_geoduck_RRBS_md5_checks.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=d543fd8f5447830f82621eb072b5ce5c3ddb1d5b&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f643534336664386635343437383330663832363231656230373262356365356333646462316435622f6a7570797465725f6e62732f73616d2f32303136313233305f646f636b65725f67656f6475636b5f525242535f6d64355f636865636b732e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20161230_docker_geoduck_RRBS_md5_checks.ipynb&repository_id=13746500#a0b8069d-0253-4a59-a3d0-7f63a7fba75f" width="100%" height="2000" scrolling="yes"></iframe>
