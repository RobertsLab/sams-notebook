---
author: kubu4
comments: true
date: 2018-07-03 22:44:34+00:00
layout: post
slug: transposable-element-mapping-olympia-oyster-genome-assembly-olurida_v081-using-repeatmasker-4-07
title: Transposable Element Mapping – Olympia Oyster Genome Assembly, Olurida_v081,
  using RepeatMasker 4.07
wordpress_id: 3412
author:
  - kubu4
categories:
  - Miscellaneous
tags:
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
  - RepeatMasker
  - roadrunner
  - TE
  - transposable elements
---

[I previously performed this analysis](https://robertslab.github.io/sams-notebook/2018/05/23/transposable-element-mapping-olympia-oyster-genome-assembly-using-repeatmasker-4-07.html) using a different version of our _Ostrea lurida_ genome assembly. [Steven asked that I repeat the analysis with a modified version of the genome assembly (Olurida_v081)](https://github.com/RobertsLab/resources/issues/265#issuecomment-401055771) - only has contigs >1000bp in length.

Genome used: [Olurida_v081](https://github.com/RobertsLab/resources/wiki/Genomic-Resources#genome-1)

I ran RepeatMasker (v4.07) with RepBase-20170127 and RMBlast 2.6.0 four times:





  1. Default settings (i.e. no species select - will use human genome).



  2. Species = _Crassostrea gigas_ (Pacific oyster)



  3. Species = _Crassostrea virginica_ (Eastern oyster)



  4. Species = _Ostrea lurida_ (Olympia oyster)






The idea was to get a sense of how the analyses would differ with species specifications. However, it's likely that the only species setting that will make any difference will be Run #2 (_Crassostrea gigas_).

The reason I say this is that RepeatMasker has a built in tool to query which species are available in the RepBase database (e.g.):


    
    <code>RepeatMasker-4.0.7/util/queryRepeatDatabase.pl -species "crassostrea virginica" -stat</code>



Here's a very brief overview of what that yields:





  * _Crassotrea gigas_: 792 specific repeats



  * _Crassostrea virginica_: 4 _Crassostrea virginica_ specific repeats



  * _Ostrea lurida_: 0 _Ostrea lurida_ specific repeats






All runs were performed on roadrunner.

All commands were documented in a Jupyter Notebook (GitHub):





  * [20180702_roadrunner_oly_TEs_repeatmasker.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20180702_roadrunner_oly_TEs_repeatmasker.ipynb)



_NOTE: RepeatMasker writes the desired output files (*.out, *.cat.gz, and *.gff) to the same directory that the genome is located in! If you conduct multiple runs with the same genome in the same directory, it will overwrite those files, as they are named using the genome assembly filename._



* * *





##### RESULTS:





###### RUN 1 (default settings - human genome)



Output folder:





  * [20180702_oly_repeatmasker_defaults](https://owl.fish.washington.edu/Athaliana/20180702_oly_repeatmasker_defaults)



Summary table (text):



  * [Olurida_v081.fa.tbl](https://owl.fish.washington.edu/Athaliana/20180702_oly_repeatmasker_defaults/Olurida_v081.fa.tbl)



Output table (GFF):



  * [Olurida_v081.fa.out.gff](https://owl.fish.washington.edu/Athaliana/20180702_oly_repeatmasker_defaults/Olurida_v081.fa.out.gff)





##### SUMMARY TABLE




    
    <code>
    ==================================================
    file name: Olurida_v081.fa          
    sequences:        159429
    total length: 1140787867 bp  (1077373535 bp excl N/X-runs)
    GC level:         36.58 %
    bases masked:   17954347 bp ( 1.67 %)
    ==================================================
                   number of      length   percentage
                   elements*    occupied  of sequence
    --------------------------------------------------
    SINEs:            16599       978030 bp    0.09 %
          ALUs            1          292 bp    0.00 %
          MIRs          937        72873 bp    0.01 %
    
    LINEs:             3279       752631 bp    0.07 %
          LINE1         172        10882 bp    0.00 %
          LINE2         646        67827 bp    0.01 %
          L3/CR1        659        60327 bp    0.01 %
    
    LTR elements:       569       127808 bp    0.01 %
          ERVL           32         1949 bp    0.00 %
          ERVL-MaLRs     10          490 bp    0.00 %
          ERV_classI    165        17699 bp    0.00 %
          ERV_classII    26         1590 bp    0.00 %
    
    DNA elements:      1911       161957 bp    0.02 %
         hAT-Charlie     74         4216 bp    0.00 %
         TcMar-Tigger   584        24985 bp    0.00 %
    
    Unclassified:        78         9834 bp    0.00 %
    
    Total interspersed repeats:  2030260 bp    0.19 %
    
    
    Small RNA:         5592       409456 bp    0.04 %
    
    Satellites:         117        21278 bp    0.00 %
    Simple repeats:  270784     12935570 bp    1.20 %
    Low complexity:   42130      2568284 bp    0.24 %
    ==================================================
    
    * most repeats fragmented by insertions or deletions
      have been counted as one element
      Runs of >=20 X/Ns in query were excluded in % calcs
    
    
    The query species was assumed to be homo sapiens  
    RepeatMasker Combined Database: Dfam_Consensus-20170127, RepBase-20170127
            
    run with rmblastn version 2.6.0+
    </code>





* * *





###### RUN 2 (species - _Crassostrea gigas_)



Output folder:





  * [20180702_oly_repeatmasker_Cgigas](https://owl.fish.washington.edu/Athaliana/20180702_oly_repeatmasker_Cgigas)



Summary table (text):



  * [Olurida_v081.fa.tbl](https://owl.fish.washington.edu/Athaliana/20180702_oly_repeatmasker_Cgigas/Olurida_v081.fa.tbl)



Output table (GFF):



  * [Olurida_v081.fa.out.gff](https://owl.fish.washington.edu/Athaliana/20180702_oly_repeatmasker_Cgigas/Olurida_v081.fa.out.gff)





##### SUMMARY TABLE




    
    <code>
    file name: Olurida_v081.fa          
    sequences:        159429
    total length: 1140787867 bp  (1077373535 bp excl N/X-runs)
    GC level:         36.58 %
    bases masked:  152816516 bp ( 14.18 %)
    ==================================================
                   number of      length   percentage
                   elements*    occupied  of sequence
    --------------------------------------------------
    Retroelements       193250     67253771 bp    6.24 %
       SINEs:             2087       284274 bp    0.03 %
       Penelope         158576     56080082 bp    5.21 %
       LINEs:           179430     61300904 bp    5.69 %
        CRE/SLACS            0            0 bp    0.00 %
         L2/CR1/Rex        675       348273 bp    0.03 %
         R1/LOA/Jockey       0            0 bp    0.00 %
         R2/R4/NeSL          7        10781 bp    0.00 %
         RTE/Bov-B        7051      1827344 bp    0.17 %
         L1/CIN4             0            0 bp    0.00 %
       LTR elements:     11733      5668593 bp    0.53 %
         BEL/Pao          1517       871288 bp    0.08 %
         Ty1/Copia          78        72481 bp    0.01 %
         Gypsy/DIRS1      9151      4445789 bp    0.41 %
           Retroviral        0            0 bp    0.00 %
    
    DNA transposons     233691     33727339 bp    3.13 %
       hobo-Activator    17578      1886743 bp    0.18 %
       Tc1-IS630-Pogo    39184      6403235 bp    0.59 %
       En-Spm                0            0 bp    0.00 %
       MuDR-IS905            0            0 bp    0.00 %
       PiggyBac           7261      1003937 bp    0.09 %
       Tourist/Harbinger  8635       823434 bp    0.08 %
       Other (Mirage,        0            0 bp    0.00 %
        P-element, Transib)
    
    Rolling-circles          0            0 bp    0.00 %
    
    Unclassified:       157855     36675484 bp    3.40 %
    
    Total interspersed repeats:   137656594 bp   12.78 %
    
    
    Small RNA:             222        72690 bp    0.01 %
    
    Satellites:           6260      1238331 bp    0.11 %
    Simple repeats:     241081     11662466 bp    1.08 %
    Low complexity:      38915      2347827 bp    0.22 %
    ==================================================
    
    * most repeats fragmented by insertions or deletions
      have been counted as one element
      Runs of >=20 X/Ns in query were excluded in % calcs
    
    
    The query species was assumed to be crassostrea gigas
    RepeatMasker Combined Database: Dfam_Consensus-20170127, RepBase-20170127
            
    run with rmblastn version 2.6.0+
    </code>





* * *





###### RUN 3 (species - _Crassostrea virginica_)



Output folder:





  * [20180702_oly_repeatmasker_Cvirginica](https://owl.fish.washington.edu/Athaliana/20180702_oly_repeatmasker_Cvirginica)



Summary table (text):



  * [Olurida_v081.fa.tbl](https://owl.fish.washington.edu/Athaliana/20180702_oly_repeatmasker_Cvirginica/Olurida_v081.fa.tbl)



Output table (GFF):



  * [Olurida_v081.fa.out.gff](https://owl.fish.washington.edu/Athaliana/20180702_oly_repeatmasker_Cvirginica/Olurida_v081.fa.out.gff)





##### SUMMARY TABLE




    
    <code>
    file name: Olurida_v081.fa          
    sequences:        159429
    total length: 1140787867 bp  (1077373535 bp excl N/X-runs)
    GC level:         36.58 %
    bases masked:   36996910 bp ( 3.43 %)
    ==================================================
                   number of      length   percentage
                   elements*    occupied  of sequence
    --------------------------------------------------
    Retroelements        59806      9886111 bp    0.92 %
       SINEs:            59806      9886111 bp    0.92 %
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
    
    DNA transposons       8720      2230426 bp    0.21 %
       hobo-Activator        0            0 bp    0.00 %
       Tc1-IS630-Pogo        0            0 bp    0.00 %
       En-Spm                0            0 bp    0.00 %
       MuDR-IS905            0            0 bp    0.00 %
       PiggyBac              0            0 bp    0.00 %
       Tourist/Harbinger     0            0 bp    0.00 %
       Other (Mirage,        0            0 bp    0.00 %
        P-element, Transib)
    
    Rolling-circles          0            0 bp    0.00 %
    
    Unclassified:        47005      9434652 bp    0.88 %
    
    Total interspersed repeats:    21551189 bp    2.00 %
    
    
    Small RNA:           60030      9959172 bp    0.92 %
    
    Satellites:              8         5100 bp    0.00 %
    Simple repeats:     259134     12795379 bp    1.19 %
    Low complexity:      42184      2581162 bp    0.24 %
    ==================================================
    
    * most repeats fragmented by insertions or deletions
      have been counted as one element
      Runs of >=20 X/Ns in query were excluded in % calcs
    
    
    The query species was assumed to be crassostrea virginica
    RepeatMasker Combined Database: Dfam_Consensus-20170127, RepBase-20170127
            
    run with rmblastn version 2.6.0+
    </code>





* * *





###### RUN 4 (species - _Ostrea lurida_)



Output folder:





  * [20180702_oly_repeatmasker_Olurida/](https://owl.fish.washington.edu/Athaliana/20180702_oly_repeatmasker_Olurida/)



Summary table (text):



  * [Olurida_v081.fa.tbl](https://owl.fish.washington.edu/Athaliana/20180702_oly_repeatmasker_Olurida/Olurida_v081.fa.tbl)



Output table (GFF):



  * [Olurida_v081.fa.out.gff](https://owl.fish.washington.edu/Athaliana/20180702_oly_repeatmasker_Olurida/Olurida_v081.fa.out.gff)





##### SUMMARY TABLE




    
    <code>
    ==================================================
    file name: Olurida_v081.fa          
    sequences:        159429
    total length: 1140787867 bp  (1077373535 bp excl N/X-runs)
    GC level:         36.58 %
    bases masked:   15918797 bp ( 1.48 %)
    ==================================================
                   number of      length   percentage
                   elements*    occupied  of sequence
    --------------------------------------------------
    Retroelements            0            0 bp    0.00 %
       SINEs:                0            0 bp    0.00 %
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
    
    DNA transposons          0            0 bp    0.00 %
       hobo-Activator        0            0 bp    0.00 %
       Tc1-IS630-Pogo        0            0 bp    0.00 %
       En-Spm                0            0 bp    0.00 %
       MuDR-IS905            0            0 bp    0.00 %
       PiggyBac              0            0 bp    0.00 %
       Tourist/Harbinger     0            0 bp    0.00 %
       Other (Mirage,        0            0 bp    0.00 %
        P-element, Transib)
    
    Rolling-circles          0            0 bp    0.00 %
    
    Unclassified:            3          189 bp    0.00 %
    
    Total interspersed repeats:         189 bp    0.00 %
    
    
    Small RNA:             224        73061 bp    0.01 %
    
    Satellites:              8         5100 bp    0.00 %
    Simple repeats:     273098     13256460 bp    1.23 %
    Low complexity:      42443      2592212 bp    0.24 %
    ==================================================
    
    * most repeats fragmented by insertions or deletions
      have been counted as one element
      Runs of >=20 X/Ns in query were excluded in % calcs
    
    
    The query species was assumed to be ostrea lurida 
    RepeatMasker Combined Database: Dfam_Consensus-20170127, RepBase-20170127
            
    run with rmblastn version 2.6.0+
    
    
    </code>





* * *
