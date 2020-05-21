---
layout: post
title: Tutorial - SRA Toolkit for Data Retrieval and Conversion to FastQ
date: '2020-05-21 08:51'
tags:
  - SRA
  - FastQ
  - mox
categories:
  - Tutorials
---
I was looking for some crab transcriptomic data today and, unable to find any previously assembled transcriptomes, turned to the good ol' [NCBI SRA](https://www.ncbi.nlm.nih.gov/sra). In order to simplify retrieval and conversion of SRA data, need to use the [SRA Toolkit software suite](https://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?view=software). Since I haven't used this in many years, I figured I might as well put together a brief guide/tutorial so I can refer back to it in the future.

It should be noted that this is written to describe usage of the SRA Toolkit on our Mox account (UW HPC). If setting this up elsewhere, you'll want (need?) to configure the default storage location that the SRA Toolkit will use on your specific computer.

As a side note, I found this helpful page which tracks arthropod genome data present on NCBI:

- [i5k](https://i5k.github.io/arthropod_genomes_at_ncbi)

Let's get started. I'll start by visiting the SRA BioProject page for a particular SRA.


1. BioProject Page:

![sra_tools_tutorial_bioproject](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/sra_tools_tutorial_bioproject.png?raw=true)

---

2. Click on the "Number of Links" in "SRA Experiments" row:

![sra_tools_tutorial_sra-experiments](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/sra_tools_tutorial_sra-experiments.png?raw=true)

---

3. Click on "All runs" link:


![sra_tools_tutorial_sra-accession](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/sra_tools_tutorial_sra-accession.png?raw=true)

---

4. Click on "Accesion List" (circled) to download text file of all associated SRR accessions:

![sra_tools_tutorial_all-runs](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/sra_tools_tutorial_all-runs.png?raw=true)

---
