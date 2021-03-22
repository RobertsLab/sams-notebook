---
author: kubu4
comments: true
date: 2016-02-03 22:47:09+00:00
layout: post
slug: data-received-ostrea-lurida-mbd-enriched-bs-seq
title: Data Received - Ostrea lurida MBD-enriched BS-seq
wordpress_id: 1996
author:
  - kubu4
categories:
  - MBD Enrichment for Sequencing at ZymoResearch
  - Olympia oyster reciprocal transplant
tags:
  - hc1_2B
  - hc1_4B
  - hc2_15B
  - hc2_17
  - hc3_1
  - hc3_10
  - hc3_11
  - hc3_5
  - hc3_7
  - hc3_9
  - ipython notebook
  - jupyter notebook
  - MBD-Seq
  - olympia oyster
  - Ostrea lurida
  - ss2_14B
  - ss2_18B
  - ss2_9B
  - ss3_14B
  - ss3_15B
  - ss3_16B
  - ss3_20
  - ss3_3B
  - ss3_4B
  - ss5_18
  - ZymoResearch
---

Received the Olympia oyster, MBD-enriched BS-seq sequencing files (50bp, single read) from ZymoResearch ([submitted 20151208](https://robertslab.github.io/sams-notebook/2015/12/08/sample-submission-olympia-oyster-mbd-enriched-dna-to-zymoresearch.html)). Here's the sample list:




    
  * E1_hc1_2B

    
  * E1_hc1_4B

    
  * E1_hc2_15B

    
  * E1_hc2_17

    
  * E1_hc3_1

    
  * E1_hc3_5

    
  * E1_hc3_7

    
  * E1_hc3_10

    
  * E1_hc3_11

    
  * E1_ss2_9B

    
  * E1_ss2_14B

    
  * E1_ss2_18B

    
  * E1_ss3_3B

    
  * E1_ss3_14B

    
  * E1_ss3_15B

    
  * E1_ss3_16B

    
  * E1_ss3_20

    
  * E1_ss5_18





The 18 samples listed above had previously been MBD-enriched and then sent to ZymoResearch for bisulfite conversion, multiplex library construction, and subsequent sequencing. The library (multiplex of all samples) was sequenced in a single lane, three times. Thus, we would expect 54 FASTQ files. However, ZymoResearch was dissatisfied with the QC of the initial sequencing run (completed on 20160129), so they re-ran the samples (completed on 20160202). This created two sets of data, resulting in a total of 108 FASTQ files.

ZymoResearch data portal does not allow bulk download of files. However, I ended up using Chrono Download Manager extension for Google Chrome to allow for automated downloading of each file (per ZymoResearch recommendation).

After download, the files were moved to their permanent storage location on Owl: https://owl.fish.washington.edu/nightingales/O_lurida/20160203_mbdseq

The [readme.md](https://owl.fish.washington.edu/nightingales/O_lurida/20160203_mbdseq/readme.md) file was updated to include project/file information.

The file manipulations were performed in a Jupyter notebook (see below).



Total reads generated for this project: **1,481,836,875**



Jupyter Notebook file: [20160203_Olurida_Zymo_Data_Handling.ipynb](https://eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160203_Olurida_Zymo_Data_Handling.ipynb)

Notebook Viewer: [20160203_Olurida_Zymo_Data_Handling.ipynb](https://nbviewer.jupyter.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160203_Olurida_Zymo_Data_Handling.ipynb)

<iframe src="https://nbviewer.jupyter.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160203_Olurida_Zymo_Data_Handling.ipynb" width="100%" height="2000" scrolling="yes"></iframe>
