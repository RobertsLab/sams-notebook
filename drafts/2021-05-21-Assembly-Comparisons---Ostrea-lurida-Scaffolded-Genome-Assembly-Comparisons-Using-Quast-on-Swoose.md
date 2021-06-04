---
layout: post
title: Assembly Comparisons - Ostrea lurida Scaffolded Genome Assembly Comparisons Using Quast on Swoose
date: '2021-05-21 09:49'
tags: 
  - quast
  - swoose
  - Ostrea lurida
  - Olympia oyster
  - genome assembly
categories: 
  - Olympia Oyster Genome Assemlby
---


```shell
python \
/home/sam/programs/quast-5.0.2/quast.py \
--threads=20 \
--min-contig=100 \
--labels=redundans_sb_01,redundans_sb_02,redundans_sjw_01,redundans_sjw_02,redundans_sjw_03,soap_bgi_01,pbjelly_sjw_01 \
/mnt/owl/scaphapoda/Sean/Oly_Redundans_Output/scaffolds.reduced.fa \
/mnt/owl/scaphapoda/Sean/Oly_Redundans_Output_Try_2/scaffolds.reduced.fa \
/mnt/owl/Athaliana/20171005_redundans/scaffolds.reduced.fa \
/mnt/owl/Athaliana/20171004_redundans/scaffolds.reduced.fa \
/mnt/owl/Athaliana/20171024_docker_oly_redundans_01/scaffolds.reduced.fa \
/mnt/owl/O_lurida_genome_assemblies_BGI/20161201/cdts-hk.genomics.cn/Ostrea_lurida/Ostrea_lurida.fa \
/mnt/owl/Athaliana/20171130_oly_pbjelly/jelly.out.fasta
```

---

#### RESULTS

Output folder:

- []()

