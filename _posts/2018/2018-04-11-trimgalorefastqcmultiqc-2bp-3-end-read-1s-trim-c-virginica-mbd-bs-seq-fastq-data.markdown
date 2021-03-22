---
author: kubu4
comments: true
date: 2018-04-11 00:00:01+00:00
layout: post
slug: trimgalorefastqcmultiqc-2bp-3-end-read-1s-trim-c-virginica-mbd-bs-seq-fastq-data
title: TrimGalore/FastQC/MultiQC - 2bp 3' end Read 1s Trim C.virginica MBD BS-seq
  FASTQ data
wordpress_id: 3234
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

[Earlier today, I ran TrimGalore/FastQC/MultiQC on the _Crassostrea virginica_ MBD BS-seq data from ZymoResearch](https://robertslab.github.io/sams-notebook/2018/04/10/trimgalorefastqcmultiqc-14bp-trim-c-virginica-mbd-bs-seq-fastq-data.html) and hard trimmed the first 14bp from each read. Things looked better at the 5' end, but the 3' end of each of the READ1 seqs showed a wonky 2bp blip, so decided to trim that off.

I ran [TrimGalore](https://github.com/FelixKrueger/TrimGalore) (using the built-in FastQC option), with a hard trim of the last 2bp of each first read set that had previously had the 14bp hard trim and followed up with MultiQC for a summary of the FastQC reports.

TrimGalore job script:





  * [20180410_trimgalore_trim14bp_Cvirginica_MDB.sh](https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp5prim_2bp3prime_Cvirginica_MBD/20180410_trimgalore_trim14bp_Cvirginica_MDB.sh)



Standard error was redirected on the command line to this file:



  * [20180410_trimgalore_trim14bp5prim_2bp3prime_Cvirginica_MBD/stderr.log](https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp5prim_2bp3prime_Cvirginica_MBD/stderr.log)



MD5 checksums were generated on the resulting trimmed FASTQ files:



  * [20180410_trimgalore_trim14bp5prim_2bp3prime_Cvirginica_MBD/checksums.md5](https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp5prim_2bp3prime_Cvirginica_MBD/checksums.md5)



All data was copied to my folder on Owl.

Checksums for FASTQ files were verified post-data transfer (data not shown).



##### Results:



Output folder:





  * [20180410_trimgalore_trim14bp5prim_2bp3prime_Cvirginica_MBD/](https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp5prim_2bp3prime_Cvirginica_MBD/)



FastQC output folder:



  * [20180410_trimgalore_trim14bp5prim_2bp3prime_Cvirginica_MBD/20180410_fastqc_trimgalore_14bp5prime_2bp3prime_Cvirginica_MBD/](https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp_Cvirginica_MBD/20180410_fastqc_trimgalore_trim14bp_Cvirginica_MBD/)



MultiQC output folder:



  * [20180410_trimgalore_trim14bp5prim_2bp3prime_Cvirginica_MBD/20180410_fastqc_trimgalore_14bp5prime_2bp3prime_Cvirginica_MBD/multiqc_data/](https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp5prim_2bp3prime_Cvirginica_MBD/20180410_fastqc_trimgalore_14bp5prime_2bp3prime_Cvirginica_MBD/multiqc_data/)



MultiQC HTML report:



  * [20180410_trimgalore_trim14bp5prim_2bp3prime_Cvirginica_MBD/20180410_fastqc_trimgalore_14bp5prime_2bp3prime_Cvirginica_MBD/multiqc_data/multiqc_report.html](https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp5prim_2bp3prime_Cvirginica_MBD/20180410_fastqc_trimgalore_14bp5prime_2bp3prime_Cvirginica_MBD/multiqc_data/multiqc_report.html)



Well, this is a bit strange, but the 2bp trimming on the read 1s looks fine, but now the read 2s are weird in the same region!

Regardless, while this was running, Steven found out that the [Bismarck documentation (Bismarck is the bisulfite aligner we use in our BS-seq pipeline) suggests trimming 10bp from both the 5' and 3' ends.](https://github.com/FelixKrueger/Bismark/tree/master/Docs#viii-notes-about-different-library-types-and-commercial-kits) So, maybe this was all moot. I'll go ahead and re-run this following the Bismark recommendations.

<iframe src="https://owl.fish.washington.edu/Athaliana/20180410_trimgalore_trim14bp5prim_2bp3prime_Cvirginica_MBD/20180410_fastqc_trimgalore_14bp5prime_2bp3prime_Cvirginica_MBD/multiqc_data/multiqc_report.html" width="100%" height="2000" scrolling="yes"></iframe>
