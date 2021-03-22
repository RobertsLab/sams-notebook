---
author: kubu4
comments: true
date: 2018-03-22 16:25:34+00:00
layout: post
slug: assembly-geoduck-novaseq-using-sparseassembler-tldr-it-worked
title: Assembly - Geoduck NovaSeq using SparseAssembler (TL;DR - it worked!)
wordpress_id: 3146
author:
  - kubu4
categories:
  - Geoduck Genome Sequencing
tags:
  - geoduck
  - NovaSeq
  - Panopea generosa
  - QUAST
  - SparseAssembler
---

The prior attempt using SparseAssembler [failed due to a kmer size that was deemed too large](https://robertslab.github.io/sams-notebook/2018/03/08/assembly-geoduck-novaseq-using-sparseassembler-failed.html).

For this run, I arbitrarily reduced the kmer size by ~half (k 61) in hopes that this will just get through an assembly. We can potentially explore the effects of kmer size on assemblies if/when this runs and depending no how the assembly looks.

The job was run on our Mox node.

Here's the batch script to initiate the job:

[code lang=text]
#!/bin/bash
## Job Name
#SBATCH --job-name=20180313_sparse_assembler_geo_novaseq
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes (We only get 1, so this is fixed)
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=30-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --workdir=/gscratch/scrubbed/samwhite/20180312_SparseAssembler_novaseq_geoduck

/gscratch/srlab/programs/SparseAssembler/SparseAssembler 
LD 0 
NodeCovTh 1 
EdgeCovTh 0 
k 61 
g 15 
PathCovTh 100 
GS 2200000000 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/AD002_S9_L001_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/AD002_S9_L001_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/AD002_S9_L002_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/AD002_S9_L002_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR005_S4_L001_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR005_S4_L001_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR005_S4_L002_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR005_S4_L002_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR006_S3_L001_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR006_S3_L001_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR006_S3_L002_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR006_S3_L002_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR012_S1_L001_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR012_S1_L001_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR012_S1_L002_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR012_S1_L002_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR013_AD013_S2_L001_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR013_AD013_S2_L001_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR013_AD013_S2_L002_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR013_AD013_S2_L002_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR014_AD014_S5_L001_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR014_AD014_S5_L001_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR014_AD014_S5_L002_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR014_AD014_S5_L002_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR015_AD015_S6_L001_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR015_AD015_S6_L001_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR015_AD015_S6_L002_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR015_AD015_S6_L002_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR019_S7_L001_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR019_S7_L001_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR019_S7_L002_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR019_S7_L002_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR021_S8_L001_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR021_S8_L001_R2_001_val_2_val_2.fastq 
i1 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR021_S8_L002_R1_001_val_1_val_1.fastq 
i2 /gscratch/scrubbed/samwhite/20180129_trimmed_again/NR021_S8_L002_R2_001_val_2_val_2.fastq
[/code]



##### Results



Output folder: [20180312_SparseAssembler_novaseq_geoduck](https://owl.fish.washington.edu/Athaliana/20180312_SparseAssembler_novaseq_geoduck/)

IT WORKED!!! At last; we have an assembly of the geoduck NovaSeq data!! It took ~10days to complete.

The primary output file of interest is this FASTA file:





  * [Contigs.txt (11GB)(https://owl.fish.washington.edu/Athaliana/20180312_SparseAssembler_novaseq_geoduck/Contigs.txt)



In order to get a rough idea of how this assembly looks, I ran it through [Quast Version: 4.5, 15ca3b9](https://quast.sourceforge.net/quast.html):

`python software/quast-4.5/quast.py \
-t 16 
/mnt/owl/Athaliana/20180312_SparseAssembler_novaseq_geoduck/Contigs.txt`

Quast output folder: [results_2018_03_22_08_12_12](https://owl.fish.washington.edu/Athaliana/quast_results/results_2018_03_22_08_12_12/)

Here're the stats on the assembly:

Quast output (text): [results_2018_03_22_08_12_12/report.txt](https://owl.fish.washington.edu/Athaliana/quast_results/results_2018_03_22_08_12_12/report.txt)

Quast output (HTML):[results_2018_03_22_08_12_12/report.html](https://owl.fish.washington.edu/Athaliana/quast_results/results_2018_03_22_08_12_12/report.html)

<iframe src="https://owl.fish.washington.edu/Athaliana/quast_results/results_2018_03_22_08_12_12/report.html" width="100%" height="2000" scrolling="yes"></iframe>

Overall, the assembly doesn't look great. The N50 = 645 is really, really low. One would hope for a much large number for a quality assembly. As it stands, this assembly is comprised of many small contigs.

Looks like we'll have to fiddle with the kmer size used for SparseAssembler and see if we can improve upon this.

Despite that, it's an accomplishment to finally get any sort of assembler to run to completion for this data set!
