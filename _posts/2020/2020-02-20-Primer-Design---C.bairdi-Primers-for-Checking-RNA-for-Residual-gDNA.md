---
layout: post
title: Primer Design - C.bairdi Primers for Checking RNA for Residual gDNA
date: '2020-02-20 15:01'
tags:
  - Primer3
  - Tanner crab
  - Chionoecetes bairdi
  - transcriptome
  - DEGs
  - Trinity
  - Trinotate
categories:
  - Tanner Crab RNAseq
---
Getting ready to run some qPCRs and first we need to confirm that our RNA is actually DNA-free. Before we can do that, we need some primers to use, so I decided to semi-arbitrarily select three different gene targets from our [MEGAN6 taxonomic-specific Trinity assembly from 20200122](https://robertslab.github.io/sams-notebook/2020/01/22/Transcriptome-Assembly-C.bairdi-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html).

I used our [recent differential gene expression analysis](https://robertslab.github.io/sams-notebook/2020/02/07/Gene-Expression-C.bairdi-MEGAN6-with-Trinity-and-EdgeR.html) to identify those genes which were highly differentially expressed in infected vs. uninfected samples.

Overall, the process went something like this:

1. Sort [upregulated genes in infected group](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/infected-vs-uninfected/edgeR.2317.dir/salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.infected-UP.subset) by logFC (fold change) to find Trinity transcript IDs of highly expressed genes:

```
awk 'NR>1' salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.infected-UP.subset \
| sort -n -k4,4
```

2. Search for some of the highly expressed Trinity IDs in the [Trinotate annotations](https://gannet.fish.washington.edu/Atumefaciens/20200126_cbai_trinotate_megan/20200126.cbai.trinotate_annotation_report.txt) to find SwissProt IDs:

```
grep "TRINITY_DN6549_c0_g1" \
20200126.cbai.trinotate_annotation_report.txt
```

3. Copy SwissProt ID (if available) and see what it is on the UniProtKB website.

4. If interesting (somewhat), search [Trinity _de novo_ assembly](https://gannet.fish.washington.edu/Atumefaciens/20200122_cbai_trinity_megan_RNAseq/trinity_out_dir/20200122.C_bairdi.megan.Trinity.fasta) for transcript sequence.

5. Use sequence to generate primers on the [Primer3 website](http://bioinfo.ut.ee/primer3-0.4.0/).

---

#### RESULTS


Here are the targets and primers designed and ordered.


#### 40s rRNA S30

```
PRIMER PICKING RESULTS FOR cbai_TRINITY_DN6411_c0_g2_i1

No mispriming library specified
Using 1-based sequence positions
OLIGO            start  len      tm     gc%   any    3' seq
LEFT PRIMER         80   20   59.94   45.00  4.00  0.00 TGCCGGTAAGGTGAAAAATC
RIGHT PRIMER       261   20   59.97   45.00  2.00  2.00 AAATCCGCAACCAATACAGC
SEQUENCE SIZE: 334
INCLUDED REGION SIZE: 334

PRODUCT SIZE: 182, PAIR ANY COMPL: 3.00, PAIR 3' COMPL: 0.00

    1 GTTTTTTCCTTTTTCGTTTTCTACATATATTAACCCCCCTTTATTAAACAATGGGTAAAG


   61 TCCACGGTTCCTTGGCTCGTGCCGGTAAGGTGAAAAATCAGACCCCGAAAGTTGCCAAGA
                         >>>>>>>>>>>>>>>>>>>>                     

  121 TGGAGAAGAAGAAGTCTCTCACGGGCCGCGCCAAGAAACGCATGCAGTACAACCGTCGTT


  181 TCGTGAACATCGTGCGGGCAGGTGGCCCCAAGCGCGGCCCTAATTCCAACCAGAAGTAAA


  241 GGCTGTATTGGTTGCGGATTTTAGGTGTTAACGATGCGCTGGACTTCCTCCTCTATATGA
       <<<<<<<<<<<<<<<<<<<<                                       

  301 GTATCATGGGATGGATGCAACGAACTTGATGGAC
```

---


#### allantoicase

```
	PRIMER PICKING RESULTS FOR cbai_TRINITY_DN13073_c0_g1_i1

No mispriming library specified
Using 1-based sequence positions
OLIGO            start  len      tm     gc%   any    3' seq
LEFT PRIMER         65   20   60.29   50.00  4.00  0.00 CGAGTGTTTCCAAGCCTGTT
RIGHT PRIMER       215   20   60.07   50.00  4.00  0.00 GTGAATACGCCTTCCTTCCA
SEQUENCE SIZE: 237
INCLUDED REGION SIZE: 237

PRODUCT SIZE: 151, PAIR ANY COMPL: 3.00, PAIR 3' COMPL: 1.00

    1 GTAGTATTCTGGAATCGGCGTTTTTTGTTTGTGTAATCCGTGGAAATGGACATATCTCAA


   61 CCCGCGAGTGTTTCCAAGCCTGTTTTTACACGCTTGACCGACCTCGCGAGCGAACTGCTC
          >>>>>>>>>>>>>>>>>>>>                                    

  121 GGCTCGAAGGTGCTTTTTGCCACCGATCAGTGGTTTGCCGAAGCTTCAAATTTACTCAAG


  181 AGTGAAGAGCCGGTATGGAAGGAAGGCGTATTCACCGAACATGGAAAATGGATGGAC
                     <<<<<<<<<<<<<<<<<<<<                      
```

---

#### ubiqutin thioesterase

```
PRIMER PICKING RESULTS FOR cbai_TRINITY_DN6549_c0_g1_i1

No mispriming library specified
Using 1-based sequence positions
OLIGO            start  len      tm     gc%   any    3' seq
LEFT PRIMER        297   20   60.00   45.00  4.00  2.00 CGGTTTGTTTGAACGGCTAT
RIGHT PRIMER       577   20   59.95   50.00  4.00  3.00 GATAAAGCTCGGCATTCTGC
SEQUENCE SIZE: 647
INCLUDED REGION SIZE: 647

PRODUCT SIZE: 281, PAIR ANY COMPL: 3.00, PAIR 3' COMPL: 0.00

    1 TGCGGGAATATCTTTAAATACTATATACTCGGGTAGCGTCTTGGAATGTCATGTGAGGGA


   61 AATTCAGACCCGCACCATGATTATCAGGCATCCCTGAACCAGCAAGATGCGATCCGGCAG


  121 GAAGCGTCCGTCGATCACCCGTTGATGAAGAAGCGCGAGCCCGTAGGGGCATCGCTGAAC


  181 GAGCAGTTCGCGGAGAATAAGAACTTCCTACAGAAGGTCGCTTCAATCGCGGCCAAGTAT


  241 GAGTTCATTCGACGGGCGAGACCGGACGGCAATTGCTTTTACCGCACGTATCTGTTCGGT
                                                              >>>>

  301 TTGTTTGAACGGCTATTGGGCATGTCCCGCGAGGAGCGGGACAAATTTGTCGTGTTTCTC
      >>>>>>>>>>>>>>>>                                            

  361 AAGAAATCACTGGATGATGTGCTTTGCCAAGGGTATGAGCGATTTGCGGTAGAAGAAATG


  421 CACGAAGATATCCTTGAAGAGTTTGAGAAACTCGCTCAGAATGACAATGCAACCGTCGGC


  481 GATATCGAGACGATATTCGACGAGGAAAGGCATTACCATATTTGCTACTTGAGGTGCCTA


  541 GCGTCGGCGTACCTCAAGCAGAATGCCGAGCTTTATCAATCGTTCCTCGAAGGCTATGCG
                       <<<<<<<<<<<<<<<<<<<<                       

  601 ACTATAGCAGAGTTCTGCGCTCATGAAGTGGATCCTATGTGGCGCGG
```
