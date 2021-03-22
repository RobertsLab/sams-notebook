---
author: kubu4
comments: true
date: 2016-07-18 20:35:51+00:00
layout: post
slug: computing-not-enough-power
title: Computing - Not Enough Power!
wordpress_id: 2229
author:
  - kubu4
categories:
  - Miscellaneous
tags:
  - computing
  - EC2
  - jupyter notebook
  - pyrad
  - stacks
  - ustacks
---

Well, [I tackled the storage space issue by expanding the EC2 Instance to have a 1000GB of storage space](https://robertslab.github.io/sams-notebook/2016/07/17/computing-amazon-ec2-instance-out-of-space.html). Now that that's no longer a concern, it turns out I'm running up against processing/memory limits!

I'm running the EC2 c4.2xlarge (Ubuntu 14.04 LTS, 8 vCPUs, 16 GiB RAM) instance.

I'm trying to run two programs simultaneously: [PyRad](https://dereneaton.com/software/pyrad/) and [Stacks](http://catchenlab.life.illinois.edu/stacks/) (specifically, the ustacks "sub" program).

PyRad keeps crashing with some memory error stuff (see embedded Jupyter Notebook at the end of this post).

Used the following Bash program to visualize what's happening with the EC2 Instance resources (i.e. processors and RAM utilization):


    
    <code>htop</code>



Downloaded/installed to EC2 Instance using:


    
    <code>sudo apt-get install htop</code>





I see why PyRad is dying. Here are two screen captures that show what resources are being used (click to see detail):



![](https://eagle.fish.washington.edu/Arabidopsis/20160718_ec2_ustacks_cpus.png)(http://eagle.fish.washington.edu/Arabidopsis/20160718_ec2_ustacks_cpus.png)



![](https://eagle.fish.washington.edu/Arabidopsis/20160718_ec2_ustacks_mem.png)(http://eagle.fish.washington.edu/Arabidopsis/20160718_ec2_ustacks_mem.png)





The top image shows that ustacks is using 100% of all eight CPUs!

The second image shows when ustacks is finishing with one of the files it's processing, it uses all of the memory (16GBs)!

So, I will have to wait until ustacks is finished running before being able to continue with PyRad.

If I want to be able to run these simultaneously, I can (using either of these options still requires me to wait until ustacks completes in order to manipulate the current EC2 instance to accommodate either of the two following options):





  * Increase the computing resources of this EC2 Instance



  * Create an additional EC2 Instance and run PyRad on one and Stacks programs on the other.








Here's the Jupyter Notebook with the PyRad errors (see "Step 3: Clustering" section):


    
    <code><iframe src="https://render.githubusercontent.com/view/ipynb?commit=f9a4627317620dc69e7c7502aec1894f10ac3254&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f663961343632373331373632306463363965376337353032616563313839346631306163333235342f6a7570797465725f6e62732f73616d2f32303136303731355f6563325f6f6c795f6762735f70797261642e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20160715_ec2_oly_gbs_pyrad.ipynb&repository_id=13746500#a22d1ce9-8f2d-419d-a0a5-446aba32da60" width="100%" height="2000" scrolling="yes"></iframe>
    </code>
