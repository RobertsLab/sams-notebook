---
layout: post
title: DNA Shearing - M.magister CH05-21 gDNA Full Shearing Test and Bioanalyzer
date: '2020-10-22 10:31'
tags:
  - Dungeness crab
  - bioanalyzer
  - shearing
  - Matacarcinus magister
categories:
  - Miscellaneous
---
Yesterday, I did some [shearing of _Metacarcinus magister_ gill gDNA](https://robertslab.github.io/sams-notebook/2020/10/21/DNA-Shearing-M.magister-gDNA-Shear-Testing-and-Bioanalyzer.html) on a test sample (CH05-21) to determine how many cycles to run on the sonicator (Bioruptor 300; Diagenode) to achieve an average fragment length of ~350 - 500bp in preparation for MBD-BSseq. The determination from yesterday was 70 cycles (30s ON, 30s OFF; low intensity). That determination was made by first sonicating for 35 cycles, followed by successive rounds of 5 cycles each. I decided to repeat this, except by doing it in a single round of sonication.

I used 1ug of DNA in a volume of 50uL, using 0.65mL prelubricated snap cap tubes (Costar; Cat# 3206).

It turns out the Bioruptor has a maximum cycle setting of 60 cycles, so I decided to do 35 cycles, immediately followed by another 35 cycles.

Post-sonication/shearing, samples were run on High Sensitivity DNA Assay chips in the Bioanalyzer 2100 (Agilent).

---

#### RESULTS

Output folder:

- [20201021_mmag_bioanalyzer/](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/)

    - Bioanalyzer files (XAD; require 2100 Expert software to open):

			- [2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-22_07-27-24.xad](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-22_07-27-24.xad)

			- [2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-22_08-47-27.xad](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-22_08-47-27.xad)

Electropherograms are beneath the discussion that follows.

As it turns out, the initial 35 cycles + 35 cycles (total of 70) that didn't produce the results I was expecting (see RESULTS below for more info). The electropherogram had a similar profile to the sample after 35 cycles that I did yesterday. So, I performed runs of 5 cycles each, for a total of 35 additional cycles. My thinking: Electropherogram looked similar to only 35 cycles, so an additional cumulative 35 cycles would repeat what I did yesterday (despite the fact that the sample had already been through two consecutive runs of 35 cycles each).

Admittedly, this is annoying, surprising, and concerning.

 - Annoying: Suggests that I'll have to do this when sonicating the remaining samples - it's tedious to monitor and eliminates the "set it and forget it" approach.

 - Surprising: Wouldn't expect differences in outcome between 35 cycles in one shot vs. 35 cycles comprised of seven rounds of 5 cycles.

 - Concerning: Makes me wonder if I actually initiated the second round of 35 cycles in the first place... I'm confident that I did, but these results suggest otherwise.

Lo and behold, the subsequent incremental runs of 5 cycles each, ended up yielding the expected fragmentation length profile!

Strange. I guess I'll just take this approach when I sonicate the remainder of the samples.

##### Initial 35 + 35 cycles:

![Bioanalyzer electropherogram of CH05-21 after two successive 35 cycle shearing](https://gannet.fish.washington.edu/Atumefaciens/20201022_mmag_bioanalyzer/20201022_mmag_bioanalyzer_electropoherogram_CHO5-21_sheared-70-cyles.JPG)

##### Subsequent 35 cycles, by 5 cycle increments (total of 105 cycles):

![Bioanalyzer electropherogram of CH05-21 after seven successive rounds of 5 cycles each (total of 105 cycles)](https://gannet.fish.washington.edu/Atumefaciens/20201022_mmag_bioanalyzer/20201022_mmag_bioanalyzer_electropoherogram_CHO5-21_sheared-70+35-by-5s-cyles.JPG)
