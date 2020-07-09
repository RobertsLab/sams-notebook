---
layout: post
title: ENA Submission - Ostrea lurida draft genome Olurida_v081.fa
date: '2020-07-08 11:00'
tags:
  - Ostrea lurida
  - ENA
  - genome assembly
  - Olympia oyster
categories:
  - Olympia Oyster Genome Sequencing
---
Submitted our [_Ostrea lurida_ v081 genome assembly FastA](https://github.com/RobertsLab/resources/wiki/Genomic-Resources#genome-1) to the [European Nucloetide Archive](https://www.ebi.ac.uk/ena).

Used the following manifest file:

```
STUDY   PRJEB39287
SAMPLE   ERS4809621
ASSEMBLYNAME   v081
ASSEMBLY_TYPE   isolate
COVERAGE   10
PROGRAM   SOAPdenovo2, PBjelly
PLATFORM   Illumina HiSeq, PacBio
MOLECULETYPE   genomic DNA
FASTA   Olurida_v081.fa.gz
```

I wasn't entirely sure how much coverage we had, so I entered 10x as a value, since it's a requirement for submission. Additionally, you can only supply a single `SAMPLE`, despite the fact that our [sequencing efforts were derived from two tissues from the same animal](https://robertslab.github.io/sams-notebook/2015/09/15/genomic-dna-isolation-olympia-oyster-adductor-musle-mantle-3.html).

Links to the `STUDY` and `SAMPLE` used for submission:

Study: [PRJEB39287]
Sample: [ERS4809621]

---

#### RESULTS
