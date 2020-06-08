---
layout: post
title: Transcriptome Assessment - BUSCO Metazoa on C.bairdi Transcriptome v3.1
date: '2020-06-05 12:31'
tags:
  - Chionoecetes bairdi
  - Tanner crab
  - BUSCO
  - mox
  - transcriptome
categories:
  - Miscellaneous
---
Continuing to try to identify the best [_C.bairdi_ transcriptome](https://github.com/RobertsLab/resources/wiki/Genomic-Resources#transcriptomes), we decided to [extract all non-dinoflagellate sequences from `cbai_transcriptome_v2.0` (RNAseq shorthand: 2018, 2019, 2020-GW, 2020-UW) and `cbai_transcriptome_v3.0`](https://robertslab.github.io/sams-notebook/2020/06/05/Sequence-Extractions-C.bairdi-Transcriptomes-v2.0-and-v3.0-Excluding-Alveolata-with-MEGAN6-on-Swoose.html) (RNAseq shorthand: 2018, 2019, 2020-UW).

Now, want to assess its `cbai_transcriptome_v3.1` "completeness" using BUSCO and the `metazoa_odb9` database.

BUSCO was run with the `--mode transcriptome` option on Mox.

SBATCH script (GitHub):

- [20200605_cbai_busco_transcriptome_v3.1.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200605_cbai_busco_transcriptome_v3.1.sh)

```shell

```


---

#### RESULTS

As always, very quick; ~6.5mins:

![cbai v3.1 BUSCO runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200605_cbai_busco_transcriptome_v3.1_runtime.png?raw=true)

Output folder:

- [20200605_cbai_busco_transcriptome_v3.1/](https://gannet.fish.washington.edu/Atumefaciens/20200605_cbai_busco_transcriptome_v3.1/)

Short summary file (text):

- [20200605_cbai_busco_transcriptome_v3.1/run_cbai_transcriptome_v3.1.fasta/short_summary_cbai_transcriptome_v3.1.fasta.txt](https://gannet.fish.washington.edu/Atumefaciens/20200605_cbai_busco_transcriptome_v3.1/run_cbai_transcriptome_v3.1.fasta/short_summary_cbai_transcriptome_v3.1.fasta.txt)

```
# BUSCO version is: 3.0.2
# The lineage dataset is: metazoa_odb9 (Creation date: 2016-02-13, number of species: 65, number of BUSCOs: 978)
# To reproduce this run: python /gscratch/srlab/programs/busco-v3/scripts/run_BUSCO.py -i /gscratch/srlab/sam/data/C_bairdi/transcriptomes/cbai_transcriptome_v3.1.fasta -o cbai_transcriptome_v3.1.fasta -l /gscratch/srlab/sam/data/databases/BUSCO/metazoa_odb9/ -m transcriptome -c 28 --long -z
#
# Summarized benchmarking in BUSCO notation for file /gscratch/srlab/sam/data/C_bairdi/transcriptomes/cbai_transcriptome_v3.1.fasta
# BUSCO was run in mode: transcriptome

	C:98.3%[S:25.2%,D:73.1%],F:1.4%,M:0.3%,n:978

	961	Complete BUSCOs (C)
	246	Complete and single-copy BUSCOs (S)
	715	Complete and duplicated BUSCOs (D)
	14	Fragmented BUSCOs (F)
	3	Missing BUSCOs (M)
	978	Total BUSCO groups searched
```

Will add scores to [Genomic Resources wiki](https://github.com/RobertsLab/resources/wiki/Genomic-Resources). Also, after running BUSCO on the `cbai_transcriptome_v3.1` transcriptome, I will update [my BUSCO comparision notebook entry from 20200528](https://robertslab.github.io/sams-notebook/2020/05/28/Transcriptome-Comparisons-C.bairdi-BUSCO-Scores.html).
