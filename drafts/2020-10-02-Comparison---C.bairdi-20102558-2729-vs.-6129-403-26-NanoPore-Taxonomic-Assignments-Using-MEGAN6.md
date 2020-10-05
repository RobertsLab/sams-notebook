---
layout: post
title: Comparison - C.bairdi 20102558-2729 vs. 6129-403-26 NanoPore Taxonomic Assignments Using MEGAN6
date: '2020-10-02 16:06'
tags:
  - Tanner crab
  - MEGAN6
  - Chionoecetes bairdi
  - nanopore
categories:
  - Miscellaneous
---
After noticing that the [initial MEGAN6 taxonomic assignments for our combined _C.bairdi_ NanoPore data from 20200917](https://robertslab.github.io/sams-notebook/2020/09/17/Taxonomic-Assignments-C.bairdi-NanoPore-Reads-Using-DIAMOND-BLASTx-on-Mox-and-MEGAN6-daa2rma-on-swoose.html) revealed a high number of bases assigned to _E.canceri_ and _Aquifex sp._, I decided to explore the taxonomic breakdown of just the individual samples to see which of the samples was contributing to these taxonomic assignments most.

- [20102558-2729-Q7 on 20200928](https://robertslab.github.io/sams-notebook/2020/09/28/Taxonomic-Assignments-C.bairdi-20102558-2729-Q7-NanoPore-Reads-Using-DIAMOND-BLASTx-on-Mox-and-MEGAN6-daa2rma-on-emu.html): uninfected muscle


- [6129-403-26-Q7 on 20200928](https://robertslab.github.io/sams-notebook/2020/09/28/Taxonomic-Assignments-C.bairdi-6129-403-26-Q7-NanoPore-Reads-Using-DIAMOND-BLASTx-on-Mox-and-MEGAN6-daa2rma-on-emu.html): _Hematodinium_-infected hemolymph

After completing the individual taxonomic assignments, I compared the two sets of assignments using MEGAN6 and generated this bar plot showing percentage of _normalized_ base counts assigned to the following groups _within each sample_:

- _Aquifex sp._

- _Arthropoda_

- _E.canceri_

- _SAR_ (Supergroup within which _Alveolata_/_Hematodinium sp._ falls)

##### IMPORTANT!!!

- The taxonomic makeup shown in these comparisons is only a comparison of bases assigned amongst the _four taxa selected above_. It is _not_ a comparison of the full taxonomic makeup of the two samples. I will discuss the data shown here in that context.


![20201002_cbai_nanopore_20102558-2729-Q7-vs-6129-403-26-Q7_megan-taxonomic-comparison-bar-plot](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20201002_cbai_nanopore_20102558-2729-Q7-vs-6129-403-26_megan-taxonomic-comparison-bar-plot.png?raw=true)


Comparison table:

| Taxa                | 20102558-2729-Q7_base-counts | 20102558-2729-Q7_base-counts(%) | 6129-403-26-Q7_base-counts | 6129-403-26-Q7_base-counts(%) |
|---------------------|------------------------------|---------------------------------|----------------------------|-------------------------------|
| Aquifex sp.         | 221,823.00                   | 10.25                           | 199,287.06                 | 10.43                         |
| Arthropoda          | 1,046,619.00                 | 48.38                           | 1,134,731.00               | 59.40                         |
| Enterospora canceri | 889,082.00                   | 41.10                           | 561,754.19                 | 29.41                         |
| Sar                 | 5,855.00                     | 0.27                            | 14,582.56                  | 0.76                          |
| TOTAL               | 2,163,379.00                 |                                 | 1,910,354.81               |                               |

Some observations:

- _Aquifex sp._ account for nearly the same percentage of assignments in both samples.

- _Arthropoda_ makes up ~50% of assigned bases in the uninfected muscle sample (20102558-2729), but ~60% in the _Hematodinium_-infected hemolymph sample. (6129-403-26).

- _E.canceri_ makes up ~41% of assigned bases in the uninfected muscle sample (20102558-2729), but only ~30% in the _Hematodinium_-infected hemolymph sample.

- _SAR_ contributes a very small percentage to each of the two samples, but has ~2.8x the number of assigned bases. Additionally, as noted in the taxonomic assignment analysis of [20102558-2729-Q7 on 20200928](https://robertslab.github.io/sams-notebook/2020/09/28/Taxonomic-Assignments-C.bairdi-20102558-2729-Q7-NanoPore-Reads-Using-DIAMOND-BLASTx-on-Mox-and-MEGAN6-daa2rma-on-emu.html), no bases are assigned to descendants of this Supergroup, whereas in the taxonomic analysis of [6129-403-26-Q7 on 20200928](https://robertslab.github.io/sams-notebook/2020/09/28/Taxonomic-Assignments-C.bairdi-6129-403-26-Q7-NanoPore-Reads-Using-DIAMOND-BLASTx-on-Mox-and-MEGAN6-daa2rma-on-emu.html), there _are_ bases assigned within the descendants of this Supergroup, down the level of _Hematodinium sp._ Genus.
