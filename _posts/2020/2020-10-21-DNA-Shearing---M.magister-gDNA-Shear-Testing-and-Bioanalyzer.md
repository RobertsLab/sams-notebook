---
layout: post
title: DNA Shearing - M.magister gDNA Shear Testing and Bioanalyzer
date: '2020-10-21 08:36'
tags:
  - Dungeness crab
  - bioanalyzer
  - Metacarcinus magister
  - Bioruptor
categories:
  - Miscellaneous
---
[Steven assigned me to do some MBD-BSseq library prep](https://github.com/RobertsLab/resources/issues/990) (GitHub Issue) for some Dungeness crab (_Metacarcinus magister_) DNA samples provided by Mackenzie Gavery. The DNA was isolated from juvenile (J6/J7 developmental stages) gill tissue. One of the first steps in MBD-BSseq is to fragment DNA to a desired size (~350 - 500bp in our case). However, we haven't worked with _Metacarcinus magister_ DNA previously, so I need to empirically determine sonicator (Bioruptor 300; Diagenode) settings for these samples.

I used 1ug of DNA in a volume of 50uL, using 0.65mL prelubricated snap cap tubes (Costar; Cat# 3206).

Initially, I did a 35 cycle (30s ON, 30s OFF; low intensity setting) run and determined it was insufficient, so ran increments of 5 cycles and pulled out 1.5uL after each one to run on the Bioanalyzer.

Post-sonication/shearing, samples were run on High Sensitivity DNA Assay chips in the Bioanalyzer 2100 (Agilent).


---

#### RESULTS

Output folder/files:

- [20201021_mmag_bioanalyzer/](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/)

  - Bioanalyzer files (XAD; require 2100 Expert software to open)

	  - [2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-21_07-26-05.xad](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-21_07-26-05.xad)

    - [2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-21_08-23-22.xad](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-21_08-23-22.xad)

    - [2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-21_09-50-46.xad](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-21_09-50-46.xad)

##### Quick summary: Potentially need to cycle for 70 cycles (!!!!) to achieve desired average fragment length.

Will test an uninterrupted run tomorrow to confirm that these settings are accurate.


Below are all of the electropherograms from each of the total cycles the CHO5-21 gDNA was subjected to: 35 - 80 cycles, increments of 5 cycles. Directly underneath each electropherogram (it's small - you'll need to open the image in a new tab to see better) is data showing the mean fragment size within the regions of 50 - 8000bp for each sample.

There are also two "pseudo-colored" (this is the software verbiage for heatmap-like coloration) gel representation comparisons of samples. It's an easy way to see the progression of fragmentation as the cycle number increases.

Also, I ended up running three chips (gah!) to accommodate all of this (was not expecting to need to fragment for this number of cycles) and that is why there is not a singular gel representation image allowing for the comparison of all the samples together.


##### Electropherogram: 35 cycles

![Bioanalyzer electropherogram for _M.magister_ gDNA sheared for 35 cycles](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/20201021_mmag_bioanalyzer_electropherogram_CHO5-21_shear-35-cycles.jpg)


##### Electropherogram: 40 cycles

![Bioanalyzer electropherogram for _M.magister_ gDNA sheared for 40 cycles](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/20201021_mmag_bioanalyzer_electropherogram_CHO5-21_shear-40-cycles.JPG)


##### Electropherogram: 45 cycles

![Bioanalyzer electropherogram for _M.magister_ gDNA sheared for 45 cycles](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/20201021_mmag_bioanalyzer_electropherogram_CHO5-21_shear-45-cycles.JPG)

##### Electropherogram: 50 cycles

![Bioanalyzer electropherogram for _M.magister_ gDNA sheared for 50 cycles](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/20201021_mmag_bioanalyzer_electropherogram_CHO5-21_shear-50-cycles.JPG)


##### Gel comparison: 40, 45, and 50 cycles

![Bioanalyzer gel representation and comparison for _M.magister_ gDNA sheared for 40, 45, and 50 cycles](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/20201021_mmag_bioanalyzer_gel_CHO5-21_shear-40-45-50-cycles.jpg)


##### Electropherogram: 55 cycles

![Bioanalyzer electropherogram for _M.magister_ gDNA sheared for 55 cycles](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/20201021_mmag_bioanalyzer_electropherogram_CHO5-21_shear-55-cycles.JPG)


##### Electropherogram: 60 cycles

![Bioanalyzer electropherogram for _M.magister_ gDNA sheared for 60 cycles](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/20201021_mmag_bioanalyzer_electropherogram_CHO5-21_shear-60-cycles.JPG)

##### Electropherogram: 65 cycles

![Bioanalyzer electropherogram for _M.magister_ gDNA sheared for 65 cycles](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/20201021_mmag_bioanalyzer_electropherogram_CHO5-21_shear-65-cycles.JPG)


##### Electropherogram: 70 cycles

![Bioanalyzer electropherogram for _M.magister_ gDNA sheared for 70 cycles](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/20201021_mmag_bioanalyzer_electropherogram_CHO5-21_shear-70-cycles.JPG)


##### Electropherogram: 75 cycles

![Bioanalyzer electropherogram for _M.magister_ gDNA sheared for 75 cycles](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/20201021_mmag_bioanalyzer_electropherogram_CHO5-21_shear-75-cycles.JPG)


##### Electropherogram: 80 cycles

![Bioanalyzer electropherogram for _M.magister_ gDNA sheared for 80 cycles](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/20201021_mmag_bioanalyzer_electropherogram_CHO5-21_shear-80-cycles.JPG)

##### Gel comparison: 55, 60, 65, 70, 75, and 80 cycles

![Bioanalyzer gel representation and comparison for _M.magister_ gDNA sheared for 40, 45, and 50 cycles](https://gannet.fish.washington.edu/Atumefaciens/20201021_mmag_bioanalyzer/20201021_mmag_bioanalyzer_gel_CHO5-21_shear-55-60-65-70-75-80-cycles.JPG)
