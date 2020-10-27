---
layout: post
title: DNA Shearing - M.magister gDNA Shearing All Samples and Bioanalyzer
date: '2020-10-26 10:57'
tags:
  - Metacarcinus magister
  - Dungeness crab
  - bioanalyzer
  - gDNA
  - shearing
  - sonicator
  - bioruptor
categories:
  - Miscellaneous
---
[I previously ran some shearing tests on 20201022](https://robertslab.github.io/sams-notebook/2020/10/22/DNA-Shearing-M.magister-CH05-21-gDNA-Full-Shearing-Test-and-Bioanalyzer.html) to determine how many cycles to run on the sonicator (Bioruptor 300; Diagenode) to achieve an average fragment length of ~350 - 500bp in preparation for MBD-BSseq. The determination was 70 cycles (30s ON, 30s OFF; low intensity), sonicating for 35 cycles, followed by successive rounds of 5 cycles each.

I used 1ug of DNA in a volume of 51uL (this volume was selected to simplify downstream calculations, after using 1uL for the Bioanalyzer after shearing), using 0.65mL prelubricated snap cap tubes (Costar; Cat# 3206).

Post-sonication/shearing, samples were run on High Sensitivity DNA Assay chips in the Bioanalyzer 2100 (Agilent).

All samples and volumes used are listed in the following Google Sheet (originally provided by Mackenzie Gavery):

- [OA Crab Sample Collection 071119](https://docs.google.com/spreadsheets/d/1ym0XnYVts98tIUCn0kIaU6VuvqxzV7LoSx9RHwLdiIs/edit#gid=1430155532)


---

#### RESULTS

Output folder:

- [20201026_mmag_bioanalyzer_all-samples](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples)

	- [2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-26_07-43-19.xad](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-26_07-43-19.xad)

	- [2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-26_10-22-41.xad](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-26_10-22-41.xad)

	- [2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-26_11-09-26.xad](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/2100 expert_High Sensitivity DNA Assay_DE72902486_2020-10-26_11-09-26.xad)

Images of all electropherograms (shown in a single image), as well as individual sample electropherograms, are beneath the discussion that follows.

Overall, most samples look pretty good and fall within a range of ~250 - 550bp, which is acceptable for library prep. Admittedly, some of those on the lower end will likely end up having overlapping reads (assuming we sequence >100bp paired ends), but the software we use should easily handle these overlaps.

There are three samples that need additional sonication:

- CH05-01

- CH05-21

- CH07-11

I will perform additional round of sonication these tomorrow.



###### all-01

![Sheared all-01 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_all-01.JPG)


###### all-02

![Sheared all-02 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_all-02.JPG)


###### all-03

![Sheared all-03 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_all-03.JPG)



###### CH01-06

![Sheared CH01-06 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH01-06.JPG)


###### CH01-14

![Sheared CH01-14 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH01-14.JPG)


###### CH01-22

![Sheared CH01-22 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH01-22.JPG)


###### CH01-38

![Sheared CH01-38 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH01-38.JPG)


###### CH03-04

![Sheared CH03-04 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH03-04.JPG)


###### CH03-15

![Sheared CH03-15 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH03-15.JPG)


###### CH03-33

![Sheared CH03-33 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH03-33.JPG)


###### CH05-01

![Sheared CH05-01 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH05-01.JPG)


###### CH05-06

![Sheared CH05-06 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH05-06.JPG)


###### CH05-21

![Sheared CH05-21 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH05-21.JPG)


###### CH05-24

![Sheared CH05-24 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH05-24.JPG)


###### CH05-26

![Sheared CH05-26 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH05-26.JPG)


###### CH07-06

![Sheared CH07-06 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH07-06.JPG)


###### CH07-11

![Sheared CH07-11 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH07-11.JPG)


###### CH07-24

![Sheared CH07-24 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH07-24.JPG)


###### CH09-02

![Sheared CH09-02 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH09-02.JPG)


###### CH09-11

![Sheared CH09-11 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH09-11.JPG)


###### CH09-13

![Sheared CH09-13 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH09-13.JPG)


###### CH09-28

![Sheared CH09-28 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH09-28.JPG)


###### CH09-29

![Sheared CH09-29 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH09-29.JPG)


###### CH10-01

![Sheared CH10-01 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH10-01.JPG)


###### CH10-08

![Sheared CH10-08 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH10-08.JPG)


###### CH10-11

![Sheared CH10-11 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH10-11.JPG)


###### CH10-19

![Sheared CH10-19 Bioanalyzer electropherogram](https://gannet.fish.washington.edu/Atumefaciens/20201026_mmag_bioanalyzer_all-samples/20201026_mmag_bioanalyzer-electropherogram_CH10-19.JPG)
