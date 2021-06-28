---
layout: post
title: Genome Assembly - Olurida_v090 with BGI Illumina and PacBio Hybrid Using Wengan on Mox
date: '2021-05-20 07:38'
tags: 
  - wengan
  - mox
  - Ostrea lurida
  - Olympia oyster
  - BGI
  - PacBio
  - Olurida_v090
  - genome assembly
  - assembly
categories: 
  - Olympia Oyster Genome Assembly
---
[I was recently tasked with adding annotations for our _Ostrea lurida_ genome assembly](https://github.com/RobertsLab/resources/issues/1159) to NCBI. As it turns out, adding just annotation files can't be done since the [genome was initially submitted to ENA](https://robertslab.github.io/sams-notebook/2020/07/08/ENA-Submission-Ostrea-lurida-draft-genome-Olurida_v081.fa.html). Additionally, updating the existing ENA submission with annotations is not possible, as it requires a revocation of the existing genome assembly; requiring a brand new submission. With that being the case, I figured I'd just make a new genome submission with the annotations to NCBI. Unfortunately, there were a number of issues with our genome assembly that were going to require a fair amount of work to resolve. The primary concern was that most of the sequences are considered "low quality" by NCBI (too many and too long stretches of Ns in the sequences). Revising the assembly to make it compatible with the NCBI requirements was going to be too much, so that was abandoned.

So, I decided to look into a low-effort means to try to get a better assembly using a Singularity container running [Wengan](https://github.com/adigenova/wengan) on Mox. It performs assembling and polishing, and is geared towards handling both short- and long-read data. Used all of our BGI Illumina short-read data, as well as all of our PacBio long-read data (see the `fastq_checksums.md5` file in the RESULTS to get a list of all input files.)

I'll refer to the assembly produced here as `Olurida_v090`.




---

#### RESULTS

Runtime was was just under 9hrs:

![Wengan Oly genome assembly on Mox runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210520_olur_wegan_genome-assembly_runtime.png?raw=true)

Output folder:

- [20210520_olur_wegan_genome-assembly/](https://gannet.fish.washington.edu/Atumefaciens/20210520_olur_wegan_genome-assembly/)

  - #### Assembly (FastA):

    - [Olur_v090.SPolished.asm.wengan.fasta (172MB)](https://gannet.fish.washington.edu/Atumefaciens/20210520_olur_wegan_genome-assembly/Olur_v090.SPolished.asm.wengan.fasta)

    - [Olur_v090.SPolished.asm.wengan.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20210520_olur_wegan_genome-assembly/Olur_v090.SPolished.asm.wengan.fasta.fai)

  - #### BED file:

    - [Olur_v090.SPolished.asm.wengan.bed (29MB)](https://gannet.fish.washington.edu/Atumefaciens/20210520_olur_wegan_genome-assembly/Olur_v090.SPolished.asm.wengan.bed)

  - #### Input FastQ checksums:

    - [fastq_checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20210520_olur_wegan_genome-assembly/fastq_checksums.md5)

  - #### Wengan Singularity container:

    - [wengan_v0.2.sif (227MB)](https://gannet.fish.washington.edu/Atumefaciens/20210520_olur_wegan_genome-assembly/wengan_v0.2.sif)


The assembly reulted in 19,009 contigs.

Next up, compare this assembly to our other existing assemblies.