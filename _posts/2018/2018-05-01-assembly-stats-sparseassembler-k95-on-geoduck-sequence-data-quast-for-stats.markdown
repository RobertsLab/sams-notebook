---
author: kubu4
comments: true
date: 2018-05-01 22:06:32+00:00
layout: post
slug: assembly-stats-sparseassembler-k95-on-geoduck-sequence-data-quast-for-stats
title: Assembly & Stats - SparseAssembler (k95) on Geoduck Sequence Data > Quast for
  Stats
wordpress_id: 3327
author:
  - kubu4
categories:
  - Geoduck Genome Sequencing
tags:
  - geoduck
  - mox
  - Panopea generosa
  - QUAST
  - SparseAssembler
---

[Had a successful assembly with SparseAssembler k101](https://robertslab.github.io/sams-notebook/2018/04/05/genome-assembly-sparseassembler-geoduck-genomic-data-kmer101.html), but figured I'd just tweak the kmer setting and throw it in the queue and see how it compares; minimal effort/time needed.

Initiatied an assembly run using  [SparseAssembler](https://github.com/yechengxi/SparseAssembler) on our [Mox HPC node](https://github.com/RobertsLab/hyak_mox/wiki) on all of our geoduck genomic sequencing data:





  * [BGI HiSeq Data](https://robertslab.github.io/sams-notebook/2018/03/27/fastqcmultiqc-bgi-geoduck-genome-sequencing-data.html)



  * [Illumina Mate Pair HiSeq Data](https://robertslab.github.io/sams-notebook/2018/04/01/trimgalorefastqcmultiqc-illumina-hiseq-genome-sequencing-data-continued.html)



  * [Illumina NovaSeq Data](https://robertslab.github.io/sams-notebook/2018/01/25/adapter-trimming-and-fastqc-illumina-geoduck-novaseq-data.html)






Kmer size set to 95.

Slurm script: [20180423_sparse_assembler_kmer95_geoduck_slurm.sh](https://owl.fish.washington.edu/Athaliana/20180423_sparseassembler_kmer95_geoduck/20180423_sparse_assembler_kmer95_geoduck_slurm.sh)

After the run finished, I copied the files to our server (Owl) and then ran Quast on my computer to gather some assembly stats, using the following command:


    
    <code>
    /home/sam/software/quast-4.5/quast.py \
    -t 24 \
    --labels 20180423_sparse_k95 \
    /mnt/owl/Athaliana/20180423_sparseassembler_kmer95_geoduck/Contigs.txt \
    </code>





* * *





##### Results:



SparseAssembler output folder: [20180423_sparseassembler_kmer95_geoduck/](https://owl.fish.washington.edu/Athaliana/20180423_sparseassembler_kmer95_geoduck/)

SparseAsembler assembley (FastA; 15GB): [20180423_sparseassembler_kmer95_geoduck/Contigs.txt](https://owl.fish.washington.edu/Athaliana/20180423_sparseassembler_kmer95_geoduck/Contigs.txt)

Quast output folder: [quast_results/results_2018_05_10_15_04_07](https://owl.fish.washington.edu/Athaliana/quast_results/results_2018_05_10_15_04_07/)

Quast report (HTML): [quast_results/results_2018_05_10_15_04_07/report.html](https://owl.fish.washington.edu/Athaliana/quast_results/results_2018_05_10_15_04_07/report.html)

I've embedded the Quast HTML report below, but it may be easier to view by using the link above.

Well, it's remarkable how different this is than the [previous SparseAssembler with k101 setting](https://robertslab.github.io/sams-notebook/2018/04/05/genome-assembly-sparseassembler-geoduck-genomic-data-kmer101.html)!

This assembly doesn't have a single contig >50,000bp, while the previous one has four contigs over that threshold!

Definitely shows what a large impact the kmer setting in assembly software can have on the final assembly!

<iframe src="https://owl.fish.washington.edu/Athaliana/quast_results/results_2018_05_10_15_04_07/report.html" width="100%" height="2000" scrolling="yes"></iframe>
