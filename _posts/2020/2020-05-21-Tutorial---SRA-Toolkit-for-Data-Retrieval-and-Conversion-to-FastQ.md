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

Start by visiting the SRA BioProject page for a particular SRA.


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


That file will look like this:

```shell
$ head SRR_Acc_List.txt
SRR10757136
SRR10757128
SRR10757129
SRR10757130
SRR10757131
SRR10757132
SRR10757133
SRR10757134
SRR10757135
SRR10757137
```

Use that file to download the actual SRA files.

```shell
 /gscratch/srlab/programs/sratoolkit.2.10.6-centos_linux64/bin/prefetch.2.10.6 --output-directory . --option-file SRR_Acc_List.txt
 ```
 - If running on Mox, you'll need to [use a build node](https://github.com/RobertsLab/hyak_mox/wiki/Node-Types), as the processing will be more than allowed with the default login node _and_ you need internet access (which is not avaiable on an interactive/execute node).

  - If no output directory is specified, the files will end up in: `/gscratch/srlab/data/ncbi/sra/`

Get FastQ files from the SRA file(s). This can be run on a build node, an interactive node, or via an execute node using an SBATCH script. The settings used in the example below will produce a set of paired FastQ files for each SRA file (assuming the SRA consists of paired-end reads).

```shell
for file in *.sra
do
  /gscratch/srlab/programs/sratoolkit.2.10.6-centos_linux64/bin/fasterq-dump.2.10.6 \
  --outdir . \
  --split-files \
  --threads 27 \
  --mem 100GB \
  --progress
done
```
