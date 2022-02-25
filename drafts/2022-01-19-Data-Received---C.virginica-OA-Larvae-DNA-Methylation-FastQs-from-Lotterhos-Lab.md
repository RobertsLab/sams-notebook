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

Contents:

```
├── CF01-CM01-Zygote_R1_001.fastq.gz
├── CF01-CM01-Zygote_R2_001.fastq.gz
├── CF01-CM02-Larvae_R1_001.fastq.gz
├── CF01-CM02-Larvae_R2_001.fastq.gz
├── CF02-CM02-Zygote_R1_001.fastq.gz
├── CF02-CM02-Zygote_R2_001.fastq.gz
├── CF03-CM03-Zygote_R1_001.fastq.gz
├── CF03-CM03-Zygote_R2_001.fastq.gz
├── CF03-CM04-Larvae_R1_001.fastq.gz
├── CF03-CM04-Larvae_R2_001.fastq.gz
├── CF03-CM05-Larvae_R1_001.fastq.gz
├── CF03-CM05-Larvae_R2_001.fastq.gz
├── CF04-CM04-Zygote_R1_001.fastq.gz
├── CF04-CM04-Zygote_R2_001.fastq.gz
├── CF05-CM02-Larvae_R1_001.fastq.gz
├── CF05-CM02-Larvae_R2_001.fastq.gz
├── CF05-CM05-Zygote_R1_001.fastq.gz
├── CF05-CM05-Zygote_R2_001.fastq.gz
├── CF06-CM01-Zygote_R1_001.fastq.gz
├── CF06-CM01-Zygote_R2_001.fastq.gz
├── CF06-CM02-Larvae_R1_001.fastq.gz
├── CF06-CM02-Larvae_R2_001.fastq.gz
├── CF07-CM02-Zygote_R1_001.fastq.gz
├── CF07-CM02-Zygote_R2_001.fastq.gz
├── CF08-CM03-Zygote_R1_001.fastq.gz
├── CF08-CM03-Zygote_R2_001.fastq.gz
├── CF08-CM04-Larvae_R1_001.fastq.gz
├── CF08-CM04-Larvae_R2_001.fastq.gz
├── CF08-CM05-Larvae_R1_001.fastq.gz
├── CF08-CM05-Larvae_R2_001.fastq.gz
├── EF01-EM01-Zygote_R1_001.fastq.gz
├── EF01-EM01-Zygote_R2_001.fastq.gz
├── EF02-EM02-Zygote_R1_001.fastq.gz
├── EF02-EM02-Zygote_R2_001.fastq.gz
├── EF03-EM03-Zygote_R1_001.fastq.gz
├── EF03-EM03-Zygote_R2_001.fastq.gz
├── EF03-EM04-Larvae_R1_001.fastq.gz
├── EF03-EM04-Larvae_R2_001.fastq.gz
├── EF03-EM05-Larvae_R1_001.fastq.gz
├── EF03-EM05-Larvae_R2_001.fastq.gz
├── EF04-EM04-Zygote_R1_001.fastq.gz
├── EF04-EM04-Zygote_R2_001.fastq.gz
├── EF04-EM05-Larvae_R1_001.fastq.gz
├── EF04-EM05-Larvae_R2_001.fastq.gz
├── EF05-EM01-Larvae_R1_001.fastq.gz
├── EF05-EM01-Larvae_R2_001.fastq.gz
├── EF05-EM05-Zygote_R1_001.fastq.gz
├── EF05-EM05-Zygote_R2_001.fastq.gz
├── EF05-EM06-Larvae_R1_001.fastq.gz
├── EF05-EM06-Larvae_R2_001.fastq.gz
├── EF06-EM01-Larvae_R1_001.fastq.gz
├── EF06-EM01-Larvae_R2_001.fastq.gz
├── EF06-EM02-Larvae_R1_001.fastq.gz
├── EF06-EM02-Larvae_R2_001.fastq.gz
├── EF06-EM06-Larvae_R1_001.fastq.gz
├── EF06-EM06-Larvae_R2_001.fastq.gz
├── EF07-EM01-Zygote_R1_001.fastq.gz
├── EF07-EM01-Zygote_R2_001.fastq.gz
├── EF07-EM03-Larvae_R1_001.fastq.gz
├── EF07-EM03-Larvae_R2_001.fastq.gz
├── EF08-EM03-Larvae_R1_001.fastq.gz
├── EF08-EM03-Larvae_R2_001.fastq.gz
├── EF08-EM04-Larvae_R1_001.fastq.gz
├── EF08-EM04-Larvae_R2_001.fastq.gz
├── md5sum_list.txt
├── sample_files.txt
└── second_lane
    ├── CF01-CM01-Zygote_R2_001.fastq.gz
    ├── CF01-CM02-Larvae_R1_001.fastq.gz
    ├── CF01-CM02-Larvae_R2_001.fastq.gz
    ├── CF02-CM02-Zygote_R1_001.fastq.gz
    ├── CF02-CM02-Zygote_R2_001.fastq.gz
    ├── CF03-CM03-Zygote_R1_001.fastq.gz
    ├── CF03-CM03-Zygote_R2_001.fastq.gz
    ├── CF03-CM04-Larvae_R1_001.fastq.gz
    ├── CF03-CM04-Larvae_R2_001.fastq.gz
    ├── CF03-CM05-Larvae_R1_001.fastq.gz
    ├── CF03-CM05-Larvae_R2_001.fastq.gz
    ├── CF04-CM04-Zygote_R1_001.fastq.gz
    ├── CF04-CM04-Zygote_R2_001.fastq.gz
    ├── CF05-CM02-Larvae_R1_001.fastq.gz
    ├── CF05-CM02-Larvae_R2_001.fastq.gz
    ├── CF05-CM05-Zygote_R1_001.fastq.gz
    ├── CF05-CM05-Zygote_R2_001.fastq.gz
    ├── CF06-CM01-Zygote_R1_001.fastq.gz
    ├── CF06-CM01-Zygote_R2_001.fastq.gz
    ├── CF06-CM02-Larvae_R1_001.fastq.gz
    ├── CF06-CM02-Larvae_R2_001.fastq.gz
    ├── CF07-CM02-Zygote_R1_001.fastq.gz
    ├── CF07-CM02-Zygote_R2_001.fastq.gz
    ├── CF08-CM03-Zygote_R1_001.fastq.gz
    ├── CF08-CM03-Zygote_R2_001.fastq.gz
    ├── CF08-CM04-Larvae_R1_001.fastq.gz
    ├── CF08-CM05-Larvae_R1_001.fastq.gz
    ├── CF08-CM05-Larvae_R2_001.fastq.gz
    ├── EF01-EM01-Zygote_R1_001.fastq.gz
    ├── EF01-EM01-Zygote_R2_001.fastq.gz
    ├── EF02-EM02-Zygote_R1_001.fastq.gz
    ├── EF02-EM02-Zygote_R2_001.fastq.gz
    ├── EF03-EM03-Zygote_R1_001.fastq.gz
    ├── EF03-EM04-Larvae_R1_001.fastq.gz
    ├── EF03-EM04-Larvae_R2_001.fastq.gz
    ├── EF03-EM05-Larvae_R1_001.fastq.gz
    ├── EF03-EM05-Larvae_R2_001.fastq.gz
    ├── EF04-EM04-Zygote_R1_001.fastq.gz
    ├── EF04-EM04-Zygote_R2_001.fastq.gz
    ├── EF04-EM05-Larvae_R1_001.fastq.gz
    ├── EF04-EM05-Larvae_R2_001.fastq.gz
    ├── EF05-EM01-Larvae_R1_001.fastq.gz
    ├── EF05-EM01-Larvae_R2_001.fastq.gz
    ├── EF05-EM05-Zygote_R1_001.fastq.gz
    ├── EF05-EM05-Zygote_R2_001.fastq.gz
    ├── EF05-EM06-Larvae_R1_001.fastq.gz
    ├── EF05-EM06-Larvae_R2_001.fastq.gz
    ├── EF06-EM01-Larvae_R1_001.fastq.gz
    ├── EF06-EM01-Larvae_R2_001.fastq.gz
    ├── EF06-EM02-Larvae_R1_001.fastq.gz
    ├── EF06-EM02-Larvae_R2_001.fastq.gz
    ├── EF06-EM06-Larvae_R1_001.fastq.gz
    ├── EF06-EM06-Larvae_R2_001.fastq.gz
    ├── EF07-EM01-Zygote_R1_001.fastq.gz
    ├── EF07-EM01-Zygote_R2_001.fastq.gz
    ├── EF07-EM03-Larvae_R1_001.fastq.gz
    ├── EF07-EM03-Larvae_R2_001.fastq.gz
    ├── EF08-EM03-Larvae_R1_001.fastq.gz
    ├── EF08-EM03-Larvae_R2_001.fastq.gz
    ├── EF08-EM04-Larvae_R1_001.fastq.gz
    ├── EF08-EM04-Larvae_R2_001.fastq.gz
    ├── file_labels.txt
    └── md5sum_list.txt
```