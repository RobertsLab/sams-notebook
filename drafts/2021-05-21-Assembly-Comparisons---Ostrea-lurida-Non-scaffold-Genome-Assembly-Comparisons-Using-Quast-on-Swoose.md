---
layout: post
title: Assembly Comparisons - Ostrea lurida Non-scaffold Genome Assembly Comparisons Using Quast on Swoose
date: '2021-05-21 07:42'
tags: 
  - swoose
  - quast
  - Ostrea lurida
  - Olympia oyster
categories: 
  - Olympia Oyster Genome Assembly
---
After [generating a new _Ostrea lurida_ genome assembly (v090) on 20210520](https://robertslab.github.io/sams-notebook/2021/05/20/Genome-Assembly-Olurida_v090-with-BGI-Illumina-and-PacBio-Hybrid-Using-Wengan-on-Mox.html), I decided to compare with our previous genome assemblies. Here, I compared v090 with all of our previous scaffolded assemblies using [Quast](http://quast.sourceforge.net/quast). Here is a table (GitHub) which describes all of our existing assemblies (i.e. assembly name, assembly process, etc):

- [https://github.com/RobertsLab/project-olympia.oyster-genomic/wiki/Genome-Assemblies](https://github.com/RobertsLab/project-olympia.oyster-genomic/wiki/Genome-Assemblies)

NOTE: Assembly `pbjelly_sjw_01` is the source of our current "canonical" assembly: `Olurida_v081.fa`

This was run locally on my computer with the following command:


```shell
python \
/home/sam/programs/quast-5.0.2/quast.py \
--threads=20 \
--min-contig=100 \
--labels=Olurida_v090,canu_sb_01,canu_sjw_01,platanus_sb_01,platanus_sb_02,racon_sjw_01 \
~/data/O_lurida/genomes/Olur_v090.SPolished.asm.wengan.fasta \
/mnt/owl/scaphapoda/Sean/Oly_Canu_Output/oly_pacbio_.contigs.fasta \
/mnt/owl/Athaliana/20171018_oly_pacbio_canu/20171018_oly_pacbio.contigs.fasta \
/mnt/owl/scaphapoda/Sean/Oly_Illumina_Platanus_Assembly/Oly_Out__contig.fa \
/mnt/owl/scaphapoda/Sean/Oly_Platanus_Assembly_Kmer-22/Oly_Out__contig.fa \
/mnt/owl/Athaliana/201709_oly_pacbio_assembly_minimap_asm_racon/20170918_oly_pacbio_racon1_consensus.fasta
```

---

#### RESULTS

Output folder:

- [20210521_olur_quast_non-scaffold_assembly-comparisons/](https://gannet.fish.washington.edu/Atumefaciens/20210521_olur_quast_non-scaffold_assembly-comparisons/)

  - #### Quast Report (HTML; open in browser; interactive)

    - [20210521_olur_quast_non-scaffold_assembly-comparisons/quast_results/results_2021_05_21_07_46_10/report.html](https://gannet.fish.washington.edu/Atumefaciens/20210521_olur_quast_non-scaffold_assembly-comparisons/quast_results/results_2021_05_21_07_46_10/report.html)


![QUAST comparison of non-scaffold Ostrea lurida assemblies](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210521_olur_quast_non-scaffold_assembly-comparisons_screencap.png?raw=true)

The results here are interesting. The `Olurida_v090` assembly which I [generated on 20210520](https://robertslab.github.io/sams-notebook/2021/05/20/Genome-Assembly-Olurida_v090-with-BGI-Illumina-and-PacBio-Hybrid-Using-Wengan-on-Mox.html) Looks pretty good. However, despite having ~44M fewer bases, the `canu_sjw_01` assembly ([from 20171018](https://robertslab.github.io/sams-notebook/2017/10/18/genome-assembly-olympia-oyster-pacbio-canu-v1-6.html)) could be considered "better", as it has ~4x the number of contigs >50,000bp than the `Olurida_v090`. The `canu_sjw_01` assembly also has the larger of the two assemblies' largest contigs. Also, surprisingly, the `canu_sjw_01` assembly is _only_ our PacBio sequencing data; it does _not_ include any of the Illumina short reads!

Maybe I'll just go ahead and run both of these through [GenSAS](https://www.gensas.org/)...