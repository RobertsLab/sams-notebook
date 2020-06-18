---
layout: post
title: Metagenomics - Data Extractions Using MEGAN6
date: '2020-06-18 10:50'
tags:
  - metagenomics
  - MEGAN6
categories:
  - Miscellaneous
---
Decided to finally take the time to methodically extract data from our metagenomics project so that I have the tables handy when I need them and I can easily share them with other people. Previously, I hadn't done this due to limitations on looking at the data remotely. I finally downloaded all of [the RMA6 files from 20191014](https://robertslab.github.io/sams-notebook/2019/10/14/Metagenomics-Annotation-P.generosa-Water-Samples-with-MEGAN6.html) after being fed up with the remote desktop connection _and_ upgrading the size of my hard drive (5 of the six RMA6 files are >40GB in size).

Here's an explanation of what was done and how the output files (see RESULTS section below) are named.

- All RMA6 files were imported Files using absolute read counts.

- For taxonomic extraction, data was extracted at the Class level.

- All output files were generated using the "summarized" option when exporting, meaning that all the reads at and below the terminal taxonomic class were summed to generate the counts for a given Class.

- All output files are tab-delimited.

Files are named in the following fashions:

PREFIXES:

- abs-reads_abs-comparison_: Files were imported using absolute read counts and comparison was run using absolute read counts.

- abs-reads-ind-samples_: Files were imported using absolute read counts and individual samples were analyzed.

ROOTS:

- _day_: Data is grouped by day.

- _pH_: Data is grouped by pH.

SUFFIXES:

- interpro2go: Gene ontology assignments.

- reads: Read counts.

- PathToCount: Shows full "path" (either GO terms or taxonomy) leading to,
and including, the terminal term and corresponding summarized counts (i.e.
sum of all reads at terminal term and all below that term) of reads assigned
to the terminal term.

- PathToPercent: Shows full "path" (either GO terms or taxonomy) leading to,
and including, the terminal term and corresponding percentage of summarized counts (i.e.
sum of all reads at terminal term and all below that term) of reads assigned
to the terminal term. This is percentage of all reads assigned within the designated group/sample.
It is NOT a percentage of all reads in the entire experiment!!

Here's how the sample names breakdown:

| Sample | Developmental Stage (days post-fertilization) | pH Treatment |
|--------|-------------------------|--------------|
| MG1    | 13                      | 8.2          |
| MG2    | 17                      | 8.2          |
| MG3    | 6                       | 7.1          |
| MG5    | 10                      | 8.2          |
| MG6    | 13                      | 7.1          |
| MG7    | 17                      | 7.1          |

NOTE: Days used in analysis correspond to Emma's day conversion:

| Date | Rhonda’s day | Emma’s day |
|------|--------------|------------|
| 5/15 | 6            | 1          |
| 5/19 | 10           | 5          |
| 5/22 | 13           | 8          |
| 5/26 | 17           | 12         |

---

#### RESULTS

Output folder:

- [20200618_metagenomics_megan_tables](https://gannet.fish.washington.edu/Atumefaciens/20200618_metagenomics_megan_tables)

- [abs-reads_abs-comparison_day_interpro2goPathToCount.txt](https://gannet.fish.washington.edu/Atumefaciens/20200618_metagenomics_megan_tables/abs-reads_abs-comparison_day_interpro2goPathToCount.txt)

- [abs-reads_abs-comparison_day_interpro2goPathToPercent.txt](https://gannet.fish.washington.edu/Atumefaciens/20200618_metagenomics_megan_tables/abs-reads_abs-comparison_day_interpro2goPathToPercent.txt)

- [abs-reads_abs-comparison_Day.megan](https://gannet.fish.washington.edu/Atumefaciens/20200618_metagenomics_megan_tables/abs-reads_abs-comparison_Day.megan)

- [abs-reads_abs-comparison_day_readsTaxonPathToCount.txt](https://gannet.fish.washington.edu/Atumefaciens/20200618_metagenomics_megan_tables/abs-reads_abs-comparison_day_readsTaxonPathToCount.txt)

- [abs-reads_abs-comparison_day_readsTaxonPathToPercent.txt](https://gannet.fish.washington.edu/Atumefaciens/20200618_metagenomics_megan_tables/abs-reads_abs-comparison_day_readsTaxonPathToPercent.txt)

- [abs-reads_abs-comparison_pH_interpro2goPathToCount.txt](https://gannet.fish.washington.edu/Atumefaciens/20200618_metagenomics_megan_tables/abs-reads_abs-comparison_pH_interpro2goPathToCount.txt)

- [abs-reads_abs-comparison_pH_interpro2goPathToPercent.txt](https://gannet.fish.washington.edu/Atumefaciens/20200618_metagenomics_megan_tables/abs-reads_abs-comparison_pH_interpro2goPathToPercent.txt)

- [abs-reads_abs-comparison_pH.megan](https://gannet.fish.washington.edu/Atumefaciens/20200618_metagenomics_megan_tables/abs-reads_abs-comparison_pH.megan)

- [abs-reads_abs-comparison_pH_readsTaxonPathToCount.txt](https://gannet.fish.washington.edu/Atumefaciens/20200618_metagenomics_megan_tables/abs-reads_abs-comparison_pH_readsTaxonPathToCount.txt)

- [abs-reads_abs-comparison_pH_readsTaxonPathToPercent.txt](https://gannet.fish.washington.edu/Atumefaciens/20200618_metagenomics_megan_tables/abs-reads_abs-comparison_pH_readsTaxonPathToPercent.txt)

- [abs-reads-ind-samples_readsTaxonPathToCount.txt](https://gannet.fish.washington.edu/Atumefaciens/20200618_metagenomics_megan_tables/abs-reads-ind-samples_readsTaxonPathToCount.txt)

- [abs-reads-ind-samples_readsTaxonPathToPercent.txt](https://gannet.fish.washington.edu/Atumefaciens/20200618_metagenomics_megan_tables/abs-reads-ind-samples_readsTaxonPathToPercent.txt)

- [megan_log.txt](https://gannet.fish.washington.edu/Atumefaciens/20200618_metagenomics_megan_tables/megan_log.txt)
