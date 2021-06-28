---
layout: post
title: Assembly Assessment - Olurida_v090 Using Quast on Swoose
date: '2021-05-21 07:41'
tags: 
  - swoose
  - quast
  - Olurida_v090
  - Ostrea lurida
  - Olympia oyster
  - assembly
categories: 
  - Olympia Oyster Genome Assembly
---
[After running a new _Ostrea lurida_ assembly yesterday (`Olurida_v090`)](https://robertslab.github.io/sams-notebook/2021/05/20/Genome-Assembly-Olurida_v090-with-BGI-Illumina-and-PacBio-Hybrid-Using-Wengan-on-Mox.html), I evaluated `Olurida_v090` using [Quast](http://quast.sourceforge.net/quast) to produce some stats. This was run on my local computer with the following command:

```shell
python \
/home/sam/programs/quast-5.0.2/quast.py \
--threads=20 \
--min-contig=100 \
--labels Olurida_v090 \
/home/sam/data/O_lurida/genomes/Olur_v090.SPolished.asm.wengan.fasta
```

---

#### RESULTS

Output folder:

- [20210521_olur_quast_Olur-v090-wengan/](https://gannet.fish.washington.edu/Atumefaciens/20210521_olur_quast_Olur-v090-wengan/)

- #### Quast Report (HTML; opens in browser; "interactive")

- [20210521_olur_quast_Olur-v090-wengan/quast_results/results_2021_05_21_06_54_20/report.html](https://gannet.fish.washington.edu/Atumefaciens/20210521_olur_quast_Olur-v090-wengan/quast_results/results_2021_05_21_06_54_20/report.html)


Report text:

```
All statistics are based on contigs of size >= 100 bp, unless otherwise noted (e.g., "# contigs (>= 0 bp)" and "Total length (>= 0 bp)" include all contigs).

Assembly                    Olurida_v090
# contigs (>= 0 bp)         19009       
# contigs (>= 1000 bp)      19009       
# contigs (>= 5000 bp)      17955       
# contigs (>= 10000 bp)     5653        
# contigs (>= 25000 bp)     343         
# contigs (>= 50000 bp)     4           
Total length (>= 0 bp)      177359031   
Total length (>= 1000 bp)   177359031   
Total length (>= 5000 bp)   172575953   
Total length (>= 10000 bp)  84976128    
Total length (>= 25000 bp)  10402122    
Total length (>= 50000 bp)  232116      
# contigs                   19009       
Largest contig              65918       
Total length                177359031   
GC (%)                      36.06       
N50                         9729        
N75                         7149        
L50                         6029        
L75                         11363       
# N's per 100 kbp           0.00  
```

Overall, looks pretty good. Will need to compare to existing assemblies for a better assessment.