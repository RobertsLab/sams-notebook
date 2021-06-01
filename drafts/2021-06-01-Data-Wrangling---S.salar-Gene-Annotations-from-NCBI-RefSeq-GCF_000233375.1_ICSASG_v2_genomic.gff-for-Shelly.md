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

- []()

