---
layout: post
title: Data Received - C.virginica OA Larvae DNA Methylation FastQs from Lotterhos Lab
date: '2022-01-19 10:02'
tags: 
  - Crassostrea virginica
  - Eastern oyster
  - larvae
  - DNA methylation
  - data received
categories: 
  - Data Received
---
In [this GitHub Issue](https://github.com/RobertsLab/resources/issues/1362) Steven asked that I download [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) OA larval DNA methylation sequencing data from the Lotterhos Lab. The data is part of this project (_private_ GitHub repo): [epigeneticstoocean/2018_L18_OAExp_Cvirginica_DNAm(https://github.com/epigeneticstoocean/2018_L18_OAExp_Cvirginica_DNAm). Alan Downey-Wall provided me with a [GlobusConnect](https://www.globus.org/globus-connect-personal) link to the data.

Here's the README file provided with the data:

```
Discovery folder corresponding to the 2018 larvae OA exposure dna methylation project

Contents
	This folder contains all DNA methylation data (both raw and processed) related to the larvae
	associated with the 2018 exposure experiment. In the RAW folder contains WGBS sequence data run
	one 2 lanes of 150bp novaseq for 33 samples.

Associated Github Repository
	https://github.com/epigeneticstoocean/2018OAlarvae_DNAm 

Files
	/RAW		- Raw sequence files from GENEwIZ
	/trimmed_files  - Trimmed sequence files and associated fastq files (trimmed using trim_galore)
	/mapped_files	- File outputs from mapping (including initial mapping, deduplication, and bam file outputs)
	/cpg_report	- Outputs from the bismark cytosine report summary function. Used for creating CpG summary files 
	/src		- Scripts
	/slurm_log	- Outputs from running slurm scripts associated with data processing
	/multiqc_data 	- Files associated with multi_qc summary
  ```

Since we don't have Globus installed on Owl, I used Mox as an intermediate.

Data was transferred from `2018OALarvae_DNAm_discovery/RAW/` via Globus to Mox `/gscratch/scrubbed/samwhite/data/C_virginica/`:

![screencap of globus transfer confirmation](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20220119-globus_data_transfer-lotterhos-dna-methylation-cvir-larvae.png?raw=true)

I then `rsync`'d the data to [`Owl/nightingales/C_virginica2018OALarvae_DNAm_discovery/`](https://owl.fish.washington.edu/nightingales/C_virginica/2018OALarvae_DNAm_discovery/).
