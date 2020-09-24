---
layout: post
title: Assembly Assessment - BUSCO C.bairdi Genome v1.01 on Mox
date: '2020-09-24 04:51'
tags:
  - Chionoecetes bairdi
  - Tanner crab
  - BUSCO
  - genome
  - mox
  - assembly
categories:
  - Miscellaneous
---



---

#### RESULTS

As usual, very fast, ~1.5mins:

![BUSCO runtime on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200924_cbai_genome_v1.01_busco.png?raw=true)

Output folder:

- [20200924_cbai_genome_v1.01_busco/](https://gannet.fish.washington.edu/Atumefaciens/20200924_cbai_genome_v1.01_busco/)


  - [20200924_cbai_genome_v1.01_busco/run_cbai_genome_v1.01.fasta/short_summary_cbai_genome_v1.01.fasta.txt](https://gannet.fish.washington.edu/Atumefaciens/20200924_cbai_genome_v1.01_busco/run_cbai_genome_v1.01.fasta/short_summary_cbai_genome_v1.01.fasta.txt)

```
# BUSCO version is: 3.0.2
# The lineage dataset is: metazoa_odb9 (Creation date: 2016-02-13, number of species: 65, number of BUSCOs: 978)
# To reproduce this run: python /gscratch/srlab/programs/busco-v3/scripts/run_BUSCO.py -i /gscratch/srlab/sam/data/C_bairdi/genomes/cbai_genome_v1.01.fasta -o cbai_genome_v1.01.fasta -l /gscratch/srlab/sam/data/databases/BUSCO/metazoa_odb9/ -m genome -c 28 --long -z -sp fly --augustus_parameters '--progress=true'
#
# Summarized benchmarking in BUSCO notation for file /gscratch/srlab/sam/data/C_bairdi/genomes/cbai_genome_v1.01.fasta
# BUSCO was run in mode: genome

	C:0.4%[S:0.3%,D:0.1%],F:0.2%,M:99.4%,n:978

	4	Complete BUSCOs (C)
	3	Complete and single-copy BUSCOs (S)
	1	Complete and duplicated BUSCOs (D)
	2	Fragmented BUSCOs (F)
	972	Missing BUSCOs (M)
	978	Total BUSCO groups searched
```
