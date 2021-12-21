---
layout: post
title: RNA Isolation - O.nerka Berdahl Tissues
date: '2021-12-20 06:39'
tags: 
  - RNA isolation
  - qubit
  - RNA quantification
  - RNA
categories: 
  - Miscellaneous
---
Finally got around to tackling [this GitHub issue](https://github.com/RobertsLab/resources/issues/1307) regarding isolating RNA from some [_Oncorhynchus nerka_ (sockeye salmon)](https://en.wikipedia.org/wiki/Sockeye_salmon) tissues we have from [Andrew Berdahl's lab](https://marinebiology.uw.edu/faculty-research/faculty-instructor-bios/andrew-berdahl/) (a UW SAFS professor) to use for RNAseq and/or qPCR. We have blood, brain, gonad, and liver samples from individual salmon from two different groups: territorial and social individuals. We've decided to isolate RNA from brain, gonads, and liver from two individuals within each group. All samples are preserved in RNAlater and stored @ -80<sup>o</sup>C.

Sample labelling was as follows:

- Numbers refer to individuals:

  - 1-15 are territorial individuals
  - 16-30 are social individuals

- Letters refer to tissues:

  - (A) brain
  - (B) liver
  - (C) gonads

The following samples were selected for RNA isolation:

- 2A
- 2B
- 2C
- 3A
- 3B
- 3C
- 23A
- 23B
- 23C
- 25A
- 25B
- 25C

RNA was isolated using TriReagent and the Direct-zol RNA Microprep Kit (ZymoResearch), with the DNase I on-column treatment step. Entire brain samples were processed to minimized heterogeneity between samples in case entire brain was not collected in all samples processed. All other tissues were divided in half with a new razor blade. Forceps were rinsed in distilled H<sub>2</sub>O, soaked in 10% bleach solution for 10mins, and then rinsed in distilled H<sub>2</sub>O before re-use. All centrifugation steps were performed at 16,000g for 1.5mins. Here's a brief overview of the process.

Tubes containing tissues were allowed to thaw completely at room temperature (RT). Tissues were homogenized in 500uL of TriReagent with "disposable" platic mortar/pestle tubes (1.5mL). After homogenization, an additional 500uL of TriReagent was added to the tube, vortexed and incubated at RT for 15mins. Insoluble debris was pelleted and supernatant was transferred to a 2.0mL tube. In the case of the train tissues, the fatty top layer was avoided, and the liquid phase in between the pellet and the fat layer was transferred. An equal volume (1mL) of 100% ethanol was added to this supernatant and mixed thoroughly by pipetting. Direct-zol Microprep Kit protocol was followed from here on, including on-column DNase I treatment. Samples were eluted with 50uL of H<sub>2</sub>O.

Of note, the brain samples were a bit challenging. They were probably a bit large for the final volume of TriReagent used (1mL). Additionally, the high fat content made homogenization difficult, as well as post-centrifugation separation. The fat, unsurprisingly, remains at the top of the liquid phase after centrifugation. Additionally, the fat seemed to coat the pipette tip when inserting through the fat layer to try to get just the liquid phase, making it difficult to capture the liquid phase cleanly.

RNA was quantified using the Roberts Lab Qubit 3.0 using the Qubit RNA High Sensitivity assay.

All RNA was stored @ -80<sup>o</sup>C in [Sam's RNA Box #2](https://docs.google.com/spreadsheets/d/1jL9gOqtcHrm8JPUtZ5KShpX7_olFuci_5Gq7xqgZKIM/edit?usp=sharing), slots A1 - B3


---

#### RESULTS

Raw Qubit data (Google Sheet):

- [20211220_qubit_rna_salmon](https://docs.google.com/spreadsheets/d/1NtuztNyNWf32ggePzefrvC0TNMT2QL9FQd8EClEZiEc/edit?usp=sharing)

Summary table:

| Sample | Tissue | Concentration (ng/uL) | Yield (ng) |
|--------|--------|-----------------------|------------|
| 2A     | brain  | 0                     | 0          |
| 2B     | liver  | 190                   | 9500       |
| 2C     | gonad  | 196                   | 9800       |
| 3A     | brain  | 0.602                 | 30.1       |
| 3B     | liver  | 186                   | 9300       |
| 3C     | gonad  | 51.8                  | 2590       |
| 23A    | brain  | 0                     | 0          |
| 23B    | liver  | 200                   | 10000      |
| 23C    | gonad  | 200                   | 20000      |
| 25A    | brain  | 20.8                  | 1040       |
| 25B    | liver  | 200                   | 20000      |
| 25C    | gonad  | 114                   | 22800      |


Well, it's clear that the brain isolations did not go well. Ugh. I might consider isolating some additional individuals in order to have a full suite of RNA from an individual's set of tissues. For the brain tissue, I'd adjust things by increasing the final volume of TriReagent to accommodate the amount of insoluble fat. I'd also perform multiple rounds of "pelleting" the sample post-homogenization in order to minimize any fat carryover to the Direct-zol columns. An additional approach to the brain tissue would be to pulverize them under liquid nitrogen. This is always the best approach, but is often not the most practical.

The remainder of the tissue samples had satisfactory yields (although, 3C is lower than expected). Will discuss results with Steven and decided how to proceed.
