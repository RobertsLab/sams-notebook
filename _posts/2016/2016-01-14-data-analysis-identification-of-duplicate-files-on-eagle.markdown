---
author: kubu4
comments: true
date: 2016-01-14 17:56:51+00:00
layout: post
slug: data-analysis-identification-of-duplicate-files-on-eagle
title: Data Analysis - Identification of duplicate files on Eagle
wordpress_id: 1979
author:
  - kubu4
categories:
  - Computer Servicing
tags:
  - awk
  - bash
  - DS413
  - duplicate files
  - Eagle
  - fslint
  - ipython notebook
  - jupyter notebook
  - sed
  - Synology
---

Recently, we've been bumping into our storage limit on Eagle (our Synology DS413):

![](https://eagle.fish.washington.edu/Arabidopsis/20160114_eagle_storage.jpg)(http://eagle.fish.washington.edu/Arabidopsis/20160114_eagle_storage.jpg)



Being fairly certain that there's a significant amount of large datasets that is duplicated throughout Eagle, I ran a program on Linux called "fslint". It searches for duplicates files based on a few parameters and is smart enough to be able to compare files with different filenames that share the same file contents!

I decided to check for duplicate files in the Eagle/archive folder and the Eagle/web folder. Initially, I tried searching for duplicates across all of Eagle, but after a week of running I got tired of waiting for results and ran the analysis on those two directories independently. As such, there is a possibility that there are more duplicates (consuming even more space) across the remainder of Eagle that have not been identified. However, this is a good starting point.

Here are the two output files from the fslint analysis:




    
  * [20160104_duplicate_files_eagle_web.txt](https://eagle.fish.washington.edu/Arabidopsis/20160104_duplicate_files_eagle_web.txt)

    
  * [20151229_duplicate_files_eagle_archive.txt](https://eagle.fish.washington.edu/Arabidopsis/20151229_duplicate_files_eagle_archive.txt)





To get a summary of the fslint output, I tallied the total amount of duplicates files that were >100MB in size. This was performed in a Jupyter notebook (see below):
Notebook Viewer: [20160114_wasted_space_synologies.ipynb](https://nbviewer.ipython.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160114_wasted_space_synologies.ipynb)
Jupyter (IPython) Notebook File: [20160114_wasted_space_synologies.ipynb](https://eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160114_wasted_space_synologies.ipynb)
<iframe src="https://nbviewer.ipython.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20160114_wasted_space_synologies.ipynb" width="100%" height="2000" scrolling="yes"></iframe>


Here are the cleaned output files from the fslint analysis:




    
  * [20151229_duplicate_files_eagle_archive_cleaned.txt](https://eagle.fish.washington.edu/Arabidopsis/20151229_duplicate_files_eagle_archive_cleaned.txt)

    
  * [20151229_duplicate_files_eagle_web_cleaned.txt](https://eagle.fish.washington.edu/Arabidopsis/20160104_duplicate_files_eagle_web_cleaned.txt)





**Summary**

There are duplicates of files (>100MB in size) that are consuming at least **_730GB_**!

Since the majority of these files exist in the Eagle/web folder, careful consideration will have to be taken in determining which duplicates (if any) can be deleted since it's highly possible that there are notebooks that link to some of the files. Regardless, this analysis shows just how space is being consumed by the presence of large, duplicate files; something to consider for future data handling/storage/analysis with Eagle.
