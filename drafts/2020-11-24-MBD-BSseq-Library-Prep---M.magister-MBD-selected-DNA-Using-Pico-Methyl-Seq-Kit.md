---
layout: post
title: MBD BSseq Library Prep - M.magister MBD-selected DNA Using Pico Methyl-Seq Kit
date: '2020-11-24 10:27'
tags:
  - Metacarcinus magister
  - dungeness crab
  - MBD
  - MBD-BSseq
  - bisfulite sequencing
categories:
  - Miscellaneous
---
[After finishing the final set of eight MBD selections on 20201103](https://robertslab.github.io/sams-notebook/2020/11/03/MBD-Selection-M.magister-Sheared-Gill-gDNA-16-of-24-Samples-Set-3-of-3.html), I'm finally ready to make the BSseq libraries using the [Pico Methyl-Seq Library Prep Kit (ZymoResearch)](https://github.com/RobertsLab/resources/blob/master/protocols/Commercial_Protocols/ZymoResearch_PicoMethylseq.pdf) (PDF). I followed the manufacturer's protocols with the following notes/changes (organized by each section in the protocol):

##### GENERAL

- Protocol was followed for using input DNA range 1ng - 50ng.

- All thermalcycling was performed on the Roberts Lab PTC-200 (MJ Research).

- All thermalcycling used a heated lid temp of 104<sup>o</sup>C, unless a different temp was specified in the protocol.

- All elution steps were performed with heated elution buffer (55<sup>o</sup>C).

##### SECTION 2

- Used 0.5mL PCR tubes, since 0.2uL tubes were note specified and the 0.5mL tubes are easier to handle/work with.

- PrepAmp Mix was prepared as a master mix and then distributed to samples as required

| PrepAmp_component   | single_rxn_vol(uL) | num_rxns | total_vol(uL) |
|---------------------|--------------------|----------|---------------|
| PrepAmp Buffer (5x) | 1                  | 26       | 26            |
| PrepAmp Pre-mix     | 3.75               | 26       | 97.5          |
| PrepAmp Polymerase  | 0.3                | 26       | 7.8           |

##### SECTION 3

- Elutions consistently returned 1.5uL _less_ volume than input (e.g 12uL input returned 10.5uL).

  - This was also noted [by Shelly when she utilized this kit previously](https://shellytrigg.github.io/122th-post/).

##### SECTION 4

- Recovery from SECTION 3 elution was only 10.5uL (expected 11.5uL based on protocol), so added 1.5uL H<sub>2</sub>O to each sample.

- Based on input DNA range (1ng - 50ng), number of cycles was set to 8.

##### SECTION 5

- Anticipating the loss in elution volume, samples were eluted with 13.5uL in the preceding cleanup step and yielded 12uL (the target input volume for this section).



##### Sample - Sequencing Primer Index Table

| Sample  | Illumina_TruSeq_index_num | Illumina_TruSeq_Index_seq | SRID/ZymoID |
|---------|---------------------------|---------------------------|-------------|
| CH01-06 | 1                         | CGATGT                    | 1732        |
| CH01-14 | 2                         | TGACCA                    | A           |
| CH01-22 | 3                         | ACAGTG                    | 1731        |
| CH01-38 | 4                         | GCCAAT                    | B           |
| CH03-04 | 5                         | CAGATC                    | C           |
| CH03-15 | 6                         | CTTGTA                    | D           |
| CH03-33 | 7                         | CGTGAT                    | E           |
| CH05-01 | 8                         | GCCTAA                    | 1730        |
| CH05-06 | 9                         | TCAAGT                    | 1729        |
| CH05-21 | 10                        | CTGATC                    | 1728        |
| CH05-24 | 11                        | AAGCTA                    | 1727        |
| CH05-26 | 12                        | GTAGCC                    | F           |
| CH07-06 | 13                        | TTGACT                    | 1726        |
| CH07-11 | 14                        | GGAACT                    | 1725        |
| CH07-24 | 15                        | TGACAT                    | 1724        |
| CH09-02 | 16                        | GGACGG                    | 1723        |
| CH09-11 | 17                        | CTCTAC                    | 1722        |
| CH09-13 | 18                        | GCGGAC                    | 1721        |
| CH09-28 | 19                        | TTTCAC                    | 1720        |
| CH09-29 | 20                        | GGCCAC                    | 1719        |
| CH10-01 | 21                        | CGAAAC                    | 1718        |
| CH10-08 | 22                        | CGTACG                    | 1717        |
| CH10-11 | 23                        | CCACTC                    | 1805        |
| CH10-19 | 25                        | ATCAGT                    | 1804        |
