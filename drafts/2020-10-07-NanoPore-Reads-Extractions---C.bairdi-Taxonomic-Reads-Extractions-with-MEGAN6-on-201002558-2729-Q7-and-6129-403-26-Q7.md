---
layout: post
title: NanoPore Reads Extractions - C.bairdi Taxonomic Reads Extractions with MEGAN6 on 201002558-2729-Q7 and 6129-403-26-Q7
date: '2020-10-07 10:20'
tags:
  - MEGAN6
  - nanopore
  - Tanner crab
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
After completing the [taxonomic comparisons of 201002558-2729-Q7 and 6129-403-26-Q7 on 20201002](https://robertslab.github.io/sams-notebook/2020/10/02/Comparison-C.bairdi-20102558-2729-vs.-6129-403-26-NanoPore-Taxonomic-Assignments-Using-MEGAN6.html), I decided to extract reads assigned to the following taxa for further exploration (primarily to identify contigs/scaffolds in our [cbai_genome_v1.0.fasta](https://owl.fish.washington.edu/halfshell/genomic-databank/cbai_genome_v1.0.fasta) (19MB).

Used MEGAN6 to extract reads from the MEGAN6 RMA6 files from [201002558-2729-Q7 taxonomic assignments on 20200928](https://robertslab.github.io/sams-notebook/2020/09/28/Taxonomic-Assignments-C.bairdi-20102558-2729-Q7-NanoPore-Reads-Using-DIAMOND-BLASTx-on-Mox-and-MEGAN6-daa2rma-on-emu.html) and from [6129-403-26-Q7 on 20200928](https://robertslab.github.io/sams-notebook/2020/09/28/Taxonomic-Assignments-C.bairdi-6129-403-26-Q7-NanoPore-Reads-Using-DIAMOND-BLASTx-on-Mox-and-MEGAN6-daa2rma-on-emu.html).


---

#### RESULTS

Output folders:

- [20201007_cbai_megan-read-extractions_201002558-2729-Q7/](https://gannet.fish.washington.edu/Atumefaciens/20201007_cbai_megan-read-extractions_201002558-2729-Q7/)

  - [20201007_cbai_megan-read-extractions_201002558-2729-Q7/201002558-2729-Q7_summarized-reads-Arthropoda.fasta](https://gannet.fish.washington.edu/Atumefaciens/20201007_cbai_megan-read-extractions_201002558-2729-Q7)

  - [20201007_cbai_megan-read-extractions_201002558-2729-Q7/201002558-2729-Q7_summarized-reads-Enterospora_canceri.fasta](https://gannet.fish.washington.edu/Atumefaciens/20201007_cbai_megan-read-extractions_201002558-2729-Q7)

  - [20201007_cbai_megan-read-extractions_201002558-2729-Q7/201002558-2729-Q7_summarized-reads-Aquifex_sp..fasta](https://gannet.fish.washington.edu/Atumefaciens/20201007_cbai_megan-read-extractions_201002558-2729-Q7)

  - [20201007_cbai_megan-read-extractions_201002558-2729-Q7/201002558-2729-Q7_summarized-reads-Sar.fasta](https://gannet.fish.washington.edu/Atumefaciens/20201007_cbai_megan-read-extractions_201002558-2729-Q7)



- [20201007_cbai_megan-read-extractions_6129-403-26-Q7/](https://gannet.fish.washington.edu/Atumefaciens/20201007_cbai_megan-read-extractions_6129-403-26-Q7/)

  - [20201007_cbai_megan-read-extractions_6129-403-26-Q7/6129-403-26-Q7_summarized-reads-Arthropoda.fasta](https://gannet.fish.washington.edu/Atumefaciens/20201007_cbai_megan-read-extractions_6129-403-26-Q7)

  - [20201007_cbai_megan-read-extractions_6129-403-26-Q7/6129-403-26-Q7_summarized-reads-Alveolata.fasta](https://gannet.fish.washington.edu/Atumefaciens/20201007_cbai_megan-read-extractions_6129-403-26-Q7)

  - [20201007_cbai_megan-read-extractions_6129-403-26-Q7/6129-403-26-Q7_summarized-reads-Aquifex_sp..fasta](https://gannet.fish.washington.edu/Atumefaciens/20201007_cbai_megan-read-extractions_6129-403-26-Q7)

  - [20201007_cbai_megan-read-extractions_6129-403-26-Q7/6129-403-26-Q7_summarized-reads-Enterospora_canceri.fasta](https://gannet.fish.washington.edu/Atumefaciens/20201007_cbai_megan-read-extractions_6129-403-26-Q7)


  Here are stats on the extracted FastAs, generated with the [BBTools](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/) `stats.sh` script, using the `format=5` output format.

  NOTE: The L50 and N50 values are swapped! This seems to be a long-standing "bug" in this program.


  | file                                                         | n_contigs | contig_bp | gap_pct | ctg_N50 | ctg_L50 | ctg_N90 | ctg_L90 | ctg_max | gc_avg  | gc_std  |
|--------------------------------------------------------------|-----------|-----------|---------|---------|---------|---------|---------|---------|---------|---------|
| 201002558-2729-Q7_summarized-reads-Aquifex_sp..fasta         | 280       | 444988    | 0       | 70      | 2050    | 196     | 846     | 8255    | 0.40435 | 0.03572 |
| 201002558-2729-Q7_summarized-reads-Arthropoda.fasta          | 1850      | 3398935   | 0       | 432     | 2495    | 1294    | 957     | 19092   | 0.42579 | 0.06937 |
| 201002558-2729-Q7_summarized-reads-Enterospora_canceri.fasta | 1554      | 2409480   | 0       | 349     | 2216    | 1074    | 771     | 8849    | 0.40246 | 0.04166 |
| 201002558-2729-Q7_summarized-reads-Sar.fasta                 | 6         | 14692     | 0       | 3       | 2729    | 5       | 1559    | 3969    | 0.49442 | 0.04577 |
| 6129-403-26-Q7_summarized-reads-Alveolata.fasta              | 461       | 1753568   | 0       | 95      | 5681    | 293     | 1997    | 19921   | 0.45848 | 0.06894 |
| 6129-403-26-Q7_summarized-reads-Aquifex_sp..fasta            | 4187      | 20911232  | 0       | 877     | 7839    | 2615    | 2662    | 32879   | 0.41532 | 0.03779 |
| 6129-403-26-Q7_summarized-reads-Arthropoda.fasta             | 29649     | 160465929 | 0       | 6130    | 8336    | 18669   | 2802    | 51326   | 0.43271 | 0.05866 |
| 6129-403-26-Q7_summarized-reads-Enterospora_canceri.fasta    | 18111     | 83280155  | 0       | 3589    | 7369    | 11022   | 2357    | 49825   | 0.41499 | 0.04149 |
