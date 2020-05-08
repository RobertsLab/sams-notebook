---
layout: post
title: Transcriptome Assembly - C.bairdi All RNAseq Data Without Taxonomic Filters with Trinity on Mox
date: '2020-05-02 22:01'
tags:
  - trinity
  - mox
  - Tanner crab
  - RNAseq
  - Chionoecetes bairdi
  - transcriptome
  - assembly
categories:
  - Miscellaneous
---



---

#### RESULTS

There were some hiccups (Mox crashes, weird Trinity error that interrupted job), but overall, it took ~4 days of actual run time.

![cbai Trinity all RNAseq runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200502_cbai_trinity_all_RNAseq_runtime.png?raw=true)

Output folder:

- [20200502_cbai_trinity_all_RNAseq/](https://gannet.fish.washington.edu/Atumefaciens/20200502_cbai_trinity_all_RNAseq/)

FastA (904MB):

- [20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta)

FastA Index (text):

- [20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta.fai](https://gannet.fish.washington.edu/Atumefaciens/20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta.fai)


Trinity gene trans map (text; useful for downstream gene expression/annotation with Trinity/Trinotate):

- [20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta.gene_trans_map](https://gannet.fish.washington.edu/Atumefaciens/20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta.gene_trans_map)

Trinity FastA sequence lengths file (text; useful for downstream gene expression/annotation with Trinity/Trinotate):

- [20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta.seq_lens](https://gannet.fish.washington.edu/Atumefaciens/20200502_cbai_trinity_all_RNAseq/trinity_out_dir/20200507.C_bairdi.Trinity.fasta.seq_lens)

Assemby stats (text):

- [20200502_cbai_trinity_all_RNAseq/assembly_stats.txt](https://gannet.fish.washington.edu/Atumefaciens/20200502_cbai_trinity_all_RNAseq/assembly_stats.txt)

```
################################
## Counts of transcripts, etc.
################################
Total trinity 'genes':	783006
Total trinity transcripts:	1412254
Percent GC: 45.41

########################################
Stats based on ALL transcript contigs:
########################################

	Contig N10: 3733
	Contig N20: 2571
	Contig N30: 1863
	Contig N40: 1285
	Contig N50: 811

	Median contig length: 325
	Average contig: 579.92
	Total assembled bases: 819000346


#####################################################
## Stats based on ONLY LONGEST ISOFORM per 'GENE':
#####################################################

	Contig N10: 3093
	Contig N20: 1768
	Contig N30: 933
	Contig N40: 576
	Contig N50: 431

	Median contig length: 285
	Average contig: 434.16
	Total assembled bases: 339947966
```
