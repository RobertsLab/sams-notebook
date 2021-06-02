---
layout: post
title: Data Wrangling - S.salar Gene Annotations from NCBI RefSeq GCF_000233375.1_ICSASG_v2_genomic.gff for Shelly
date: '2021-06-01 11:10'
tags: 
  - jupyter notebook
  - gff
  - Salmo salar
  -  Atlantic salmon
categories: 
  - Miscellaneous
---
Shelly [posted a GitHub Issue](https://github.com/RobertsLab/resources/issues/1220) asking if I could create a file of _S.salar_ genes with their UniProt annotations (e.g. gene name, UniProt accession, GO terms).

Here's the approach I took:

1. Use [GFFutils](https://gffutils.readthedocs.io/en/v0.12.0/index.html) to pull out only gene features, along with:

- chromosome name

- start position

- end position

- Dbxref attribute (which, in this case, is the NCBI gene ID)

2. Submit the NCBI gene IDs to [UniProt]() to map the NCBI gene IDs to UniProt accessions. Accomplished using the [Perl batch submission script provided by UniProt](https://www.uniprot.org/help/api_batch_retrieval).

3. Parse out the stuff we were interested in.

4. Join it all together!

All of this is documented in the Jupyter Notebook below:

Jupyter Notebook (GitHub):

- [20210601_ssal_gff-annotations.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20210601_ssal_gff-annotations.ipynb)

Jupyter Notebook (NBviewer):

- [20210601_ssal_gff-annotations.ipynb](https://nbviewer.jupyter.org/github/RobertsLab/code/blob/master/notebooks/sam/20210601_ssal_gff-annotations.ipynb)

---

<iframe src="https://nbviewer.jupyter.org/github/RobertsLab/code/blob/master/notebooks/sam/20210601_ssal_gff-annotations.ipynb" width="100%" height="1000" scrolling="yes"></iframe>



---

#### RESULTS

Output folder:

Parsing of the UniProt Perl batch retrieval results file (~7.2M lines!) took ~6.5hrs!

- [20210601_ssal_gff-annotations/](https://gannet.fish.washington.edu/Atumefaciens/20210601_ssal_gff-annotations/)

  - Final tab-delimited file (10MB):

    - [20210601_ssal_chrom-gene_id_start-end-acc-gene-gene_description-go_ids.tab](https://gannet.fish.washington.edu/Atumefaciens/20210601_ssal_gff-annotations/20210601_ssal_chrom-gene_id_start-end-acc-gene-gene_description-go_ids.tab)

    It's organized in the following fashion:

    | chromosome | NCBI gene ID | start | end | UniProt accession | gene abbreviation/name | gene description | GO IDs |
    |---|----|----|----|---|----|----|----|


  - Other files:

    - [20210601_ssal_accession-gene_id-gene-gene_description-go_ids.csv](https://gannet.fish.washington.edu/Atumefaciens/20210601_ssal_gff-annotations/20210601_ssal_accession-gene_id-gene-gene_description-go_ids.csv) (8.0M)

      - MD5: `e7d970782d7f531967dbfce01e5df549`

    - [20210601_ssal_chrom-start-end-Dbxref.csv](https://gannet.fish.washington.edu/Atumefaciens/20210601_ssal_gff-annotations/20210601_ssal_chrom-start-end-Dbxref.csv) (2.9M)

      - MD5: `f4182e5129978328b0e9ae2b07d0bbf7`

    - [20210601_ssal_gene-list.txt](https://gannet.fish.washington.edu/Atumefaciens/20210601_ssal_gff-annotations/20210601_ssal_gene-list.txt) (772K)

      - MD5: `0d330da91260189090ba2fac1ca0340f`

    - [20210601_ssal_uniprot_batch_results.txt](https://gannet.fish.washington.edu/Atumefaciens/20210601_ssal_gff-annotations/20210601_ssal_uniprot_batch_results.txt) (350M)

      - MD5: `81f63345d2f2cfbabdc8d60c3326ba66`

    - [checksums.md5](https://gannet.fish.washington.edu/Atumefaciens/20210601_ssal_gff-annotations/checksums.md5) (4.0K)
