---
layout: post
title: Project Summary - C.virginica CEABiGR - Female vs. Male Gonad Exposed to OA
date: '2022-04-25 12:14'
tags: 
  - project summary
  - Crassostrea virginica
  - CEABIGR
  - OA
  - gonad
  - Eastern oyster
categories: 
  - Project Summary
---
This will be a “dynamic” notebook entry, whereby I will update this post continually as I process new samples, analyze new data, etc for this project. The hope is to make it easier to find all the work I’ve done for this without having to search my notebook to find individual notebook entries.

---

### Repositories

- [CEABiGR GitHub Repo](https://github.com/sr320/ceabigr): Workshop for this project.

- [2018_L18-adult-methylation GitHub Repo](https://github.com/epigeneticstoocean/2018_L18-adult-methylation): Original repo for this project, in conjunction with [Katie Lotterhos' Lab](https://cos.northeastern.edu/people/katie-lotterhos/). NOTE: This might be a private repo.

- [Adult sequencing metadata GitHub Repo](https://github.com/RobertsLab/project-oyster-comparative-omics/tree/master/metadata)

- [2018_L18_OAExp_Cvirginica_DNAm GitHub Repo](https://github.com/epigeneticstoocean/2018_L18_OAExp_Cvirginica_DNAm/blob/main/data/L18_larvae_meta.csv). NOTE: This might be a private repo.

- [Larval/zygote metdata GitHub Repo](https://github.com/epigeneticstoocean/2018_L18_OAExp_Cvirginica_DNAm/blob/main/data/L18_larvae_meta.csv). NOTE: This might be a private repo.
---

### Notebooks

#### Data Receipt

- [Data-Received-Yaamini's-C.virginica-WGBS-and-RNAseq-Data-from-ZymoResearch](https://robertslab.github.io/sams-notebook/2021/05/28/Data-Received-Yaamini's-C.virginica-WGBS-and-RNAseq-Data-from-ZymoResearch.html)

- Received larval/zygote trimming data from Alan Downey-Wall in Jan. 2022. No notebook entry documenting receipt.

  - Noted when initially transferred data from Lotterhos Lab (via Alan Downey-Wall) - missing some second run FastQ files (these have not been ):

    - `CF01-CM01-Zygote_R1_001.fastq.gz`
    - `CF08-CM04-Larvae_R2_001.fastq.gz`
    - `EF03-EM03-Zygote_R2_001.fastq.gz`  

  - Note from Alan Downey-Wall regarding sample naming:

    >  The Sample.ID​ contains the mothersID-fathersID-stage (zygote or 4 day larvae) for each offspring pool.

#### Trimming

- [Trimming-Additional-20bp-from-C.virginica-Gonad-RNAseq-with-fastp-on-Mox](https://robertslab.github.io/sams-notebook/2022/02/24/Trimming-Additional-20bp-from-C.virginica-Gonad-RNAseq-with-fastp-on-Mox.html)

- [Trimming-C.virginica-Gonad-RNAseq-with-FastP-on-Mox](https://robertslab.github.io/sams-notebook/2021/07/14/Trimming-C.virginica-Gonad-RNAseq-with-FastP-on-Mox.html)

- [FastQ-Trimming-and-QC-C.virginica-Larval-BS-seq-Data-from-Lotterhos-Lab-and-Part-of-CEABIGR-Project-Using-fastp-on-Mox](https://robertslab.github.io/sams-notebook/2022/08/29/FastQ-Trimming-and-QC-C.virginica-Larval-BS-seq-Data-from-Lotterhos-Lab-and-Part-of-CEABIGR-Project-Using-fastp-on-Mox.html)

#### Transcript Identification and Alignments
- [Transcript-Identification-and-Alignments-C.virginica-RNAseq-with-NCBI-Genome-GCF_002022765.2-Using-Hisat2-and-Stringtie-on-Mox](https://robertslab.github.io/sams-notebook/2022/02/25/Transcript-Identification-and-Alignments-C.virginica-RNAseq-with-NCBI-Genome-GCF_002022765.2-Using-Hisat2-and-Stringtie-on-Mox.html)

#### Differential Gene and Transcript Expression

- [Differential-Transcript-Expression-C.virginica-Gonad-RNAseq-Using-Ballgown](https://robertslab.github.io/sams-notebook/2021/10/21/Differential-Transcript-Expression-C.virginica-Gonad-RNAseq-Using-Ballgown.html)

  - [ballgown_analysis.Rmd](https://github.com/epigeneticstoocean/2018_L18-adult-methylation/blob/main/code/ballgown_analysis.Rmd)

- [Data-Wrangling-C.virginica-Gonad-RNAseq-Transcript-Counts-Per-Gene-Per-Sample-Using-Ballgown](https://robertslab.github.io/sams-notebook/2022/01/27/Data-Wrangling-C.virginica-Gonad-RNAseq-Transcript-Counts-Per-Gene-Per-Sample-Using-Ballgown.html)

  - [transcript-counts.Rmd](https://github.com/epigeneticstoocean/2018_L18-adult-methylation/blob/main/code/transcript-counts.Rmd)

#### Predominant Isoform Identification

- [Data-Wrangling-Identify-C.virginica-Genes-with-Different-Predominant-Isoforms-for-CEABIGR.html](https://robertslab.github.io/sams-notebook/2022/09/20/Data-Wrangling-Identify-C.virginica-Genes-with-Different-Predominant-Isoforms-for-CEABIGR.html)

  - [42-predominant-isoform.Rmd](https://github.com/sr320/ceabigr/blob/main/code/42-predominant-isoform.Rmd) (GitHub)

  - [20220920-cvir-ceabigr-predominant_isoform-female_male.ipynb](https://nbviewer.org/github/sr320/ceabigr/blob/main/code/20220920-cvir-ceabigr-predominant_isoform-female_male.ipynb) (NBviewer)