---
layout: post
title: NanoPore Sequencing - Initial NanoPore MinION Lambda Sequencing Test
date: '2020-01-07 12:45'
tags:
  - nanopore
  - minION
  - sequencing
categories:
  - Miscellaneous
---
We recently acquired a NanoPore MinION sequencer, FLO-MIN106 flow cell and the Rapid Sequencing Kit (SQK-RAD004). The [NanoPore website](https://community.nanoporetech.com/guides/minion/rapid/introduction) provides a pretty thorough an user-friendly walk-through of how to begin using the system for the first time. With that said, I believe the user needs to have a registered account with NanoPore _and_ needs to have purchased some products to have full access to the protocols they provide.

For first time users, they provide a "Lambda Control experiment" which:

- teaches you how to use the sequencer, flow cells, and sequencing Kit

- sequences a known, small genome to allow fast sequencing and analysis

- free access to their `EPI2ME` analysis platform (which will perform basecalling, quality analysis, alignment, and generate a visually pleasing sequencing summary/report)

Honestly, it's a really helpful and easy way to get introduced to using the entire system. It's also not a bad way to sell the `EPI2ME` service, as it's very hands-off and easy to run.

Anyway, I set up the Lambda Control experiment sequencing run and ran it for the recommended duration (6hrs) with basecalling enabled (this will help speed up the subsequent `EPI2ME` service after sequencing is complete).

---

#### RESULTS

Output folder:

- [20200107_nanopore-minION_lambda_test/20200107_2035_MN29908_FAL48614_885ed0db/](https://gannet.fish.washington.edu/Atumefaciens/20200107_nanopore-minION_lambda_test/20200107_2035_MN29908_FAL48614_885ed0db/)

Fast5 format reads:

 - [20200107_nanopore-minION_lambda_test/20200107_2035_MN29908_FAL48614_885ed0db/fast5_pass/](https://gannet.fish.washington.edu/Atumefaciens/20200107_nanopore-minION_lambda_test/20200107_2035_MN29908_FAL48614_885ed0db/fast5_pass/)

 FastQ format reads:

 - [20200107_nanopore-minION_lambda_test/20200107_2035_MN29908_FAL48614_885ed0db/fastq_pass/](https://gannet.fish.washington.edu/Atumefaciens/20200107_nanopore-minION_lambda_test/20200107_2035_MN29908_FAL48614_885ed0db/fastq_pass/)

 EPI2ME Report \#1 (Flow cell performance; PDF):

 - [20200107_nanopore-minION_lambda_test/20200107_2035_MN29908_FAL48614_885ed0db/EPI2ME_Report_224980.pdf](https://gannet.fish.washington.edu/Atumefaciens/20200107_nanopore-minION_lambda_test/20200107_2035_MN29908_FAL48614_885ed0db/EPI2ME_Report_224980.pdf)

 EPI2ME Report \#2 (Alignment stats; PDF):

 - [20200107_nanopore-minION_lambda_test/20200107_2035_MN29908_FAL48614_885ed0db/EPI2ME_Report_224980-02.pdf](https://gannet.fish.washington.edu/Atumefaciens/20200107_nanopore-minION_lambda_test/20200107_2035_MN29908_FAL48614_885ed0db/EPI2ME_Report_224980-02.pdf)

 
