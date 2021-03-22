---
author: kubu4
comments: true
date: 2017-10-18 14:07:09+00:00
layout: post
slug: genome-assembly-olympia-oyster-pacbio-canu-v1-6
title: Genome Assembly - Olympia oyster PacBio Canu v1.6
wordpress_id: 2809
author:
  - kubu4
categories:
  - Olympia Oyster Genome Sequencing
tags:
  - canu
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
  - PacBio
---

I decided to run Canu myself, since documentation for [Sean's Canu run](https://genefish.wordpress.com/2017/06/19/seans-notebook-canu-run-finished/) is a bit lacking. Additionally, it looks like he specified a genome size of 500Mbp, which is probably too small. For this assembly, I set the genome size to 1.9Gbp (based on the info in the [BGI assembly report, using 17-mers for calculating genome size](https://github.com/RobertsLab/project-olympia.oyster-genomic/blob/master/docs/20160512_F15FTSUSAT0327_genome_survey.pdf)), which is probably on the large size.

Additionally, I remembered we had [an old PacBio run that we had been forgetting about](https://robertslab.github.io/sams-notebook/2017/10/09/data-management-convert-oly-pacbio-h5-to-fastq.html) and thought it would be nice to have incorporated into an assembly.

See all the messy details of this in the Jupyter Notebook below, but here's the core info about this Canu assembly.

PacBio Input files (available on [Owl/nightingales/O_lurida](https://owl.fish.washington.edu/nightingales/O_lurida/):


    
    <code>m170308_163922_42134_c101174252550000001823269408211742_s1_p0_filtered_subreads.fastq.gz                                                               m170308_230815_42134_c101174252550000001823269408211743_s1_p0_filtered_subreads.fastq.gz
    m130619_081336_42134_c100525122550000001823081109281326_s1_p0.fastq                       m170315_001112_42134_c101169372550000001823273008151717_s1_p0_filtered_subreads.fastq.gz
    m170211_224036_42134_c101073082550000001823236402101737_s1_X0_filtered_subreads.fastq.gz  m170315_063041_42134_c101169382550000001823273008151700_s1_p0_filtered_subreads.fastq.gz
    m170301_100013_42134_c101174162550000001823269408211761_s1_p0_filtered_subreads.fastq.gz  m170315_124938_42134_c101169382550000001823273008151701_s1_p0_filtered_subreads.fastq.gz
    m170301_162825_42134_c101174162550000001823269408211762_s1_p0_filtered_subreads.fastq.gz  m170315_190851_42134_c101169382550000001823273008151702_s1_p0_filtered_subreads.fastq.gz
    m170301_225711_42134_c101174162550000001823269408211763_s1_p0_filtered_subreads.fastq.gz</code>



Canu execution command (see the Jupyter Notebook below for more info):


    
    <code>$time canu \
    useGrid=false \
    -p 20171009_oly_pacbio \
    -d /home/data/20171018_oly_pacbio_canu/ \
    genomeSize=1.9g \
    correctedErrorRate=0.075 \
    -pacbio-raw m*</code>



Results:

Well, this took a LONG time to run; a bit over two days!

The report file contains some interesting tidbits. For instance:





  * Unitgigging calculates only 1.84x coverage


  * Trimming removed >5 billion (!!) bases: `867850 reads 5755379456 bases (reads with no overlaps, deleted)`


  * Unitigging unassembled: `unassembled: 479693 sequences, total length 2277137864 bp`



I'll compare this Canu assembly against [Sean's Canu assembly](https://owl.fish.washington.edu/scaphapoda/Sean/Oly_Canu_Output/oly_pacbio_.contigs.fasta) and see how things look.

Report file (text file): [https://owl.fish.washington.edu/Athaliana/20171018_oly_pacbio_canu/20171018_oly_pacbio.report](http://owl.fish.washington.edu/Athaliana/20171018_oly_pacbio_canu/20171018_oly_pacbio.report)

Contigs Assembly (FASTA): [https://owl.fish.washington.edu/Athaliana/20171018_oly_pacbio_canu/20171018_oly_pacbio.contigs.fasta](http://owl.fish.washington.edu/Athaliana/20171018_oly_pacbio_canu/20171018_oly_pacbio.contigs.fasta)

Complete Canu output directory: [https://owl.fish.washington.edu/Athaliana/20171018_oly_pacbio_canu/](http://owl.fish.washington.edu/Athaliana/20171018_oly_pacbio_canu/)

Jupyter Notebook (GitHub): [20171018_docker_oly_canu.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20171018_docker_oly_canu.ipynb)

<iframe src="https://render.githubusercontent.com/view/ipynb?commit=06f41e8c62f1bbf7d5351126f8f4d32e3384f076&enc_url=68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f73723332302f4c6162446f63732f303666343165386336326631626266376435333531313236663866346433326533333834663037362f6a7570797465725f6e62732f73616d2f32303137313031385f646f636b65725f6f6c795f63616e752e6970796e62&nwo=sr320%2FLabDocs&path=jupyter_nbs%2Fsam%2F20171018_docker_oly_canu.ipynb&repository_id=13746500&repository_type=Repository#bfb8aefd-4cf7-477a-8cb6-5cfdc0584800" width="100%" height="2000" scrolling="yes"></iframe>
