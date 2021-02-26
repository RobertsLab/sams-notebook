---
author: kubu4
comments: true
date: 2016-01-28 00:30:56+00:00
layout: post
slug: data-received-ostrea-lurida-genome-sequencing-files-from-bgi
title: Data Received - Ostrea lurida genome sequencing files from BGI
wordpress_id: 1988
author:
  - kubu4
categories:
  - Olympia Oyster Genome Sequencing
tags:
  - BGI
  - ipython notebook
  - jupyter notebook
  - olympia oyster
  - Ostrea lurida
---

Downloaded data from the BGI project portal to our server, Owl, using the Synology Download Station. Although the BGI portal is aesthetically nice, it's set up poorly for bulk downloads and took a few tries to download all of the files.

Data integrity was assessed and read counts for each file were generated. The files were moved to their permanent storage location on Owl: https://owl.fish.washington.edu/nightingales/O_lurida

The [readme.md](https://owl.fish.washington.edu/nightingales/O_lurida/readme.md) file was updated to include project/file information.

The file manipulations were performed in a Jupyter notebook (see below).



Total reads generated for this project: 1,225,964,680

BGI provided us with the raw data files for us to play around with, but they are also currently in the process of performing the genome assembly.



Jupyter Notebook file: [20160126_Olurida_BGI_data_handling.ipynb](https://eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160126_Olurida_BGI_data_handling.ipynb)

Notebook Viewer: [20160126_Olurida_BGI_data_handling.ipynb](https://nbviewer.jupyter.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160126_Olurida_BGI_data_handling.ipynb)

<iframe src="https://nbviewer.jupyter.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160126_Olurida_BGI_data_handling.ipynb" width="100%" height="500" scrolling="yes"></iframe>
