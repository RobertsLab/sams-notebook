---
layout: post
title: MBD Selection - M.magister Sheared Gill gDNA 8 of 24 Samples Set 1 of 3
date: '2020-10-28 11:01'
tags:
  - Metacarcinus magister
  - Dungeness crab
  - MBD
  - MethylMiner
categories:
  - Miscellaneous
---
_M.magister_ (Dungeness crab) gill gDNA provided by Mackenzie Gavery was previously sheared on [20201026](https://robertslab.github.io/sams-notebook/2020/10/26/DNA-Shearing-M.magister-gDNA-Shearing-All-Samples-and-Bioanalyzer.html) and three samples were subjected to additional rounds of shearing on [20201027](https://robertslab.github.io/sams-notebook/2020/10/27/DNA-Shearing-M.magister-gDNA-Additional-Shearing-CH05-01_21-CH07-11-and-Bioanalyzer.html), in preparation for methyl bidning domain (MBD) selection using the MethylMiner Kit (Invitrogen).

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

- [20201030_qubit_DNA_mmag_MBD](https://docs.google.com/spreadsheets/d/1_Met4UuW537OC6dEGgZaD2q8XTDBYISwtagynt7lMCU/edit?usp=sharing)


| Sample_ID | Resuspension_vol(uL) | Total_recovery(ng) | Percent_recovery |
|-----------|----------------------|--------------------|------------------|
| CH01-06   | 21                   | 2.90               | 0.29             |
| CH01-14   | 21                   | 2.98               | 0.30             |
| CH01-22   | 21                   | 3.40               | 0.34             |
| CH01-38   | 21                   | 6.05               | 0.60             |
| CH03-04   | 21                   | 25.20              | 2.52             |
| CH03-15   | 21                   | 2.69               | 0.27             |
| CH03-33   | 21                   | 3.53               | 0.35             |
| CH05-01   | 21                   | 14.62              | 1.46             |


Yields are much lower than expected, as Mac indicated that the _M.magister_ genome was ~7% methylated. However, there is more than enough DNA for the subsequent library prep with the Pico MethylSeq Kit (Zymo).
