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



```shell
python \
> --threads=20 \
> --min-contig=100 \
> --labels=Olurida_v090,canu_sb_01,canu_sjw_01,platanus_sb_01,platanus_sb_02,racon_sjw_01 \
> ~/data/O_lurida/genomes/Olur_v090.SPolished.asm.wengan.fasta \
> /mnt/owl/scaphapoda/Sean/Oly_Canu_Output/oly_pacbio_.contigs.fasta \
> /mnt/owl/Athaliana/20171018_oly_pacbio_canu/20171018_oly_pacbio.contigs.fasta \
> /mnt/owl/scaphapoda/Sean/Oly_Illumina_Platanus_Assembly/Oly_Out__contig.fa \
> /mnt/owl/scaphapoda/Sean/Oly_Platanus_Assembly_Kmer-22/Oly_Out__contig.fa \
> /mnt/owl/Athaliana/201709_oly_pacbio_assembly_minimap_asm_racon/20170918_oly_pacbio_racon1_consensus.fasta
```

---

#### RESULTS

Output folder:

- []()

