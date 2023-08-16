---
layout: post
title: Daily Bits - August 2023
date: '2023-08-01 07:25'
tags: 
  - daily bits
categories: 
  - Daily Bits
---

20230815

- E5 coral sRNA-seq analyses

  - Collapse trimmed R1 FastQs to non-redundant reads with `fastx_collapser` to use for cross-wise BLAST-ing:

    ```bash
    for fastq in *flexbar*_1.fastq.gz \
    do
      filename=${fastq%.*}
      zcat ${fastq} \
      | /home/shared/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64/bin/fastx_collapser \
      -Q30 \
      -o collapsed/${filename}-collapsed.fasta
    done
    ```

---

20230809

- [_P.evermanni_ sRNA analyses](https://github.com/urol-e5/deep-dive/issues/27) (GitHub Issue)

  - NCBI BLASTn against [miRBase](https://www.mirbase.org/download/) and [MirGeneDB](https://www.mirgenedb.org/download), mature and all species, respectively.

    - Use Perl scripts in [miRDeep-P2-pipeline](https://github.com/TF-Chan-Lab/miRDeep-P2_pipeline) (GitHub repo) to convert/condense FastAs to unique sequnces and `T` instead of `U`.

    - Make NCBI BLAST databases from each.

    - Concatenate sRNA-seq FastAs (from [miRTrace](https://github.com/friedlanderlab/mirtrace) - GitHub Repo) for each sample.

    - Run NCBI BLASTn

      ```bash
      for fasta in /home/shared/8TB_HDD_01/sam/data/P_evermanni/sRNAseq/mirtrace.config.output/qc_passed_reads.all.collapsed/*cat.fasta
      do
        filename=${fasta##*/} \
        /home/shared/ncbi-blast-2.11.0+/bin/blastn \
        -db /home/shared/8TB_HDD_01/sam/data/blastdbs/mature_wo_U_uniq.fa \
        -query ${fasta} \
        -out "20230809-peve-miRBase-BLASTn-${filename}.outfmt6" \
        -max_hsps 1 \
        -max_target_seqs 1 \
        -outfmt 6 \
        -num_threads 40
      done
      ```

      ```bash
      for fasta in /home/shared/8TB_HDD_01/sam/data/P_evermanni/sRNAseq/mirtrace.config.output/qc_passed_reads.all.collapsed/*cat.fasta
      do 
        filename=${fasta##*/} \
        /home/shared/ncbi-blast-2.11.0+/bin/blastn \
        -db /home/shared/8TB_HDD_01/sam/data/blastdbs/ALL_wo_U_uniq.fas \
        -query ${fasta} \
        -out "20230809-peve-miRGene-BLASTn-${filename}.outfmt6" \
        -max_hsps 1 \
        -max_target_seqs 1 \
        -outfmt 6 \
        -num_threads 40
      done
      ```

      - NO MATCHES FOR EITHER!

  - Run [mirdeep2](https://github.com/rajewsky-lab/mirdeep2) (GitHub repo- > "About
Discovering known and novel miRNAs from small RNA sequencing data")

    - First, map reads to genome (`*.arf`)

    ```bash
    for fasta in /home/shared/8TB_HDD_01/sam/data/P_evermanni/sRNAseq/mirtrace.config.output/qc_passed_reads.all.collapsed/no_spaces*.fasta\
      do
      filename=${fasta##*/} \
      /home/shared/mirdeep2/bin/mapper.pl ${fasta} \
      -c \
      -p /home/shared/8TB_HDD_01/sam/data/P_evermanni/genomes/Porites_evermanni_v1 \
      -t "20230809-peve-miRNA-mirdeep2-${filename}.arf"
    done
    ```

    - Reformat miRTrace collapsed FastAs to have compatible description lines

      `for fasta in sRNA*20230621_[12].fasta; do sed '/^>/ s/ /_/g' ${fasta} | sed 's/_rnatype.*$//g' > "no_spaces-${fasta}"; done`

    - Run [mirdeep2](https://github.com/rajewsky-lab/mirdeep2) on sequencing reads (was having problems with loop, so ran individually)

      ```bash
      /home/shared/mirdeep2/bin/miRDeep2.pl \
      /home/shared/8TB_HDD_01/sam/data/P_evermanni/sRNAseq/mirtrace.config.output/qc_passed_reads.all.collapsed/no_spaces-sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1.fasta \
      /home/shared/8TB_HDD_01/sam/data/P_evermanni/genomes/Porites_evermanni_v1.fa \
      20230809-peve-miRNA-mirdeep2-no_spaces-sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1.fasta.arf \
      none none none \
      2>20230809-peve-miRNA-mirdeep2-no_spaces-sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1.fasta.log
      ```

      ```bash
      /home/shared/mirdeep2/bin/miRDeep2.pl \
      /home/shared/8TB_HDD_01/sam/data/P_evermanni/sRNAseq/mirtrace.config.output/qc_passed_reads.all.collapsed/no_spaces-sRNA-POR-79-S1-TP2.flexbar_trim.20230621_1.fasta \
      /home/shared/8TB_HDD_01/sam/data/P_evermanni/genomes/Porites_evermanni_v1.fa \
      20230809-peve-miRNA-mirdeep2-no_spaces-sRNA-POR-79-S1-TP2.flexbar_trim.20230621_1.fasta.arf \
      none none none \
      2>20230809-peve-miRNA-mirdeep2-no_spaces-sRNA-POR-79-S1-TP2.flexbar_trim.20230621_1.fasta.log
      ```

      ```bash
      /home/shared/mirdeep2/bin/miRDeep2.pl \
      /home/shared/8TB_HDD_01/sam/data/P_evermanni/sRNAseq/mirtrace.config.output/qc_passed_reads.all.collapsed/no_spaces-sRNA-POR-82-S1-TP2.flexbar_trim.20230621_1.fasta \
      /home/shared/8TB_HDD_01/sam/data/P_evermanni/genomes/Porites_evermanni_v1.fa \
      20230809-peve-miRNA-mirdeep2-no_spaces-sRNA-POR-82-S1-TP2.flexbar_trim.20230621_1.fasta.arf \
      none none none \
      2>20230809-peve-miRNA-mirdeep2-no_spaces-sRNA-POR-82-S1-TP2.flexbar_trim.20230621_1.fasta.log
      ```

---

20230808

- [_P.evermanni_ sRNA analyses](https://github.com/urol-e5/deep-dive/issues/27) (GitHub Issue)

  - [`MirMachine`](https://github.com/sinanugur/MirMachine):

    ```bash
    MirMachine.py \
    --node Metazoa \
    --species 20230808-peve-MirMachine \
    --genome /home/shared/8TB_HDD_01/sam/data/P_evermanni/genomes/Porites_evermanni_v1.fa \
    --cpu 40 \
    --add-all-nodes
    ```

    - 83 loci identified (`grep -c "^[^#]" 20230808-peve-MirMachine.PRE.gff`)

    - 15 unique miRNA families (`grep "^[^#]" 20230808-peve-MirMachine.PRE.gff | awk -F"[\t=;]" '{print $10}'| sort -u | wc -l`)


---

20230804

- In lab.

  - Fresh install of Ubuntu on `swoose`. Ugh... Replaced internal HDD (1TB) with 8TB HDD.

  - Cleaning for lab safety inspection.

  - Lab safety inspection.

  - Tried troubleshooting dual boot situation for Jackie's Linux/Windows computer. Some progress (GRUB menu now shows again), but booting into Windows just hangs at a black screen.

---

20230803

- CEABIGR

  - Worked on transcript annotation by exploring differences in DIAMOND/NCBI BLASTx.

  - Gathered some prelinary sRNA-seq stats for Steven's grant update.

---

20230801

