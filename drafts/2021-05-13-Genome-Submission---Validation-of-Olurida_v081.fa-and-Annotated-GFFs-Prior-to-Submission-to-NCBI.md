---
layout: post
title: Genome Submission - Validation of Olurida_v081.fa and Annotated GFFs Prior to Submission to NCBI
date: '2021-05-13 13:34'
tags: 
  - NCBI
  - Ostrea lurida
  - Olympia oyster
  - jupyter notebook
categories: 
  - Olympia Oyster Genome Assembly
---
[Per this GitHub Issue](https://github.com/RobertsLab/resources/issues/1159), Steven has asked to get our [_Ostrea lurida_ (Olympia oyster)](http://en.wikipedia.org/wiki/Pacific_oyster) genome assembly (`Olurida_v081.fa`) submitted to NCBI with annotations. The first step in the submission process is to use the NCBI `table2asn_GFF` software to validate the FastA assembly, as well as the GFF annotations file. Once the software has been run, it will point out any errors which need to be corrected prior to submission.

The validation was run on my local computer in the following Jupyter Notebook:


Jupyter Notebook (GitHub):

- [20210513_olur_NCBI_genome-submission-prep.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20210513_olur_NCBI_genome-submission-prep.ipynb)

Jupyter Notebook (NBviewer):

- [20210513_olur_NCBI_genome-submission-prep.ipynb](https://nbviewer.jupyter.org/github/RobertsLab/code/blob/master/notebooks/sam/20210513_olur_NCBI_genome-submission-prep.ipynb)


<iframe src="https://nbviewer.jupyter.org/github/RobertsLab/code/blob/master/notebooks/sam/20210513_olur_NCBI_genome-submission-prep.ipynb" width="100%" height="2000" scrolling="yes"></iframe>


---

#### RESULTS

Output folder:

- []()

