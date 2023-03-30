---
layout: post
title: Data Wrangling - Append Gene Ontology Aspect to P.generosa Primary Annotation File
date: '2023-03-29 14:15'
tags: 
  - R
  - Panopea generosa
  - Pacific geoduck
categories: 
  - Miscellaneous
---
[Steven tasked me with updating our _P.generosa_ genome annotation file](https://github.com/RobertsLab/resources/issues/1602) (GitHub Issue) a while back and I finally managed to get it all figured out. Although I wanted to perform most of this using the [GSEAbase package](https://bioconductor.org/packages/release/bioc/manuals/GSEABase/man/GSEABase.pdf) (PDF), as this package is geared towards storage/retrieval of gene set data, I eventually decided to abondon this approach due to the time it was taking and my lack of familiarity/understanding of how to manipulate objects in R. Despite that, `GSEAbase` was still utilized for its very simple use for identifying GOlims (IDs and Terms).

I also struggled with the UniProt API. They updated the API since I had [previously created the initial annotation file on 20220419](https://robertslab.github.io/sams-notebook/2022/04/19/Data-Wrangling-Create-Primary-P.generosa-Genome-Annotation-File.html) and the update/change to the API rendered the previous API usage inoperable! I tried for a bit to get the new API figured out, but evenutally said "F it!" and used the data I had previously downloaded from UniProt (which, when I started, I didn't actually realize I had kept).

_Then_, after all this, I decided to integrate the entire thing into an R Project. This kept things a bit more cohesive, as it didn't need to bounc between a Jupyter Notebook and then into R. 

Produced a tab-delimited file which added columns grouping GO IDs by Biological Process (BP), Cellular Component (CC), and Molecular Function (MF). Also added a column grouping BP GOslims and corresponding BP GOslim terms for each gene.

See [Results section below](#results) for file and layout.

---

#### RESULTS

Output folder:

- [20230328-pgen-gene_annotation-update](https://github.com/RobertsLab/code/tree/master/r_projects/sam/20230328-pgen-gene_annotation-update) (GiHub; R Project)

  #### Annotation file

  - [20230329-pgen-annotations-SwissProt-GO-BP_GOslim.tab](https://github.com/RobertsLab/code/raw/master/r_projects/sam/20230328-pgen-gene_annotation-update/outputs/02-goslim-mapping/20230329-pgen-annotations-SwissProt-GO-BP_GOslim.tab) (7.8MB; tab-delimited)

  Table layout:

gene | accessions | gene_id | gene_name | gene_description | alt_gene_description | all_GO_ids | BP_GO_ids | CC_GO_ids | MF_GO_ids | GOslim | Term
-- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | --

