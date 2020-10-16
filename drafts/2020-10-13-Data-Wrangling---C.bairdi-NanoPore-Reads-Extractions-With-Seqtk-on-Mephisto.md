---
layout: post
title: Data Wrangling - C.bairdi NanoPore Reads Extractions With Seqtk on Mephisto
date: '2020-10-13 11:16'
tags:
  - Tanner crab
  - seqtk
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
In my pursuit to identify which contigs/scaffolds of our ["_C.bairdi_" genome assembly from 20200917](https://robertslab.github.io/sams-notebook/2020/09/17/Genome-Assembly-C.bairdi-cbai_v1.0-Using-All-NanoPore-Data-With-Flye-on-Mox.html) correspond to interesting taxa, [based on taxonomic assignments produced by MEGAN6 on 20200928](https://robertslab.github.io/sams-notebook/2020/09/28/Taxonomic-Assignments-C.bairdi-6129-403-26-Q7-NanoPore-Reads-Using-DIAMOND-BLASTx-on-Mox-and-MEGAN6-daa2rma-on-emu.html), I used MEGAN6 to [extract taxa-specific reads from `cbai_genome_v1.01` on 20201007](https://robertslab.github.io/sams-notebook/2020/10/07/NanoPore-Reads-Extractions-C.bairdi-Taxonomic-Reads-Extractions-with-MEGAN6-on-201002558-2729-Q7-and-6129-403-26-Q7.html) - the output is only available in FastA format. Since I want the original reads in FastQ format, I will use the FastA sequence IDs (from the FastA index file) and provide that to [`seqtk`](https://github.com/lh3/seqtk) to extract the FastQ reads for each sample and corresponding taxa.

This was run on my personal computer (mephisto) and documented in a Jupyter Notebook:

Jupyter Notebook (GitHub):

- [20201013_mephisto_cbai_seqtk_megan-fastq-read-extractions.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20201013_mephisto_cbai_seqtk_megan-fastq-read-extractions.ipynb)


---

#### RESULTS

Output folders/files:

- FastQ files end with the `.fq` suffix.

- The ID list supplied to `seqtk` ends with the suffix `seqtk-read-id-list`. It is a simple text file.

##### 201002558-2729-Q7 (_Hematodinium_-free _C.bairdi_ muscle)

- [20201013_201002558-2729-Q7_megan-reads/](https://gannet.fish.washington.edu/Atumefaciens/20201013_201002558-2729-Q7_megan-reads/)

  - [20201013_201002558-2729-Q7_Aquifex_sp_megan.fq](20201013_201002558-2729-Q7_Aquifex_sp_megan.fq)

  - [20201013_201002558-2729-Q7_Aquifex_sp_seqtk-read-id-list](20201013_201002558-2729-Q7_Aquifex_sp_seqtk-read-id-list)

  - [20201013_201002558-2729-Q7_Arthropoda_megan.fq](20201013_201002558-2729-Q7_Arthropoda_megan.fq)

  - [20201013_201002558-2729-Q7_Arthropoda_seqtk-read-id-list](20201013_201002558-2729-Q7_Arthropoda_seqtk-read-id-list)

  - [20201013_201002558-2729-Q7_Enterospora_canceri_megan.fq](20201013_201002558-2729-Q7_Enterospora_canceri_megan.fq)

  - [20201013_201002558-2729-Q7_Enterospora_canceri_seqtk-read-id-list](20201013_201002558-2729-Q7_Enterospora_canceri_seqtk-read-id-list)

  - [20201013_201002558-2729-Q7_Sar_megan.fq](20201013_201002558-2729-Q7_Sar_megan.fq)

  - [20201013_201002558-2729-Q7_Sar_seqtk-read-id-list](20201013_201002558-2729-Q7_Sar_seqtk-read-id-list)

##### 6129-403-26-Q7 (_Hematodinium_-infected _C.bairdi_ hemolymph)

- [20201013_6129-403-26-Q7_megan-reads/](https://gannet.fish.washington.edu/Atumefaciens/20201013_6129-403-26-Q7_megan-reads/)

  - [20201013_6129-403-26-Q7_Alveolata_megan.fq](20201013_6129-403-26-Q7_Alveolata_megan.fq)

  - [20201013_6129-403-26-Q7_Alveolata_seqtk-read-id-list](20201013_6129-403-26-Q7_Alveolata_seqtk-read-id-list)

  - [20201013_6129-403-26-Q7_Aquifex_sp_megan.fq](20201013_6129-403-26-Q7_Aquifex_sp_megan.fq)

  - [20201013_6129-403-26-Q7_Aquifex_sp_seqtk-read-id-list](20201013_6129-403-26-Q7_Aquifex_sp_seqtk-read-id-list)

  - [20201013_6129-403-26-Q7_Arthropoda_megan.fq](20201013_6129-403-26-Q7_Arthropoda_megan.fq)

  - [20201013_6129-403-26-Q7_Arthropoda_seqtk-read-id-list](20201013_6129-403-26-Q7_Arthropoda_seqtk-read-id-list)

  - [20201013_6129-403-26-Q7_Enterospora_canceri_megan.fq](20201013_6129-403-26-Q7_Enterospora_canceri_megan.fq)

  - [20201013_6129-403-26-Q7_Enterospora_canceri_seqtk-read-id-list](20201013_6129-403-26-Q7_Enterospora_canceri_seqtk-read-id-list)

Next up, use [Minimap2](https://github.com/lh3/minimap2) to map these reads to the [`cbai_genome_v1.01.fasta`](https://owl.fish.washington.edu/halfshell/genomic-databank/cbai_genome_v1.01.fasta) (18MB). After that's complete I want to see which contigs/scaffolds [generated in the assembly using Flye on 20200917](https://robertslab.github.io/sams-notebook/2020/09/17/Genome-Assembly-C.bairdi-cbai_v1.0-Using-All-NanoPore-Data-With-Flye-on-Mox.html) have reads mapped to them by each of the taxa. 

Admittedly, I'm not entirely sure where I'm going with this, or if there's even a point any more. However, it's an interesting exercise in bioinformatics stuff (new tools/software, data "munging" practice).
