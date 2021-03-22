---
author: kubu4
comments: true
date: 2016-01-28 00:30:48+00:00
layout: post
slug: data-received-panopea-generosa-genome-sequencing-files-from-bgi
title: Data Received - Panopea generosa genome sequencing files from BGI
wordpress_id: 1992
author:
  - kubu4
categories:
  - Geoduck Genome Sequencing
tags:
  - BGI
  - geoduck
  - ipython notebook
  - jupyter notebook
  - Panopea generosa
---

Downloaded data from the BGI project portal to our server, Owl, using the Synology Download Station. Although the BGI portal is aesthetically nice, it's set up poorly for bulk downloads and took a few tries to download all of the files.

Data integrity was assessed and read counts for each file were generated. The files were moved to their permanent storage location on Owl: https://owl.fish.washington.edu/nightingales/P_generosa/

The [readme.md](https://owl.fish.washington.edu/nightingales/P_generosa/readme.md) file was updated to include project/file information.

The file manipulations were performed in a Jupyter notebook (see below).



Total reads generated for this project: 1,208,635,950

BGI provided us with the raw data files for us to play around with, but they are also currently in the process of performing the genome assembly.



Jupyter Notebook file: [20160126_Olurida_BGI_data_handling.ipynb](https://eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160126_Pgenerosa_BGI_data_handling.ipynb)

Notebook Viewer: [20160126_Olurida_BGI_data_handling.ipynb](https://nbviewer.jupyter.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160126_Pgenerosa_BGI_data_handling.ipynb)

<iframe src="https://nbviewer.jupyter.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160126_Pgenerosa_BGI_data_handling.ipynb" width="100%" height="2000" scrolling="yes"></iframe>
