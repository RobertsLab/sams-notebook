---
layout: post
title: lncRNA Expression - P.generosa lncRNA Expression Using StringTie
date: '2023-05-04 12:19'
tags: 
  - jupyter
  - lncRNA
  - Panopea generosa
  - Pacific geoduck
  - stringtie
categories: 
  - Miscellaneous
---
After [identifying lncRNA in _P.generosa_](https://robertslab.github.io/sams-notebook/2023/05/02/lncRNA-Identification-P.generosa-lncRNAs-using-CPC2-and-bedtools.html), [Steven asked that I generate an tissue-specific expression/count matrix](https://github.com/RobertsLab/resources/issues/1642) (GitHub Issue). Looking through the documentation for [`StringTie`](https://ccb.jhu.edu/software/stringtie/), I decided that [`StringTie`](https://ccb.jhu.edu/software/stringtie/) would work for this. The overall approach:

- Use tissue-specifc BAMs [from HISAT2 alignments](https://robertslab.github.io/sams-notebook/2023/04/26/Transcript-Alignments-P.generosa-RNA-seq-Alignments-for-lncRNA-Identification-Using-Hisat2-StingTie-and-gffcompare-on-Mox.html)

- Use ["canonical" lncRNA GTF representing all lncRNAs found across all tissues](https://robertslab.github.io/sams-notebook/2023/05/02/lncRNA-Identification-P.generosa-lncRNAs-using-CPC2-and-bedtools.html) as input to [`StringTie`](https://ccb.jhu.edu/software/stringtie/).

- Use [`StringTie`](https://ccb.jhu.edu/software/stringtie/)'s expression estimation feature to generate read coverage and expression (FPKM) for each lncRNA.

- Use [`StringTie`](https://ccb.jhu.edu/software/stringtie/)'s Python script (`prepDE.py3`) to generate tissue/sample-specific count matrix.

This was all run on Raven, using a Jupyter Notebook. Links below:

- [20230504-pgen-lncRNA-expression.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20230504-pgen-lncRNA-expression.ipynb)

Jupyter Notebook (NB Viewer):

- [20230502-pgen-lncRNA-identification.ipynb](https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230504-pgen-lncRNA-expression.ipynb)


<iframe src="https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230504-pgen-lncRNA-expression.ipynb" width="100%" height="1000" scrolling="yes"></iframe>

---

#### RESULTS

This produced `ballgown` expression files, as well as a transcript read count matrix with a column for each tissue/sample. I'm only linking directly to the final matrix file due to the number of samples and redundant `ballgown` files/structure. To view the organization of the output directory, see the [directory tree below](#directory-tree)

Output folder:

- [20230504-pgen-lncRNA-expression/](https://gannet.fish.washington.edu/Atumefaciens/20230504-pgen-lncRNA-expression/)

  #### Transcript count matrix (CSV)

  - [`20230504-pgen-lncRNA-expression/transcript_count_matrix.csv`](https://gannet.fish.washington.edu/Atumefaciens/20230504-pgen-lncRNA-expression/transcript_count_matrix.csv)


    | transcript_id | ctenidia | gonad | heart | juvenile | larvae |
    |---------------|----------|-------|-------|----------|--------|
    | MSTRG.1.1     | 34       | 16    | 13    | 93       | 6      |
    | MSTRG.2.1     | 18       | 5     | 2     | 9        | 2      |
    | MSTRG.3.1     | 15       | 9     | 48    | 171      | 60     |
    | MSTRG.22.1    | 4        | 24    | 7     | 27       | 22     |
    | MSTRG.9.1     | 3        | 133   | 1     | 1681     | 245    |
    | MSTRG.11.1    | 88       | 123   | 77    | 144      | 95     |
    | MSTRG.12.1    | 3        | 81    | 12    | 47       | 50     |
    | MSTRG.25.1    | 6        | 47    | 8     | 0        | 1      |
    | MSTRG.27.1    | 4        | 79    | 9     | 12       | 4      |

### Directory tree

```
├── [4.0K]  ctenidia
│   ├── [3.9M]  ctenidia-pgen-lncRNA-stringtie.gtf
│   ├── [137K]  e2t.ctab
│   ├── [997K]  e_data.ctab
│   ├── [  10]  i2t.ctab
│   ├── [  48]  i_data.ctab
│   └── [1.2M]  t_data.ctab
├── [316K]  gene_count_matrix.csv
├── [4.0K]  gonad
│   ├── [137K]  e2t.ctab
│   ├── [1002K]  e_data.ctab
│   ├── [3.9M]  gonad-pgen-lncRNA-stringtie.gtf
│   ├── [  10]  i2t.ctab
│   ├── [  48]  i_data.ctab
│   └── [1.2M]  t_data.ctab
├── [4.0K]  heart
│   ├── [137K]  e2t.ctab
│   ├── [990K]  e_data.ctab
│   ├── [3.9M]  heart-pgen-lncRNA-stringtie.gtf
│   ├── [  10]  i2t.ctab
│   ├── [  48]  i_data.ctab
│   └── [1.2M]  t_data.ctab
├── [4.0K]  juvenile
│   ├── [137K]  e2t.ctab
│   ├── [1.0M]  e_data.ctab
│   ├── [  10]  i2t.ctab
│   ├── [  48]  i_data.ctab
│   ├── [3.9M]  juvenile-pgen-lncRNA-stringtie.gtf
│   └── [1.2M]  t_data.ctab
├── [4.0K]  larvae
│   ├── [137K]  e2t.ctab
│   ├── [1001K]  e_data.ctab
│   ├── [  10]  i2t.ctab
│   ├── [  48]  i_data.ctab
│   ├── [3.9M]  larvae-pgen-lncRNA-stringtie.gtf
│   └── [1.2M]  t_data.ctab
└── [409K]  transcript_count_matrix.csv

5 directories, 32 files
```