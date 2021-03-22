---
author: kubu4
comments: true
date: 2016-07-17 19:46:21+00:00
layout: post
slug: computing-amazon-ec2-instance-out-of-space
title: Computing - Amazon EC2 Instance Out of Space?
wordpress_id: 2223
author:
  - kubu4
categories:
  - Genotype-by-sequencing at BGI
  - Olympia oyster reciprocal transplant
tags:
  - EC2
  - jupyter notebook
  - pyrad
---

Running PyRad analysis on the Olympia oyster GBS data. PyRad exited with warnings about running out of space. However, looking at free disk space on the EC2 Instance suggests that there's still space left on the disk. Possibly PyRad monitors the expected disk space usage during analysis to verify there will be sufficient disk space to write to? Regardless, will expand EC2 volume instance to a larger size...

![](https://eagle.fish.washington.edu/Arabidopsis/20160717_ec2_out_of_space.png)(http://eagle.fish.washington.edu/Arabidopsis/20160717_ec2_out_of_space.png)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=a63ac11b57c693a7762dec20508c796cc8575ff4&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f613633616331316235376336393361373736326465633230353038633739366363383537356666342f6a7570797465725f6e62732f73616d2f32303136303731355f6563325f6f6c795f6762735f70797261642e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20160715_ec2_oly_gbs_pyrad.ipynb&repository_id=13746500#c4fc33df-e3eb-4377-b469-28e11bf518f6" width="100%" height="2000" scrolling="yes"></iframe>




