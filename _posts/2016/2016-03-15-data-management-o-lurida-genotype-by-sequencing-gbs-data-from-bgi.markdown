---
author: kubu4
comments: true
date: 2016-03-15 00:24:26+00:00
layout: post
slug: data-management-o-lurida-genotype-by-sequencing-gbs-data-from-bgi
title: Data Management - O. lurida genotype-by-sequencing (GBS) data from BGI
wordpress_id: 2038
author:
  - kubu4
categories:
  - Genotype-by-sequencing at BGI
tags:
  - BGI
  - GBS
  - genotype-by-sequencing
  - ipython notebook
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
---

We received a hard drive from BGI on 20160223 (while I was out on paternity leave) containing the _Ostrea lurida_ GBS data.

Briefly, three sets (i.e. populations) of [Olympia oyster tissue was collected from oysters raised in Oyster Bay](https://robertslab.github.io/sams-notebook/2015/11/30/sample-submission-oly-oyster-bay-tissues-for-gbs.html) and were sent to BGI for DNA extraction and GBS. A total of 23 individuals from each of the following three populations were sequenced (a grand total of 96 samples):




    
  * 1HL - (Hood Canal, Long Spit)

    
  * 1NF - (North Sound, Fidalgo Bay)

    
  * 1SN - (South Sound, Oyster Bay)



An overview of this project can be viewed on our [GitHub Olympia oyster wiki](https://github.com/RobertsLab/project-olympia.oyster-genomic/wiki/Genotype-by-sequencing-November-2015).

Data was copied from the HDD to the following location on Owl (our server): [https://owl.fish.washington.edu/nightingales/O_lurida/20160223_gbs/](http://owl.fish.washington.edu/nightingales/O_lurida/20160223_gbs/)

The data was generated from paired-end Illumina sequencing, so there are two FASTQ files for each individual.

The files were analyzed to create a MD5 checksum, perform read counts, and create a [readme (markdown format) file](https://owl.fish.washington.edu/nightingales/O_lurida/20160223_gbs/readme.md). This was performed in a Jupyter/iPython notebook (see below).

IMPORTANT NOTE: The directory where this data is housed was renamed AFTER the Jupyter notebook was run. As such, the directory listed above will not be seen in the Jupyter notebook.

Jupyter notebook file: [20160314_Olurida_GBS_data_management.ipynb](https://eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160314_Olurida_GBS_data_management.ipynb)

Notebook Viewer: [20160314_Olurida_GBS_data_management.ipynb](https://nbviewer.jupyter.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160314_Olurida_GBS_data_management.ipynb)

<iframe src="https://nbviewer.jupyter.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160314_Olurida_GBS_data_management.ipynb" width="100%" height="2000" scrolling="yes"></iframe>
