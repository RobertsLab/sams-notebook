---
author: kubu4
comments: true
date: 2018-04-11 21:26:58+00:00
layout: post
slug: trimgalorefastqcmultiqc-trim-10bp-53-ends-c-virginica-mbd-bs-seq-fastq-data
title: TrimGalore/FastQC/MultiQC - Trim 10bp 5'/3' ends C.virginica MBD BS-seq FASTQ
  data
wordpress_id: 3251
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

Steven found out that the [Bismarck documentation (Bismarck is the bisulfite aligner we use in our BS-seq pipeline) suggests trimming 10bp from both the 5' and 3' ends.](https://github.com/FelixKrueger/Bismark/tree/master/Docs#viii-notes-about-different-library-types-and-commercial-kits) Since this is the next step in our pipeline, we figured we should probably just follow their recommendations!

TrimGalore job script:





  * [20180410_trimgalore_trim14bp_Cvirginica_MDB.sh](https://owl.fish.washington.edu/Athaliana/20180411_trimgalore_10bp_Cvirginica_MBD/20180411_trimgalore_trim_10bp_Cvirginica_MBD.sh)



Standard error was redirected on the command line to this file:



  * [20180411_trimgalore_10bp_Cvirginica_MBD/stderr.log](https://owl.fish.washington.edu/Athaliana/20180411_trimgalore_10bp_Cvirginica_MBD/stderr.log)



MD5 checksums were generated on the resulting trimmed FASTQ files:



  * [20180411_trimgalore_10bp_Cvirginica_MBD/checksums.md5](https://owl.fish.washington.edu/Athaliana/20180411_trimgalore_10bp_Cvirginica_MBD/checksums.md5)



All data was copied to my folder on Owl.

Checksums for FASTQ files were verified post-data transfer (data not shown).



##### Results:



Output folder:





  * [20180411_trimgalore_10bp_Cvirginica_MBD](https://owl.fish.washington.edu/Athaliana/20180411_trimgalore_10bp_Cvirginica_MBD/)



FastQC output folder:



  * [20180411_trimgalore_10bp_Cvirginica_MBD/20180411_fastqc_trim_10bp_Cvirginica_MBD](https://owl.fish.washington.edu/Athaliana/20180411_trimgalore_10bp_Cvirginica_MBD/20180411_fastqc_trim_10bp_Cvirginica_MBD/)



MultiQC output folder:



  * [20180411_trimgalore_10bp_Cvirginica_MBD/20180411_fastqc_trim_10bp_Cvirginica_MBD/multiqc_data/](https://owl.fish.washington.edu/Athaliana/20180411_trimgalore_10bp_Cvirginica_MBD/20180411_fastqc_trim_10bp_Cvirginica_MBD/multiqc_data/)



MultiQC HTML report:



  * [20180411_trimgalore_10bp_Cvirginica_MBD/20180411_fastqc_trim_10bp_Cvirginica_MBD/multiqc_data/multiqc_report.html](https://owl.fish.washington.edu/Athaliana/20180411_trimgalore_10bp_Cvirginica_MBD/20180411_fastqc_trim_10bp_Cvirginica_MBD/multiqc_data/multiqc_report.html)



Hey! Look at that! Everything is much better! Thanks for the excellent documentation and suggestions, Bismarck!

<iframe src="https://owl.fish.washington.edu/Athaliana/20180411_trimgalore_10bp_Cvirginica_MBD/20180411_fastqc_trim_10bp_Cvirginica_MBD/multiqc_data/multiqc_report.html" width="100%" height="2000" scrolling="yes"></iframe>
