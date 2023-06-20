---
layout: post
title: ORF Identification - L.staminea De Novo Transcriptome Assembly v1.0 Using Transdecoder on Mox
date: '2023-06-17 15:27'
tags: 
  - Leukoma staminea
  - little neck clam
  - transdecoder
  - mox
categories: 
  - Miscellaneous
---



---

#### RESULTS

Run time was nearly 20hrs.

![Screencap of L.staminea Transdecoder run time on Mox showing a run time of 19hrs, 12mins, 51secs](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20230617-lsta-transdecoder-transcriptome_v1.0-runtime.png?raw=true)

Output folder:

- [20230617-lsta-transdecoder-transcriptome_v1.0/](https://gannet.fish.washington.edu/Atumefaciens/20230617-lsta-transdecoder-transcriptome_v1.0/)

  #### BED (text)
  - [lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.bed](https://gannet.fish.washington.edu/Atumefaciens/20230617-lsta-transdecoder-transcriptome_v1.0/lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.bed) (30M)

    - MD5: `02497568c87e65279e83551ba8fb43ae`

  #### Coding Sequences (FastA)
  - [lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.cds](https://gannet.fish.washington.edu/Atumefaciens/20230617-lsta-transdecoder-transcriptome_v1.0/lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.cds) (98M)

    - MD5: `1517d724b18d0bd8759cbccc0487e460`

  #### GFF (text)
  - [lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.gff3](https://gannet.fish.washington.edu/Atumefaciens/20230617-lsta-transdecoder-transcriptome_v1.0/lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.gff3) (99M)

    - MD5: `901ab1c9ca1c0998714ff9cd602b2063`

  #### Peptide Sequences (FastA)
  - [lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.pep](https://gannet.fish.washington.edu/Atumefaciens/20230617-lsta-transdecoder-transcriptome_v1.0/lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.pep) (52M)

    - MD5: `53752bdb28bf2f89a04620bcee109a4f`

  #### Pfam output (text)
  - [pfam.domtblout](https://gannet.fish.washington.edu/Atumefaciens/20230617-lsta-transdecoder-transcriptome_v1.0/pfam_out/pfam.domtblout) (132M)

  - MD5: `18cd0fdff4993ed7f1d8f7d36f83e1d6`

  #### BLASTp output (format 6; text)
  - [blastp.outfmt6](https://gannet.fish.washington.edu/Atumefaciens/20230617-lsta-transdecoder-transcriptome_v1.0/blastp_out/blastp.outfmt6) (6.2M)

  - MD5: `c416fbe543555672083f1a63a4935ed0`

When counting complete ORFs (`awk -F"\t" '$3=="gene"' lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.gff3 | grep -c "complete"`), the result is 28,451. This is a _significant_ reduction in potential genes compared to what [Trinity identified in the _do novo_ assembly from yesterday](https://robertslab.github.io/sams-notebook/2023/06/16/Transcriptome-Assembly-De-Novo-L.staminea-Trimmed-RNAseq-Using-Trinity-on-Mox.html) (502,826 "genes"). Additionally, this is a much more realistic number of genes. Overall, ORF identification broke out like so:

```
74533 CDS
74533 exon
35983 five_prime_UTR
74533 gene
74533 mRNA
43403 three_prime_UTR
```

These numbers include partial ORFs. Even including the partial OFRs, these counts are much more realistic compared to the Trinity _de novo_ assembly stats. 