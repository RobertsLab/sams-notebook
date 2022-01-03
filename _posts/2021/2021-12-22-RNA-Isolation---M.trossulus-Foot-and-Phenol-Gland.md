---
layout: post
title: RNA Isolation - M.trossulus Foot and Phenol Gland
date: '2021-12-22 05:56'
tags: 
  - Mytilus trossulus
  - bay mussel
  - RNA isolation
  - RNA quantification
  - Qubit 3.0
categories: 
  - Miscellaneous
---
As part of a mussel project that Matt George has with the [Pacific States Marine Fisheries Commission (PSMFC)](https://www.psmfc.org/), I'm helping by isolating RNA from a relatively large number of samples. The samples are listed/described in [this GitHub Issue](https://github.com/RobertsLab/resources/issues/1352). Today, I isolated RNA from the following samples (the "F" indicates "foot" and the "PG" indicates "phenol gland" tissues):

- T01-F

- T02-F

- T03-F

- T04-F

- T05-F

- T06-F

- T07-F

- T08-F

- T09-F

- T10-F

- T11-F

- T12-F

- T01-F PG

- T02-F PG

- T03-F PG

- T04-F PG

- T05-F PG

- T06-F PG

Before I get into how RNA was isolated, I need to mention that I actually screwed up on the foot samples! I totally forgot that [I was only supposed to isolate RNA from the _phenol gland_!](https://github.com/RobertsLab/resources/issues/1352). Ugh. Can't believe this. This means I had to go back to each of the foot samples and isolate RNA from the remaining half of the phenol gland. Yeesh.

RNA was isolated using TriReagent and the Direct-zol RNA Microprep Kit (ZymoResearch), with the DNase I on-column treatment step. Foot tissues were allowed to partially thaw to allow me to unfold/unbend the foot and then divided in half lengthwise (along the pedal groove) with a new razor blade. After realizing my screw up (mentioned above), I went back and dissected the phenol gland (essentially the most distal end of the foot). Forceps were rinsed in distilled H<sub>2</sub>O, soaked in 10% bleach solution for 10mins, and then rinsed in distilled H<sub>2</sub>O before re-use. All centrifugation steps were performed at 16,000g for 1.5mins. Here's a brief overview of the process.

Tissues were homogenized in 500uL of TriReagent with "disposable" platic mortar/pestle tubes (1.5mL). After homogenization, an additional 500uL of TriReagent was added to the tube, vortexed and incubated at RT for 10mins. Insoluble debris was pelleted and supernatant was transferred to a 2.0mL tube. An equal volume (1mL) of 100% ethanol was added to this supernatant and mixed thoroughly by pipetting. Direct-zol Microprep Kit protocol was followed from here on, including on-column DNase I treatment. Foot samples were eluted with 50uL of H<sub>2</sub>O, while phenol gland tissues were eluted with 100uL.

RNA was quantified using the Roberts Lab Qubit 3.0 using the Qubit RNA High Sensitivity assay.

All RNA was stored @ -80<sup>o</sup>C in [Sam's RNA Box #2](https://docs.google.com/spreadsheets/d/1jL9gOqtcHrm8JPUtZ5KShpX7_olFuci_5Gq7xqgZKIM/edit?usp=sharing).

---

#### RESULTS

Raw Qubit data (Google Sheet):

- [qubit_20211222_rna_mtro](https://docs.google.com/spreadsheets/d/1ge_0JnRNbKiFFEy-LIVvpjSzDS8wsE_ctyHV-3vmVFw/edit?usp=sharing)


Yields from the foot tissues were extremely high and required multiple rounds of dilutions in order to get the concentrations within the linear range of the Qubit High Sensitivity assay. This led to a somewhat confusing set of raw qubit data (linked above), so I've put together a summary table to make things easier to follow:

Summary table:

| sample               | tissue       | concentration(ng/uL) | volume(uL) | yield(ng) |
|----------------------|--------------|----------------------|------------|-----------|
| M.trossulus T01-F    | foot         | 122                  | 200        | 24400     |
| M.trossulus T02-F    | foot         | 166                  | 50         | 8300      |
| M.trossulus T03-F    | foot         | 186                  | 50         | 9300      |
| M.trossulus T04-F    | foot         | 138                  | 200        | 27600     |
| M.trossulus T05-F    | foot         | 136                  | 200        | 27200     |
| M.trossulus T06-F    | foot         | 106                  | 400        | 42400     |
| M.trossulus T07-F    | foot         | 27.6                 | 50         | 1380      |
| M.trossulus T08-F    | foot         | 172                  | 100        | 17200     |
| M.trossulus T09-F    | foot         | 174                  | 200        | 34800     |
| M.trossulus T10-F    | foot         | 188                  | 50         | 9400      |
| M.trossulus T11-F    | foot         | 116                  | 200        | 23200     |
| M.trossulus T12-F    | foot         | 132                  | 200        | 26400     |
| M.trossulus T01-F PG | phenol gland | 158                  | 50         | 7900      |
| M.trossulus T02-F PG | phenol gland | 92                   | 50         | 4600      |
| M.trossulus T03-F PG | phenol gland | 70.4                 | 50         | 3520      |
| M.trossulus T04-F PG | phenol gland | 44.4                 | 50         | 2220      |
| M.trossulus T05-F PG | phenol gland | 65.8                 | 50         | 3290      |
| M.trossulus T06-F PG | phenol gland | 95.2                 | 50         | 4760      |

