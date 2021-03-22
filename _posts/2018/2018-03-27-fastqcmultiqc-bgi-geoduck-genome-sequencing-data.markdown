---
author: kubu4
comments: true
date: 2018-03-27 21:17:13+00:00
layout: post
slug: fastqcmultiqc-bgi-geoduck-genome-sequencing-data
title: FastQC/MultiQC - BGI Geoduck Genome Sequencing Data
wordpress_id: 3165
author:
  - kubu4
categories:
  - Geoduck Genome Sequencing
tags:
  - BGI
  - FASTQC
  - geoduck
  - mox
  - multiqc
  - Panopea generosa
---

Since running [SparseAssembler seems to be working](https://robertslab.github.io/sams-notebook/2018/03/27/assembly-geoduck-novaseq-using-sparseassembler-kmer-101.html) and actually able to produce assemblies, I've decided I'll try to beef up the geoduck genome assembly with the rest of our existing genomic sequencing data.

I transferred our [BGI geoduck FASTQ files](https://owl.fish.washington.edu/P_generosa_genome_assemblies_BGI/20161201/cdts-hk.genomics.cn/Panopea_generosa/clean_data/) to our Mox node (/gscratch/scrubbed/samwhite/bgi_geoduck/).

I ran FASTQC on them to actually check them out and see if they needed any trimming, as I don't believe this has been done!

FASTQC slurm script: [20180327_fastqc_bgi_geoduck_slurm.sh](https://owl.fish.washington.edu/Athaliana/20180327_bgi_fastqc/20180327_fastqc_bgi_geoduck_slurm.sh)

_Side note: Initial FASTQC failed on one file. Turns out, it got corrupted during transfer! Serves as good reminder about the importance of verifying MD5 checksums after file transfer, prior to attempting to work with files!_

This was followed up with MultiQC (run locally from my computer on the files hosted on Owl). This was performed the following day (20180328).



##### Results:



FASTQC output: [20180327_bgi_fastqc](https://owl.fish.washington.edu/Athaliana/20180327_bgi_fastqc/)

MultiQC output: [20180328_bgi_multiqc](https://owl.fish.washington.edu/Athaliana/20180327_bgi_fastqc/20180328_bgi_multiqc/)

MultiQC HTML report: [20180328_bgi_multiqc/multiqc_report.html](https://owl.fish.washington.edu/Athaliana/20180327_bgi_fastqc/20180328_bgi_multiqc/multiqc_report.html)

Everything looks nice and clean! Waiting on transfer and FASTQC of Illumina NMP data before proceeding to next assembly attempt.

<iframe src="https://owl.fish.washington.edu/Athaliana/20180327_bgi_fastqc/20180328_bgi_multiqc/multiqc_report.html" width="100%" height="2000" scrolling="yes"></iframe>
