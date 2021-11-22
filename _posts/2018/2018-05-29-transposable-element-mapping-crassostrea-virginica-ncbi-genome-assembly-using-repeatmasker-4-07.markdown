---
author: kubu4
comments: true
date: 2018-05-29 22:02:26+00:00
layout: post
slug: transposable-element-mapping-crassostrea-virginica-ncbi-genome-assembly-using-repeatmasker-4-07
title: Transposable Element Mapping – Crassostrea virginica NCBI Genome Assembly using
  RepeatMasker 4.07
wordpress_id: 3392
author:
  - kubu4
categories:
  - Miscellaneous
tags:
  - Crassostrea virginica
  - jupyter notebook
  - RepeatMasker
  - roadrunner
  - TE
  - transposable elements
---

Genome used: [NCBI GCA_002022765.4_C_virginica-3.0](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/002/022/765/GCA_002022765.4_C_virginica-3.0)

I ran RepeatMasker (v4.07) with RepBase-20170127 and RMBlast 2.6.0 with species set to _Crassotrea virginica_.

All commands were documented in a Jupyter Notebook (GitHub):


  * [20180529_roadrunner_virginica_TEs_repeatmasker.ipynb](https://github.com/sr320/LabDocs/blob/master/jupyter_nbs/sam/20180529_roadrunner_virginica_TEs_repeatmasker.ipynb)

---

### RESULTS:



Output folder:

  * [20180529_virginica_repeatmasker](https://owl.fish.washington.edu/Athaliana/20180529_virginica_repeatmasker/)


Output table (GFF):

  * [GCF_002022765.2_C_virginica-3.0_genomic.fasta.out.gff](https://owl.fish.washington.edu/Athaliana/20180529_virginica_repeatmasker/GCF_002022765.2_C_virginica-3.0_genomic.fasta.out.gff)



Summary table (text):

  * [GCF_002022765.2_C_virginica-3.0_genomic.fasta.tbl](https://owl.fish.washington.edu/Athaliana/20180529_virginica_repeatmasker/GCF_002022765.2_C_virginica-3.0_genomic.fasta.tbl)

    ```
    ==================================================
    file name: GCF_002022765.2_C_virginica-3.0_genomic.fasta
    sequences:            11
    total length:  684741128 bp  (684675328 bp excl N/X-runs)
    GC level:         34.83 %
    bases masked:   46637065 bp ( 6.81 %)
    ==================================================
                   number of      length   percentage
                   elements*    occupied  of sequence
    --------------------------------------------------
    Retroelements        43139      8952068 bp    1.31 %
       SINEs:            43139      8952068 bp    1.31 %
       Penelope              0            0 bp    0.00 %
       LINEs:                0            0 bp    0.00 %
        CRE/SLACS            0            0 bp    0.00 %
         L2/CR1/Rex          0            0 bp    0.00 %
         R1/LOA/Jockey       0            0 bp    0.00 %
         R2/R4/NeSL          0            0 bp    0.00 %
         RTE/Bov-B           0            0 bp    0.00 %
         L1/CIN4             0            0 bp    0.00 %
       LTR elements:         0            0 bp    0.00 %
         BEL/Pao             0            0 bp    0.00 %
         Ty1/Copia           0            0 bp    0.00 %
         Gypsy/DIRS1         0            0 bp    0.00 %
           Retroviral        0            0 bp    0.00 %
    
    DNA transposons       3538      1564942 bp    0.23 %
       hobo-Activator        0            0 bp    0.00 %
       Tc1-IS630-Pogo        0            0 bp    0.00 %
       En-Spm                0            0 bp    0.00 %
       MuDR-IS905            0            0 bp    0.00 %
       PiggyBac              0            0 bp    0.00 %
       Tourist/Harbinger     0            0 bp    0.00 %
       Other (Mirage,        0            0 bp    0.00 %
        P-element, Transib)
    
    Rolling-circles          0            0 bp    0.00 %
    
    Unclassified:        65151     23982146 bp    3.50 %
    
    Total interspersed repeats:    34499156 bp    5.04 %
    
    
    Small RNA:           43353      8992879 bp    1.31 %
    
    Satellites:              1          222 bp    0.00 %
    Simple repeats:     232627     10544162 bp    1.54 %
    Low complexity:      29762      1561018 bp    0.23 %
    ==================================================
    
    * most repeats fragmented by insertions or deletions
      have been counted as one element
      Runs of >=20 X/Ns in query were excluded in % calcs
    
    
    The query species was assumed to be crassostrea virginica
    RepeatMasker Combined Database: Dfam_Consensus-20170127, RepBase-20170127
            
    run with rmblastn version 2.6.0+
    
    ```
