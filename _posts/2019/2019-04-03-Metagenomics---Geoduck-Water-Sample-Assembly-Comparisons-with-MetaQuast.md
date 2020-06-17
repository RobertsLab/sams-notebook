---
layout: post
title: Metagenomics - Geoduck Water Sample Assembly Comparisons with MetaQuast
date: '2019-04-03 20:39'
tags:
  - metagenomics
  - Panopea generosa
  - metaquast
  - geoduck
categories:
  - Miscellaneous
---
As part of addressing this [GitHub Issue on assessing taxonomic diversity in our metagenomics samples](https://github.com/RobertsLab/resources/issues/547), I decided to compare the individual sample assemblies [I made on 20190327 using Megahit](https://robertslab.github.io/sams-notebook/2019/03/27/Metagenome-Assemblies-P.generosa-Water-Samples-Trimmed-HiSeqX-Data-Using-Megahit-on-Mox.html) and the assemblies that Emma made. Emma utilized [NGless](https://github.com/ngless-toolkit/ngless) on her cluster in Genome Sciences with the following scripts:

- [ngless.job](http://eagle.fish.washington.edu/oyster/metagenomics_2019/ngless.job)

```shell
#!/bin/bash

#$ -cwd
#$ -S /bin/bash
#$ -o ./output
#$ -e ./output
#$ -l mfree=3G
#$ -pe serial 16
#$ -R y

# Send email when job starts, ends or runs into an error
#$ -m beas
#$ -M emmats@uw.edu

#cause a failing process to trigger a job failure to make errors easier to catch
set -eo pipefail

#Initialize and load modules
. /etc/profile.d/modules.sh
module purge
module load modules{,-{init,gs/prod}} ngless/0.10.0

#Script
ngless \
   /net/nunn/vol1/emmats/sequencing/geo_metaG/ngl.singleLibs \
   --trace \
   --keep-temporary-files \
   -j $NSLOTS \
   -t /data/scratch/ssd
```

---

- [ngl.singleLibs](http://eagle.fish.washington.edu/oyster/metagenomics_2019/ngl.singleLibs)

```shell
ngless "0.10"
import "parallel" version "0.6"

samples = readlines('MG7S2')
sample = lock1(samples)
input = fastq(sample)

output = preprocess(input, keep_singles=False) using |read|:
   read = substrim(read, min_quality=25)
   if len(read) < 45:
     discard

contigs = assemble(input)
write(contigs, ofile='contigsM7S2.fa')

orfs = orf_find(contigs, is_metagenome=True)
write(contigs, ofile='orfM7S2.fna')
```

I `rsync`'d all the assembly files to my computer (swoose) and ran [MetaQuast](http://quast.sourceforge.net/metaquast) locally. I did _not_ provide MetaQuast with individual reads, nor reference, as I just wanted a quick and dirty assessment of each of the assemblies. For a more in-depth comparison, I'm currently running [Anvi'o](http://merenlab.org/software/anvio/) on Mox.

I ran MetaQuast with the following command:

```shell
python \
/home/sam/programs/quast-5.0.2/metaquast.py \
--threads=20 \
--min-contig=100 \
--labels=MG1_ets,MG1_sjw,MG2_ets,MG2_sjw,MG3_ets,MG3_sjw,MG5_ets,MG5_sjw,MG6_ets,MG6_sjw,MG7_ets,MG7_sjw \
/home/sam/data/metagenomics/P_generosa/contigsMG1S3.fa \
/home/sam/data/metagenomics/P_generosa/MG1.contigs.fa \
/home/sam/data/metagenomics/P_generosa/contigsMG2S4.fa \
/home/sam/data/metagenomics/P_generosa/MG2.contigs.fa \
/home/sam/data/metagenomics/P_generosa/contigsM32S1.fa \
/home/sam/data/metagenomics/P_generosa/MG3.contigs.fa \
/home/sam/data/metagenomics/P_generosa/contigsM5S6.fa \
/home/sam/data/metagenomics/P_generosa/MG5.contigs.fa \
/home/sam/data/metagenomics/P_generosa/contigsM6S5.fa \
/home/sam/data/metagenomics/P_generosa/MG6.contigs.fa \
/home/sam/data/metagenomics/P_generosa/contigsM7S2.fa \
/home/sam/data/metagenomics/P_generosa/MG7.contigs.fa
```

Here's how the sample names breakdown:

| Sample | Develomental Stage (days post-fertilization) | pH Treatment |
|--------|-------------------------|--------------|
| MG1    | 13                      | 8.2          |
| MG2    | 17                      | 8.2          |
| MG3    | 6                       | 7.1          |
| MG5    | 10                      | 8.2          |
| MG6    | 13                      | 7.1          |
| MG7    | 17                      | 7.1          |



---

#### RESULTS

This took most of the day to run, but churns out some interesting info/data visualizations.

Basically, MetaQuast takes the assemblies you provide it and runs a BLASTn against SILVA 16S rRNA database. After annotating your assemblies via BLASTn, it tries to match taxonomy to a subset (n=50) of NCBI prokaryotic reference genomes. As such, the taxonomic data in this particular assessment is limited and is somewhat obvious when looking at the data (e.g. most contigs don't align to any of the references). Consequently, the various "Genome Statistics" carry little weight on considering the impications of that data, in my opinion.

However, it does provide an excellent summary on how big each of the assemblies are, N50, largest contigs, etc.

Output folder:

- [20190403_metagenomics_pgen_metaquast_comparisons/](http://gannet.fish.washington.edu/Atumefaciens/20190403_metagenomics_pgen_metaquast_comparisons/)

Quast Report (HTML):

- [20190403_metagenomics_pgen_metaquast_comparisons/quast_results/results_2019_04_03_08_23_17/report.html](http://gannet.fish.washington.edu/Atumefaciens/20190403_metagenomics_pgen_metaquast_comparisons/quast_results/results_2019_04_03_08_23_17/report.html)

- The Quast HTML report is a fully interactive report with ways to change views of the data, including contig browsers, heat maps, line graphs.

  - Screen cap of default report view (look at the "Stastics without Reference" section at the bottom of the table):

---

  ![Screen cap of default report view](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190404_metagenomics_pgen_quast-01.png?raw=true)

---

  - Screen cap of the Icarus Contig Viewer:

---

![Screen cap of the Icarus Contig Viewer](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190404_metagenomics_pgen_quast-02.png?raw=true)


---

At a cursory glance at the comparisons, I'd say that the assemblies that I generated with Megahit seem a bit more robust than those that were generated using NGless. However, when looking at the alignments/missassembly data, Emma's assemblies certainly seem to perform better. Overall, it seems like her assemblies were done in a more conservative fashion, resulting in smaller, but possibly more accurate, assemblies. Unfortunately, the NGless job submission is a bit of a black box, as Emma's cluster loaded it as part of a cluster "module" - meaning the settings for NGless are stored in there, not actually in the cluster job submission script. Maybe I'll contact Emma and see if she can pass along the NGless module contents.
