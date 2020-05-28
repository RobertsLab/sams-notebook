---
layout: post
title: Transcriptome Comparisons - C.bairdi BUSCO Scores
date: '2020-05-28 09:06'
tags:
  - BUSCO
  - Tanner crab
  - mox
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
Since we've generated a [number of versions of the _C.bairdi_ transcriptome](https://github.com/RobertsLab/resources/wiki/Genomic-Resources#transcriptomes), we've decided to compare them using various metrics. Here, I've compared the BUSCO scores generated for each transcriptome using BUSCO's built-in plotting script. The script generates a stacked bar plot of all BUSCO short summary files that it is provided with, as well as the R code used to generate the plot.

This was run on Mox with the following script (GitHub):

- [busco_comparison_plotting.sh](https://github.com/RobertsLab/sams-notebook/blob/661804257f5ba47874f9a76fde3510d81675a1ea/bash_scripts/busco_comparison_plotting.sh)

---

#### RESULTS

Output folder:

- [20200528_cbai_transcriptome_busco_comparisons](https://gannet.fish.washington.edu/Atumefaciens/20200528_cbai_transcriptome_busco_comparisons/)


![busco comparison stacked bar plot](https://gannet.fish.washington.edu/Atumefaciens/20200528_cbai_transcriptome_busco_comparisons/busco_figure.png)



Here's a table to help see which libraries contribute to each of the transcriptomes:

| assembly_name                 | arthropoda_only(y/n) | library_01 | library_02 | library_03 | library_04 |
|-------------------------------|----------------------|------------|------------|------------|------------|
| cbai_transcriptome_v1.0.fasta | y                    | 2018       | 2019       | NA         | NA         |
| cbai_transcriptome_v1.5.fasta | y                    | 2018       | 2019       | 2020-GW    | NA         |
| cbai_transcriptome_v1.6.fasta | y                    | 2018       | 2019       | 2020-GW    | 2020-UW    |
| cbai_transcriptome_v1.7.fasta | y                    | 2018       | 2019       | 2020-UW    | NA         |
| cbai_transcriptome_v2.0.fasta | n                    | 2018       | 2019       | 2020-GW    | 2020-UW    |
| cbai_transcriptome_v3.0.fasta | n                    | 2018       | 2019       | 2020-UW    | NA         |

Unsurprisingly, we see a high amount of duplicated BUSCOs in these results. Why is this unsurprising? This is not surprising because we looked at BUSCO results using the full Trinty transcriptome FastAs. These FastAs include _all_ isoforms for any given gene. As such, the presence of the isoforms will lead to a large increase in duplicated (and fragmented) BUSCOs.

Also, we see that transcriptomes v2.0 & v3.0 show the highest amounts of duplicated BUSCOs, compared with the other three. This is likely due to the fact that these two assemblies have _not_ been subjected to taxonomic filtering, so BUSCOs are likely being identified from multiple organisms (e.g. _Hematodinium sp._) that would be present.

I'll extract just the genes from each of the assemblies and re-run BUSCO and subsequent comparisons to see how they look.
