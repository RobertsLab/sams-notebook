---
layout: post
title: Transcriptome Annotation - Trinotate Hematodinium v1.7 on Mox
date: '2021-03-09 09:45'
tags:
  - trinotate
  - Hematodinium
  - Tanner crab
  - Chionoecetes bairdi
  - transcriptome
  - annotation
categories:
  - Miscellaneous
---
To continue annotation of our _Hematodinium_ v1.7 transcriptome assembly, I wanted to run [Trinotate](https://github.com/Trinotate/Trinotate.github.io/wiki).

Info for each transcriptome version (library composition, assembly dates, BUSCO, etc) can be found in this table:

- [hemat_transcriptome_comp](https://docs.google.com/spreadsheets/d/1A81cFdFw5Mlks5DWMmq0-8eVqyTXqmoCsHNWs95N_p4/edit?usp=sharing)

This was run on Mox.

SBATCH script (GitHub):

- [20210309_hemat_trinotate_transcriptome-v1.7.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210309_hemat_trinotate_transcriptome-v1.7.sh)

```shell

```

---

#### RESULTS

Took ~36mins to run:

![Runtime for Hemat v1.7 Trinotate job](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210309_hemat_trinotate_transcriptome-v1.7_runtime.png?raw=true)

Output folder:

- [20210309_hemat_trinotate_transcriptome-v1.7/](https://gannet.fish.washington.edu/Atumefaciens/20210309_hemat_trinotate_transcriptome-v1.7/)

Annotation feature map (2.3MB; TXT):

- [20210309.hemat_transcriptome_v1.7.fasta.trinotate.annotation_feature_map.txt](https://gannet.fish.washington.edu/Atumefaciens/20210309_hemat_trinotate_transcriptome-v1.7/20210309.hemat_transcriptome_v1.7.fasta.trinotate.annotation_feature_map.txt)

  - [This can be used to update Trinity-based gene expression matrices like so](https://github.com/trinityrnaseq/trinityrnaseq/wiki/Functional-Annotation-of-Transcripts):

    - ```${TRINITY_HOME}/Analysis/DifferentialExpression/rename_matrix_feature_identifiers.pl Trinity_trans.counts.matrix annot_feature_map.txt > Trinity_trans.counts.wAnnot.matrix```

Gene ontology (GO) annotations (7.9MB; TXT):

- [20210309.hemat_transcriptome_v1.7.fasta.trinotate.go_annotations.txt](https://gannet.fish.washington.edu/Atumefaciens/20210309_hemat_trinotate_transcriptome-v1.7/20210309.hemat_transcriptome_v1.7.fasta.trinotate.go_annotations.txt)

Annotation report (25MB; CSV):

- [20210309.hemat_transcriptome_v1.7.fasta.trinotate_annotation_report.txt](https://gannet.fish.washington.edu/Atumefaciens/20210309_hemat_trinotate_transcriptome-v1.7/20210309.hemat_transcriptome_v1.7.fasta.trinotate_annotation_report.txt)

SQlite database (442MB; SQLITE):

- [Trinotate.sqlite](https://gannet.fish.washington.edu/Atumefaciens/20210309_hemat_trinotate_transcriptome-v1.7/Trinotate.sqlite)
