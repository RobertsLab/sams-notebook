---
author: kubu4
comments: true
date: 2018-04-01 16:21:11+00:00
layout: post
slug: trimgalorefastqcmultiqc-illumina-hiseq-genome-sequencing-data-continued
title: TrimGalore!/FastQC/MultiQC - Illumina HiSeq Genome Sequencing Data Continued
wordpress_id: 3179
author:
  - kubu4
categories:
  - Geoduck Genome Sequencing
tags:
  - FASTQC
  - geoduck
  - mox
  - multiqc
  - Panopea generosa
  - TrimGalore!
---

The [previous attempt at this](https://robertslab.github.io/sams-notebook/2018/03/28/trimgalorefastqcmultiqc-illumina-hiseq-genome-sequencing-data.html) was interrupted by a random glitch with our [Mox HPC node](https://github.com/RobertsLab/hyak_mox/wiki).

I removed the last files processed by [TrimGalore!](https://github.com/FelixKrueger/TrimGalore), just in case they were incomplete. I updated the slurm script to process only the remaining files that had _not_ been processed when the Mox glitch happened (including the files I deemed "incomplete").

As in the initial run, I kept the option in TrimGalore! to automatically run FastQC on the trimmed output files.

TrimGalore! slurm script: [20180401_trim_galore_illumina_geoduck_hiseq_slurm.sh](https://owl.fish.washington.edu/Athaliana/20180328_trim_galore_illumina_hiseq_geoduck/20180401_trim_galore_illumina_geoduck_hiseq_slurm.sh)

MultiQC was run locally once the files were copied to Owl.



#### Results:



Job completed on 20180404.

Trimmed FASTQs: [20180328_trim_galore_illumina_hiseq_geoduck/](https://owl.fish.washington.edu/Athaliana/20180328_trim_galore_illumina_hiseq_geoduck/)

MD5 checksums: [20180328_trim_galore_illumina_hiseq_geoduck/checksums.md5](https://owl.fish.washington.edu/Athaliana/20180328_trim_galore_illumina_hiseq_geoduck/checksums.md5)





  * MD5 checksums were generated on Mox node and verified after copying to Owl.



Slurm output file: [20180401_trim_galore_illumina_geoduck_hiseq_slurm.sh](https://owl.fish.washington.edu/Athaliana/20180328_trim_galore_illumina_hiseq_geoduck/20180401_trim_galore_illumina_geoduck_hiseq_slurm.sh)

TrimGalore! output: [20180328_trim_galore_illumina_hiseq_geoduck/20180404_trimgalore_reports/](https://owl.fish.washington.edu/Athaliana/20180328_trim_galore_illumina_hiseq_geoduck/20180404_trimgalore_reports/)

FastQC output: [20180328_trim_galore_illumina_hiseq_geoduck/20180328_fastqc_trimmed_hiseq_geoduck/](https://owl.fish.washington.edu/Athaliana/20180328_trim_galore_illumina_hiseq_geoduck/20180328_fastqc_trimmed_hiseq_geoduck/)

MultiQC output: [20180328_trim_galore_illumina_hiseq_geoduck/20180328_fastqc_trimmed_hiseq_geoduck/multiqc_data/](https://owl.fish.washington.edu/Athaliana/20180328_trim_galore_illumina_hiseq_geoduck/20180328_fastqc_trimmed_hiseq_geoduck/multiqc_data/)

MultiQC HTML report: [20180328_trim_galore_illumina_hiseq_geoduck/20180328_fastqc_trimmed_hiseq_geoduck/multiqc_data/multiqc_report.html](https://owl.fish.washington.edu/Athaliana/20180328_trim_galore_illumina_hiseq_geoduck/20180328_fastqc_trimmed_hiseq_geoduck/multiqc_data/multiqc_report.html)

<iframe src="https://owl.fish.washington.edu/Athaliana/20180328_trim_galore_illumina_hiseq_geoduck/20180328_fastqc_trimmed_hiseq_geoduck/multiqc_data/multiqc_report.html" width="100%" height="2000" scrolling="yes"></iframe>

Trimming completed and the FastQC results look much better than before.

Will proceed with full-blown assembly!
