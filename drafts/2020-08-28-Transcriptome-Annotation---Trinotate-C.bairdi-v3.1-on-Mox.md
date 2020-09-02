---
layout: post
title: Transcriptome Annotation - Trinotate C.bairdi v3.1 on Mox
date: '2020-08-28 04:50'
tags:
  - Tanner crab
  - trinotate
  - Chionoecetes bairdi
  - mox
  - annotation
  - transcriptome
categories:
  - Miscellaneous
---



---

#### RESULTS

Runtime was ~2.5hrs:

![cbai v3.1 Trinotate runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200827_cbai_trinotate_transcriptome-v3.1_runtime.png?raw=true)


Output folder:

- [20200828_cbai_trinotate_transcriptome-v3.1](https://gannet.fish.washington.edu/Atumefaciens/20200828_cbai_trinotate_transcriptome-v3.1)

Annotation feature map (2.6MB; text):

- [20200828.cbai_transcriptome_v3.1.fasta.trinotate.annotation_feature_map.txt](https://gannet.fish.washington.edu/Atumefaciens/20200828_cbai_trinotate_transcriptome-v3.1/20200828.cbai_transcriptome_v3.1.fasta.trinotate.annotation_feature_map.txt)

  - [This can be used to update Trinity-based gene expression matrices like so](https://github.com/trinityrnaseq/trinityrnaseq/wiki/Functional-Annotation-of-Transcripts):

    - ```${TRINITY_HOME}/Analysis/DifferentialExpression/rename_matrix_feature_identifiers.pl Trinity_trans.counts.matrix annot_feature_map.txt > Trinity_trans.counts.wAnnot.matrix```

Annotation report (35MB; CSV)

- [20200828.cbai_transcriptome_v3.1.fasta.trinotate_annotation_report.txt](https://gannet.fish.washington.edu/Atumefaciens/20200828_cbai_trinotate_transcriptome-v3.1/20200828.cbai_transcriptome_v3.1.fasta.trinotate_annotation_report.txt)

Gene ontology (GO) annotations (2.8MB; text)

- [20200828.cbai_transcriptome_v3.1.fasta.trinotate.go_annotations.txt](https://gannet.fish.washington.edu/Atumefaciens/20200828_cbai_trinotate_transcriptome-v3.1/20200828.cbai_transcriptome_v3.1.fasta.trinotate.go_annotations.txt)

SQlite database (543MB; SQLITE):

- [Trinotate.sqlite](https://gannet.fish.washington.edu/Atumefaciens/20200828_cbai_trinotate_transcriptome-v3.1/Trinotate.sqlite)
