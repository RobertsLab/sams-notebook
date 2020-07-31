---
layout: post
title: Primer Design and In-Silico Testing - Geoduck Reproduction Primers
date: '2020-07-30 21:02'
tags:
  - geoduck
  - Panopea generosa
  - Primer3
  - EMBOSS
  - primersearch
  - jupyter
categories:
  - Miscellaneous
---
[Shelly asked that I re-run the primer design pipeline](https://github.com/RobertsLab/resources/issues/974) that Kaitlyn had previously run to design a set of reproduction-related qPCR primers. Unfortunately, Kaitlyn's Jupyter Notebook wasn't backed up and she accidentally deleted it, I believe, so there's no real record of how she designed the primers. However, I do know that she was unable to run the EMBOSS primersearch tool, which will check your primers against a set of sequences for any other matches. This is useful for confirming specificity.

In an attempt to replicate what Katilyn previously did, I used the following:

- [List of sequence IDs from _P.generosa_ genes FastA](https://github.com/RobertsLab/resources/issues/822#issuecomment-572313717) (GitHub Issue comment from Steven)

- [_P.generosa_ genes FastA](https://osf.io/ct623/) (OSF repo)

- [Abbreviated gene names used to name primers](https://docs.google.com/spreadsheets/d/1vkUQvqNUN-9ntv0NoVDAtD8zA-p9e3xosGwsWSFV0qk/edit#gid=0) (Google Sheet)


Primers were designed using [Primer3](https://sourceforge.net/projects/primer3/files/primer3/).

Primers were checked for specificity, allowing a 20 percent mismatch, using the [EMBOSS primersearch program](http://emboss.open-bio.org/rel/rel6/apps/primersearch.html).

This was all documented and run in a Jupyter Notebook (GitHub):

- [20200730_swoose_geoduck_repro_check.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20200730_swoose_geoduck_repro_check.ipynb)

---

#### RESULTS

Output folder:

- []()
