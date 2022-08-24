---
layout: post
title: Daily Bits - August 2022
date: '2022-08-03 07:39'
tags: 
  - daily bits
  - August
categories: 
  - Daily Bits
---

20220823

- All day troubleshooting Linda Rhodes QIIME2 stuff. Discovered sequences are already trimmed(?), but would like to look at the `adapters.fa` file which is referenced in her notebooks (she didn't have this available at the beginning of this project, so I'm not sure what's in that file).

- [Reviewed Marta's SBATCH file for Stacks](https://github.com/RobertsLab/resources/issues/1516) and helped with a multitude of issues/errors.

---

20220822

- Worked heavily on Linda Rhodes QIIME2 stuff. Getting odd results of most data having unassigned taxonomies; the rest assigned to eukaryotes...

- Located pre-formatted SILVA 138 files (finally!) ([here](https://docs.qiime2.org/2020.11/data-resources/) - need to click on the red box to actually get to the links!), but got same results with taxonomic assignments...

- Lab meeting discussed Intro/Ch.1 of "The Disordered Cosmos"

- [Reviewed Matt's SBATCH script for Trinity assembly...](https://github.com/RobertsLab/resources/issues/1508)

---

20220819

- Took the day off.

---

20220818

- Created _S.namaycush_ genes-only BED file for use in Ballgown analysis.

- Started work on _S.namaycush_ Ballgown analysis.

- Continued recreating SILVA databases (bayes classification step takes a LONG time - and there are two steps)


---

20220817

- Recreated SILVA database(s) using more specific workflow. Hope to solve issue of no taxonomic assignments experienced yesterday. https://forum.qiime2.org/t/processing-filtering-and-evaluating-the-silva-database-and-other-reference-sequence-data-with-rescript/15494

- Established lake trout repo for Ballgown analysis: https://github.com/RobertsLab/project-lake-trout

---

20220816

- Renewed formaldehyde training

- Renewed fire extinguisher training

- Worked through Linda Rhodes Jupyter Notebooks 2,3, & 4. Hit roadblock in 4 - need external file.

- Worked through Linda Rhodes Jupyter Notebook 8. End results of pipeline had no taxonomic assignments. Need to review process to determine what went wrong.

---

20220815

- Lab meeting:

  - Decided on next book for book club: The Disordered Cosmos

  - Discussed Pub-a-thon

  - Had Dorothy show her mussel heat stress poster

- Internet outage at ~ 11AM ... back on about 12PM

- Internet outage again at 13:15...14:15 it's back on!

- Worked on getting through Linda's Jupyter Notebooks 2 & 3.

---

20220812

- Intalled newest version of Stacks on Mox ([Stacks version - issue by Marta](https://github.com/RobertsLab/resources/issues/1507))

  1. `wget https://catchenlab.life.illinois.edu/stacks/source/stacks-2.62.tar.gz`
  2. `tar -xzvf stacks-2.62.tar.gz`
  3. `cd stacks-2.62`
  4. `module load gcc/10.1.0`: Had to load newer version of `gcc` because default version triggered an error when running `make`.
  5. `make`

- Science Hour:

  - Helped Grace get Trinity running on Mox as part of this issue: [RNAseq workflow](https://github.com/RobertsLab/resources/issues/1476)

- Helped Marta get Globus Connect Personal running for transferring data to/from Mox: [Globus Connect Personal](https://github.com/RobertsLab/resources/issues/1510)


20220811

- Worked a bit on Linda Rhodes 16s stuff.

- Did a _lot_ of troubleshooting for lab people. See the following GitHub Issues:

  - [RNAseq workflow - issue by Grace](https://github.com/RobertsLab/resources/issues/1476)

  - [Trinity error on Raven: no module name numpy - issue by Matt](https://github.com/RobertsLab/resources/issues/1506)

  - [Stacks version - issue by Marta](https://github.com/RobertsLab/resources/issues/1507)

  - [Install transrate on Raven - issue by Matt](https://github.com/RobertsLab/resources/issues/1503)

---

20220810

- Completed [installation of `transrate` on Raven](https://github.com/RobertsLab/resources/issues/1503). Due to the fact that the hosting provider for [TransRate](http://hibberdlab.com/transrate/) binaries no longer exists, one cannot download the binaries needed to run it. So, instead, the process required the following:

  - [Installation of RVM - a Ruby version manager](https://rvm.io/). I followed the [Ubuntu install instructions](https://github.com/rvm/ubuntu_rvm), which allows for a multi-user installation by default.

  - Added users the `rvm` group: `sudo usermod -a -G rvm <username>`

  - Activating a Ruby version: `rvm use ruby-3.0.0`

  - Install TransRate: `gem install transrate`

  - Install TransRate dependencies: `transrate --install-deps all`

  - Remove problematic library preventing `salmon` from working (solution courtesy of [this GitHub repo Issue from unrelated software](https://github.com/nghiavtr/FuSeq/issues/8)): `rm /usr/share/rvm/gems/ruby-3.0.0/bin/librt.so.1`

- Put script together for S.namaycush [`HISAT2`](https://daehwankimlab.github.io/hisat2/) alignments and splice site identification.

- Internet died at 10:30... and came back ~13:30.

---

20220809

- In lab today to address lab inspection deficiencies:

  - Waste collection request for most old chemicals (this was a _lot_ of chemicals).

  - Printed new lab hazards sign and mounted outside of FTR 213.

  - Labeled acids and bases cabinets in FTR 213.

  - Ordered additional gas cylinder bracket for CO<sub>2</sub> cylinder in FTR 213.

  - Took liquid nitrogen training (now required training).

- Helped Dorothy get qPCR barplot exported from R to SVG to use in her poster.

---

20220808

- Read Fresh Banana Leaves Ch. 8 for lab meeting.

- Lab meeting.

- Oyster gene expression meeting. Played with methylation percentages and grouping by data in R with Steven (he did most of the playing around in R).

---

20220805

- Messed around with Dorothy's data with Steven (he did most of the messing around) during Science Hour.

- Chatted with Zack regarding aligning data for identification of lncRNAs. Showed him the basic HiSat2 indexing/aligning options.

- Chatted with Zack regarding mussel primers from that FISH541 class. Told him to re-run class samples with primers - most failures during class likely due to inexperience with bench work.

---

20220804

- In lab today.

- Re-ran ferritin qPCR with fresh primer stocks using Dorothy's mussel cDNA.

- Annual UW lab safety inspection.

- Introduced Dorothy to R and R Studio on Raven.

---

20220803

- Created notebook post for [mussel RNA isolation and reverse transcription from 20220726]()

- Created notebook post for [mussel qPCRs from 20220727]()

- Briefly review some of the qPCR data mentioned above.

- [Resolved Sensaphone GitHub Issue](https://github.com/RobertsLab/resources/issues/1492)

- [Added generic reverse transcription protocol to lab handbook](https://github.com/RobertsLab/resources/issues/1494)

- Reviewed lab safety documentation and personnel in preparation for lab safety inspection tomorrow.

