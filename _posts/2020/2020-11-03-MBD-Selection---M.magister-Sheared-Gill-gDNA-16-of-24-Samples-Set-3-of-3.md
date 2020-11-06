---
layout: post
title: MBD Selection - M.magister Sheared Gill gDNA 16 of 24 Samples Set 3 of 3
date: '2020-11-03 09:25'
tags:
  - Metacarcinus magister
  - Dungeness crab
  - MBD
  - MethylMiner
  - gDNA
categories:
  - Miscellaneous
---
[Click here for notebook on the first eight samples processed.](https://robertslab.github.io/sams-notebook/2020/10/28/MBD-Selection-M.magister-Sheared-Gill-gDNA-8-of-24-Samples-Set-1-of-3.html) [Click here for the second set of eight samples processed.](https://robertslab.github.io/sams-notebook/2020/11/02/MBD-Selection-M.magister-Sheared-Gill-gDNA-8-of-24-Samples-Set-2-of-3.html)  _M.magister_ (Dungeness crab) gill gDNA provided by Mackenzie Gavery was previously sheared on [20201026](https://robertslab.github.io/sams-notebook/2020/10/26/DNA-Shearing-M.magister-gDNA-Shearing-All-Samples-and-Bioanalyzer.html) and three samples were subjected to additional rounds of shearing on [20201027](https://robertslab.github.io/sams-notebook/2020/10/27/DNA-Shearing-M.magister-gDNA-Additional-Shearing-CH05-01_21-CH07-11-and-Bioanalyzer.html), in preparation for methyl bidning domain (MBD) selection using the MethylMiner Kit (Invitrogen).

Followed the manufacturer's protocol for using \<= 1ug of DNA (I'm using 1ug) with the following notes/changes:

- Prepared beads for all 8 samples in single prep. Combined the amount of beads/protein needed for 8, 1ug reactions. Protein calculations and wash volumes were based off of 8ug of input DNA. Prepared beads were resuspended in 80uL (instead of 100uL) and 10uL were distributed to each of 8 tubes. Volume was then brought up to 100uL with 1x binding/wash buffer.

- DNA capture incubation was performed overnight (~20hrs).

- Non-captured DNA and wash volumes were combined in a single tube for each sample. These were stored at 4<sup>oC</sup>, but were _not_ precipitated.

- Ethanol precipitations were incubated at -80<sup>oC</sup> overnight (~20hrs).

- Precipitated DNA was resuspended in 21uL of H<sub>2</sub>O (this allows the usage of 1uL for Qubit and leave 20uL as the maximum input volume for the subsequent PicoMethylSeq Kit (ZymoResearch)).

Samples were quantified using the Roberts Lab Qubit 3.0 with the Qubit 1x dsDNA HS Assay (Invitrogen), using 1uL of sample.

All samples were stored temporarily at 4<sup>o</sup>C.

For reference, all sample info for this project is here (Google Sheet):

- [OA Crab Sample Collection 071119](https://docs.google.com/spreadsheets/d/1ym0XnYVts98tIUCn0kIaU6VuvqxzV7LoSx9RHwLdiIs/edit#gid=1430155532)


---

#### RESULTS


Qubit results (Google Sheet):

- [20201105_qubit_DNA_mmag_MBD](https://docs.google.com/spreadsheets/d/1WKUE_mKIHShlwEoM28MAqtvJVRLA1pLtejs_O00lW9g/edit?usp=sharing)


| Sample ID | Resuspension_vol(uL) | Total_recovery(ng) | Percent_recovery(%) |
|-----------|----------------------|--------------------|---------------------|
| CH09-11   | 21                   | 3.07               | 0.31                |
| CH09-13   | 21                   | 0.00               | 0.00                |
| CH09-28   | 21                   | 4.62               | 0.46                |
| CH09-29   | 21                   | 11.09              | 1.11                |
| CH10-01   | 21                   | 7.27               | 0.73                |
| CH10-08   | 21                   | 38.64              | 3.86                |
| CH10-11   | 21                   | 6.43               | 0.64                |
| CH10-19   | 21                   | 3.57               | 0.36                |

Most of the samples had similar recoveries to the [first set](https://robertslab.github.io/sams-notebook/2020/10/28/MBD-Selection-M.magister-Sheared-Gill-gDNA-8-of-24-Samples-Set-1-of-3.html) and [second set](https://robertslab.github.io/sams-notebook/2020/11/02/MBD-Selection-M.magister-Sheared-Gill-gDNA-8-of-24-Samples-Set-2-of-3.html) of samples.

However, notable there are a few notable exceptions:

- `CH09-13`: No DNA recovered. I asked Mac about how to proceed and [she has indicated to proceed to lbirary construction _without_ this sample.](https://github.com/RobertsLab/resources/issues/990#issuecomment-722627158)

- `CH09-29` and `CH10-08`: Significantly more recovery than all other samples. It's difficult to say why this happened. The [Bioanlyzer electropherograms](https://robertslab.github.io/sams-notebook/2020/10/26/DNA-Shearing-M.magister-gDNA-Shearing-All-Samples-and-Bioanalyzer.html) for these samples don't stand out as markedly different than the others.
