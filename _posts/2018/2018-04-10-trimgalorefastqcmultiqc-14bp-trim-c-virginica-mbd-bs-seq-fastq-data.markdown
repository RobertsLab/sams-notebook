---
author: kubu4
comments: true
date: 2018-04-10 20:40:00+00:00
layout: post
slug: trimgalorefastqcmultiqc-14bp-trim-c-virginica-mbd-bs-seq-fastq-data
title: TrimGalore/FastQC/MultiQC - 14bp Trim C.virginica MBD BS-seq FASTQ data
wordpress_id: 3231
author:
  - kubu4
categories:
  - Miscellaneous
tags:
  - Crassostrea virginica
  - Eastern oyster
  - FASTQC
  - MBD-Seq
  - multiqc
  - TrimGalore!
  - ZymoResearch
---

[Yesterday, I ran TrimGalore/FastQC/MultiQC on the _Crassostrea virginica_ MBD BS-seq data from ZymoResearch](https://robertslab.github.io/sams-notebook/2018/04/09/trimgalorefastqcmultiqc-auto-trim-c-virginica-mbd-bs-seq-fastq-data.html) with the default settings (i.e. "auto-trim"). There was still some variability in the first ~15bp of the reads and Steven wanted to see how a hard trim would change things.

I ran [TrimGalore](https://github.com/FelixKrueger/TrimGalore) (using the built-in FastQC option), with a hard trim of the first 14bp of each read and followed up with MultiQC for a summary of the FastQC reports.

TrimGalore job script:





  * [20180410_trimgalore_trim14bp_Cvirginica_MDB.sh](https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp_Cvirginica_MBD/20180410_trimgalore_trim14bp_Cvirginica_MDB.sh)



Standard error was redirected on the command line to this file:



  * [20180410_trimgalore_trim14bp_Cvirginica_MBD/stderr.log](https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp_Cvirginica_MBD/stderr.log)



MD5 checksums were generated on the resulting trimmed FASTQ files:



  * [20180410_trimgalore_trim14bp_Cvirginica_MBD/checksums.md5](https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp_Cvirginica_MBD/checksums.md5)



All data was copied to my folder on Owl.

Checksums for FASTQ files were verified post-data transfer (data not shown).



##### Results:



Output folder:





  * [20180410_trimgalore_trim14bp_Cvirginica_MBD/](https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp_Cvirginica_MBD/)



FastQC output folder:



  * [20180410_trimgalore_trim14bp_Cvirginica_MBD/20180410_fastqc_trimgalore_trim14bp_Cvirginica_MBD/](https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp_Cvirginica_MBD/20180410_fastqc_trimgalore_trim14bp_Cvirginica_MBD/)



MultiQC output folder:



  * [20180410_trimgalore_trim14bp_Cvirginica_MBD/20180410_fastqc_trimgalore_trim14bp_Cvirginica_MBD/multiqc_data/](https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp_Cvirginica_MBD/20180410_fastqc_trimgalore_trim14bp_Cvirginica_MBD/multiqc_data/)



MultiQC HTML report:



  * [20180410_trimgalore_trim14bp_Cvirginica_MBD/20180410_fastqc_trimgalore_trim14bp_Cvirginica_MBD/multiqc_data/multiqc_report.html](https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp_Cvirginica_MBD/20180410_fastqc_trimgalore_trim14bp_Cvirginica_MBD/multiqc_data/multiqc_report.html)



OK, this trimming definitely took care of the variability seen in the first ~15bp of all the reads.

However, I noticed that the last 2bp of each of the Read 1 seqs all have some wonky stuff going on. I'm guessing I should probably trim that stuff off, too...

<iframe src="https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp_Cvirginica_MBD/20180410_fastqc_trimgalore_trim14bp_Cvirginica_MBD/multiqc_data/multiqc_report.html" width="100%" height="2000" scrolling="yes"></iframe>
