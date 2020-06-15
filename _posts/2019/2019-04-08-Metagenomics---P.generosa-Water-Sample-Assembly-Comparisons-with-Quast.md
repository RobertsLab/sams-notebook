---
layout: post
title: Metagenomics - P.generosa Water Sample Assembly Comparisons with Quast
date: '2019-04-08 09:59'
tags:
  - Panopea generosa
  - geoduck
  - metagenomics
  - quast
  - swoose
categories:
  - Miscellaneous
---
Continuing work on the metagenomics project, [Emma shared her "co-assembly"](https://github.com/RobertsLab/resources/issues/647), so I figured it would be quick and easy to compare hers with mine and get a feel for how different/similar they might be. I did a [similar comparison last week](https://robertslab.github.io/sams-notebook/2019/04/03/Metagenomics-Geoduck-Water-Sample-Assembly-Comparisons-with-MetaQuast.html) where I compared each of our individual water sample assemblies. Those results showed my assemblies generated:

- significantly larger "largest contigs" (10 - 50x larger than Emma's)

- larger N50 values (~2x larger than Emma's)

- total length in bps (~1.5x more than Emma's)

So, I ran Quast on my computer (swoose - Ubuntu 16.04LTS) with the following input FastAs:

- [contigs.fa](http://eagle.fish.washington.edu/oyster/metagenomics_2019/contigs.fa) (Emma's)

- [final.contigs.fa](http://gannet.fish.washington.edu/Atumefaciens/20190102_metagenomics_geo_megahit/megahit_out/final.contigs.fa) (Mine from [20190102_metagenomics_geo_megahit](https://robertslab.github.io/sams-notebook/2019/01/02/Metagenome-Assembly-P.generosa-Water-Sample-HiSeqX-Data-Using-Megahit.html))

```shell
python \
/home/sam/programs/quast-5.0.2/quast.py \
--threads=20 \
--min-contig=100 \
--labels=ets,sjw \
/home/sam/data/metagenomics/P_generosa/emma_assemblies/contigs.fa \
/home/sam/data/metagenomics/P_generosa/final.contigs.fa
```

---

#### RESULTS

Output folder:

- [20190408_metagenomics_pgen_quast_comparison/](http://gannet.fish.washington.edu/Atumefaciens/20190408_metagenomics_pgen_quast_comparison/)

Quast report (HTML):

- [20190408_metagenomics_pgen_quast_comparison/quast_results/results_2019_04_08_09_47_17/report.html](http://gannet.fish.washington.edu/Atumefaciens/20190408_metagenomics_pgen_quast_comparison/quast_results/results_2019_04_08_09_47_17/report.html)


![Screen cap of assembly comparison report](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190408_metagenomics_pgen_quast-01.png?raw=true)

Well, these results are very strange. The thing that immediately jumps out to me is how "small" Emma's assembly is. My assembly has nearly _5x_ the number of bases as hers does (2.2Gbp vs 412Mbp). This is an enormous disparity between the two assemblies. I'll talk to Emma and try to get explicit details on how she constructed her assembly.
