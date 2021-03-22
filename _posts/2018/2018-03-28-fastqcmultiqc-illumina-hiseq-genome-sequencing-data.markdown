---
author: kubu4
comments: true
date: 2018-03-28 21:32:44+00:00
layout: post
slug: fastqcmultiqc-illumina-hiseq-genome-sequencing-data
title: FastQC/MultiQC – Illumina HiSeq Genome Sequencing Data
wordpress_id: 3169
author:
  - kubu4
categories:
  - Geoduck Genome Sequencing
tags:
  - FASTQC
  - geoduck
  - Illumina
  - mox
  - multiqc
  - Panopea generosa
---

Since running [SparseAssembler seems to be working](https://robertslab.github.io/sams-notebook/2018/03/27/assembly-geoduck-novaseq-using-sparseassembler-kmer-101.html) and actually able to produce assemblies, I've decided I'll try to beef up the geoduck genome assembly with the rest of our existing genomic sequencing data.

[Yesterday, I transferred our BGI geoduck data to our Mox node and ran it through FASTQC](https://robertslab.github.io/sams-notebook/2018/03/27/fastqcmultiqc-bgi-geoduck-genome-sequencing-data.html)

I transferred our [Illumina HiSeq data sets (*NMP*.fastq.gz)(https://owl.fish.washington.edu/nightingales/P_generosa/) to our Mox node (/gscratch/scrubbed/samwhite/illumina_geoduck_hiseq). These were part of the Illumina-sponsored sequencing project.

I verified the MD5 checksums (not documented) and then ran FASTQC, followed by MultiQC.

FastQC slurm script: [20180328_fastqc_illumina_geoduck_hiseq_slurm.sh](https://owl.fish.washington.edu/Athaliana/20180328_illumina_hiseq_geoduck_fastqc/20180328_fastqc_illumina_geoduck_hiseq_slurm.sh)

This was followed with MultiQC (locally, after copying the the FastQC output to Owl).



##### Results:



FASTQC output: [20180328_illumina_hiseq_geoduck_fastqc](https://owl.fish.washington.edu/Athaliana/20180328_illumina_hiseq_geoduck_fastqc/)

MultiQC output: [20180328_illumina_hiseq_geoduck_fastqc/multiqc_data](https://owl.fish.washington.edu/Athaliana/20180328_illumina_hiseq_geoduck_fastqc/multiqc_data/)

MultiQC HTML report: [20180328_illumina_hiseq_geoduck_fastqc/multiqc_data/multiqc_report.html](https://owl.fish.washington.edu/Athaliana/20180328_illumina_hiseq_geoduck_fastqc/multiqc_data/multiqc_report.html)

Well, lots of fails. I high level of "Per Base N Content" (these are only warnings, but we also haven't received data with these warnings before). Also, they all fail in the "Overrepresented sequences" analysis.

I'll run these through [TrimGalore!](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/) (probably twice), and see how things change.

<iframe src="https://owl.fish.washington.edu/Athaliana/20180328_illumina_hiseq_geoduck_fastqc/multiqc_data/multiqc_report.html" width="100%" height="2000" scrolling="yes"></iframe>
