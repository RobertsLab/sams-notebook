---
layout: post
title: Bioanalyzer - M.magister MBD BSseq Libraries
date: '2020-11-25 06:48'
tags:
  - bioanalyzer
  - Metacarcinus magister
  - MBD
  - BSseq
categories:
  - Miscellaneous
---
[MBD BSseq library construction was completed yesterday (20201124)](https://robertslab.github.io/sams-notebook/2020/11/24/MBD-BSseq-Library-Prep-M.magister-MBD-selected-DNA-Using-Pico-Methyl-Seq-Kit.html). Next, I needed to evaluate the libraries using the Roberts Lab Bioanalyzer 2100 (Agilent) to assess library sizes, yields, and qualities (i.e. primer dimers).

ZymoResearch recommends using the TapeStation (Agilent), but if a lab doesn't have access to that, they indicated that either of the regular DNA assays will work (verbal communication). I ran the libraries on the High Sensitivity DNA Assay (Agilent), since that's what we had in the lab. It should work relatively OK.

All data (including Bioanalyzer electropherograms) will be added to the Google Sheet for this project:

- [OA Crab Sample Collection 071119](https://docs.google.com/spreadsheets/d/1ym0XnYVts98tIUCn0kIaU6VuvqxzV7LoSx9RHwLdiIs/edit#gid=1430155532)

Additional details are available in this GitHub repo:

- [project-dungeness-crab](https://github.com/RobertsLab/project-dungeness-crab)

---

#### RESULTS

Most samples ([including `CH09-13` which had no detectable DNA via Qubit(https://robertslab.github.io/sams-notebook/2020/11/03/MBD-Selection-M.magister-Sheared-Gill-gDNA-16-of-24-Samples-Set-3-of-3.html)]) exhibited the expected profiles. Admittedly, a number of samples were probably slightly too concentrated for the High Sensitivity DNA Assay (Agilent), leading to skewed baselines. However, the software does a good job of detecting, and accounting for, this.

One sample failed: `CH10-19`

Although I did not expect it to fail, [this sample did have a wonky elution at the end of SECTION 4 of the library prep.](https://robertslab.github.io/sams-notebook/2020/11/24/MBD-BSseq-Library-Prep-M.magister-MBD-selected-DNA-Using-Pico-Methyl-Seq-Kit.html).

Once a sequencing facility is decided upon, will make decisions about sample pooling and desired sequencing output.

Output folder:

- [20201125_mmag_bioanalyzer_mbd-bsseq-libraries/](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/)

  - Bioanalyzer data files (XAD; requires 2100 Expert software):

    - [2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07.xad](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07.xad)    

    - [2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38.xad](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38.xad)    

    - [2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_07-00-25.xad](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_07-00-25.xad)

  - Bioanalyzer report files (includes fragment lengths, concentration, and molarity; CSV):

    - [2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_Results.csv](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_Results.csv)

    - [2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_Results.csv](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_Results.csv)

    - [2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_07-00-25_Results.csv](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_07-00-25_Results.csv)


#### Electropherograms and gels (full chips)

##### DE72902486_2020-11-25_05-16-07

![Bioanalyzer electrophergrams for all samples in DE72902486_2020-11-25_05-16-07](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_EGRAM.png)

![Bioanalyzer gel for all samples in DE72902486_2020-11-25_05-16-07](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_GEL.png)


##### DE72902486_2020-11-25_06-12-38

![Bioanalyzer electrophergrams for all samples in DE72902486_2020-11-25_06-12-38](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_EGRAM.png)

![Bioanalyzer electrophergrams for all samples in DE72902486_2020-11-25_06-12-38](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_GEL.png)


##### DE72902486_2020-11-25_07-00-25

![Bioanalyzer electrophergrams for all samples in DE72902486_2020-11-25_07-00-25](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_07-00-25_EGRAM.png)


![Bioanalyzer gel for all samples in DE72902486_2020-11-25_07-00-25](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_07-00-25_GEL.png)

---

#### Electropherograms (individual samples)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH01-06](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_EGRAM_Sample1.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH01-14](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_EGRAM_Sample2.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH01-22](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_EGRAM_Sample3.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH01-38](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_EGRAM_Sample4.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH03-04](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_EGRAM_Sample5.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH03-15](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_EGRAM_Sample6.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH03-33](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_EGRAM_Sample7.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH05-01](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_EGRAM_Sample8.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH05-06](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_EGRAM_Sample9.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH05-21](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_EGRAM_Sample10.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH05-24](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_05-16-07_EGRAM_Sample11.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH05-26](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_EGRAM_Sample1.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH07-06](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_EGRAM_Sample10.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH07-11](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_EGRAM_Sample11.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH07-24](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_EGRAM_Sample2.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH09-02](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_EGRAM_Sample3.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH09-11](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_EGRAM_Sample4.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH09-13](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_EGRAM_Sample5.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH09-28](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_EGRAM_Sample6.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH09-29](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_EGRAM_Sample7.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH10-01](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_EGRAM_Sample8.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH10-08](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_06-12-38_EGRAM_Sample9.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH10-11](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_07-00-25_EGRAM_Sample1.png)

![Bioanalyzer 2100 electropherogram for MBD BSseq library CH10-19](https://gannet.fish.washington.edu/Atumefaciens/20201125_mmag_bioanalyzer_mbd-bsseq-libraries/2100-expert_High-Sensitivity-DNA-Assay_DE72902486_2020-11-25_07-00-25_EGRAM_Sample2.png)
