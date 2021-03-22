---
author: kubu4
comments: true
date: 2015-05-04 23:41:33+00:00
layout: post
slug: blast-c-gigas-larvae-oa-illumina-data-against-genbank-nt-db
title: BLAST - C.gigas Larvae OA Illumina Data Against GenBank nt DB
wordpress_id: 1300
author:
  - kubu4
categories:
  - Crassostrea gigas larvae OA (2011) bisulfite sequencing
tags:
  - bioinformatics
  - BLAST
  - BLASTn
  - BS-seq
  - Crassostrea gigas
  - GenBank
  - ipython notebook
  - jupyter notebook
  - NCBI
  - Pacific oyster
---

In an attempt to figure out what's going on with the Illumina data we recently received for these samples, I BLASTed the 400ppm data set that had previously been _de-novo_ assembled by Steven: [EmmaBS400.fa](https://owl.fish.washington.edu/halfshell/EmmaBS400.fa).

Jupyter (IPython) Notebook : [20150501_Cgigas_larvae_OA_BLASTn_nt.ipynb](https://eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20150501_Cgigas_larvae_OA_BLASTn_nt.ipynb)

Notebook Viewer : [20150501_Cgigas_larvae_OA_BLASTn_nt](https://nbviewer.ipython.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20150501_Cgigas_larvae_OA_BLASTn_nt.ipynb)

<iframe src="https://nbviewer.ipython.org/url/eagle.fish.washington.edu/Arabidopsis/iPythonNotebooks/20150501_Cgigas_larvae_OA_BLASTn_nt.ipynb" width="100%" height="2000" scrolling="yes"></iframe>

Results:

BLASTn Output File: [20150501_nt_blastn.tab](https://eagle.fish.washington.edu/Arabidopsis/20150501_nt_blastn.tab)

BLAST e-vals <= 0.001: [20150501_Cgigas_larvae_OA_blastn_evals_0.001.txt](https://eagle.fish.washington.edu/Arabidopsis/20150501_Cgigas_larvae_OA_blastn_evals_0.001.txt)

Unique BLAST Species: [20150501_Cgigas_larvae_OA_unique_blastn_evals.txt](https://eagle.fish.washington.edu/Arabidopsis/20150501_Cgigas_larvae_OA_unique_blastn_evals.txt)



Firstly, since this library was bisulfite converted, we know that matching won't be as robust as we'd normally see.

However, the BLAST matches for this are terrible.

Only 0.65% of the BLAST matches (e-value <0.001) are to _Crassostrea gigas_. Yep, you read that correctly: 0.65%.

It's nearly 40-fold less than the top species: _[Dictyostelium discoideum](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0CB8QFjAA&url=http%3A%2F%2Fen.wikipedia.org%2Fwiki%2FDictyostelium_discoideum&ei=WQBIVbGUBYy7ogTFnYCwDA&usg=AFQjCNFUalm3Sy5RAsI8xZSmAB3P8RHxTw&sig2=Yma6kVnm1PJflwBRfsMiCg&bvm=bv.92291466,d.cGU)_ (a slime mold)

It's 30-fold less than the next species: _Danio rerio_ (zebra fish)

Then it's followed up by human and mouse.

I think I will need to contact the Univ. of Oregon sequencing facility to see what their thoughts on this data is, because it's not even remotely close to what we should be seeing, even with the bisulfite conversion...
