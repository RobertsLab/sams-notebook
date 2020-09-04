---
layout: post
title: NanoPore Sequencing - C.bairdi gDNA Sample 20102558-2729
date: '2020-01-09 14:52'
tags:
  - tanner crab
  - nanopore
  - gDNA
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
I performed the [initial Lambda sequencing test on 20200107](https://robertslab.github.io/sams-notebook/2020/01/07/NanoPore-Sequencing-Initial-NanoPore-MinION-Lambda-Sequencing-Test.html) and everything went smoothly, so I'm ready to give the NanoPore (ONT) MinION a run with an actual sample!

I [isolated gDNA from an uninfected _C.bairdi_ muscle sample yesterday (sample 20102558-2729)](https://robertslab.github.io/sams-notebook/2020/01/08/DNA-Isolation-and-Quantification-C.bairdi-gDNA-from-EtOH-Preserved-Tissue.html). Earlier today I [ran that DNA on a gel to assess it's quality/integrity](https://robertslab.github.io/sams-notebook/2020/01/09/DNA-Quality-Assessment-Agarose-Gel-and-NanoDrop-on-C.bairdi-gDNA.html) and it didn't look very good - pretty degraded.

Despite that fact, I'll run this on the NanoPore MinION. This will provide me with additional experience on using the system and will also provide us with info about using degraded DNA. Presumably, sequencing will proceed without issue and we'll just end up with shorter read lengths than if we had higher quality input DNA.

The sample DNA was prepared according to [the protocol for the Rapid Sequencing Kit (SQK-RAD004)](https://github.com/RobertsLab/resources/blob/master/protocols/Commercial_Protocols/Nanopore_rapid-sequencing-sqk-rad004-RSE_9046_v1_revM_14Aug2019-minion.pdf) and run on a FLO-MIN106 (ID: FAL58500) flowcell. Data acquisition was set to run _without_ basecalling for a period of 72hrs. This will make sure the raw Fast5 output files will be preserved (not sure if they're saved or not when basecalling is enabled), but will require conversion to FastQ at a later date.

Start of the run was good, with 1226 pores available for sequencing (minimum for a "good" flowcell, per ONT, is 800 pores). The number of available pores dropped below 800 after ~3hrs, which doesn't seem good. Based on the various metrics for monitoring a sequencing run, I decided to terminate this run after ~17hrs. Available pores had dropped to 270 and data acquisition was minimal. With that being said, I should be able to wash the flowcell to restore everything back to normal (i.e. clean out clogged pores) and use it again.

I washed the flowcell according [the protocol for the Flowcell Wash Kit (WFC_9088)](https://github.com/RobertsLab/resources/blob/master/protocols/Commercial_Protocols/Nanopore_flow-cell-wash-kit-protocol-WFC_9088_v1_revF_18Sep2019-any.pdf) and decided to do a second run with this same gDNA sample to see how well washing/reusing actually seems to work.

Prepared a fresh library as before and ran as before on the FLO-MIN106 (ID: FAL58500) flowcell. This time, I decided to just go with a "set it and forget it" approach. I set the run time to 72hrs and let the program finish. The washing/reusing of the flowcell didn't really work as expected, though. Starting number of available pores was only 414, far short of the minimum of 800 indicative of a good flowcell. I'll contact ONT about this and see what they can do.


---

#### RESULTS

Output folder:

- [20200109_cbai_nanopore_20102558-2729/](https://gannet.fish.washington.edu/Atumefaciens/20200109_cbai_nanopore_20102558-2729/)

First run report (PDF):

- [20200109_cbai_nanopore_20102558-2729/20102558-2729/3d288d14-89d6-4ae4-8a76-18ec6ff63fc7--report.pdf](https://gannet.fish.washington.edu/Atumefaciens/20200109_cbai_nanopore_20102558-2729/20102558-2729/3d288d14-89d6-4ae4-8a76-18ec6ff63fc7--report.pdf)

Second run report (PDF):

- [20200109_cbai_nanopore_20102558-2729/cbaI_20102558-2729/a909f60a-d49f-4564-8cd3-3c8a31e8c572--report.pdf](https://gannet.fish.washington.edu/Atumefaciens/20200109_cbai_nanopore_20102558-2729/cbaI_20102558-2729/a909f60a-d49f-4564-8cd3-3c8a31e8c572--report.pdf)
