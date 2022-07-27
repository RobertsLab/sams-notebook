---
layout: post
title: BS-seq and SNP Analysis - Nextflow EpiDiverse Pipelines Trials and Tribulations
date: '2022-07-25 13:37'
tags: 
  - epidiverse
  - SNP
  - BSseq
  - Nextflow
categories: 
  - Miscellaneous
---
Alrighty, this notebook entry is going to have a _lot_ to unpack, as the process to get these pipelines running _and_ then deal with the actual data we wanted to run them with was quite involved. However, the TL;DR of this all is this:

- Both EpiDiverse pipelines (`wgbs` and `snp`) are running properly on our computer, Raven.

- The [_Ostrea lurida_ (Olympia oyster)](http://en.wikipedia.org/wiki/Pacific_oyster) data which Steven wanted to identify SNPs in is possibly screwy?

Anyway, now to the meat of everything! If not interested in all the ins/outs, skip down to the [Results section](####Results) to see the various comparisons which were run. This analysis was spurred by [this GitHub Issue](https://github.com/RobertsLab/resources/issues/1489). Steven wanted to run some [_Ostrea lurida_ (Olympia oyster)](http://en.wikipedia.org/wiki/Pacific_oyster) MBD BSseq data ([from December 2015](https://github.com/RobertsLab/project-olympia.oyster-genomic/wiki/MBD-BSseq-December-2015)). These data are single-end, 50bp FastQs from ZymoResearch, with files named `zr1394*`. They were trimmed with `TrimGalore` on 20180503. Steven ran the trimmed data through [`Bismark`](https://github.com/FelixKrueger/Bismark) and created deduplicated, sorted BAMs on 2020205. These BAMs were created using our [Olurida_v081.fa](http://owl.fish.washington.edu/halfshell/genomic-databank/Olurida_v081.fa).

- [Trimming data](https://owl.fish.washington.edu/Athaliana/20180503_oly_methylseq_trimgalore/)

- [Trimming notebook](https://robertslab.github.io/sams-notebook/2018/05/08/bs-seq-mapping-olympia-oyster-bisulfite-sequencing-trimgalore-fastqc-bismark.html)

- [Olurida_v081 Bismark alignment data](https://gannet.fish.washington.edu/seashell/bu-mox/scrubbed/020320-oly/)


Attempted to run the deduplicated, sorted BAMs through the [`EpiDiverse/snp`](https://github.com/EpiDiverse/snp) Nextflow pipeline, but repeatedly encountered a memory error. Memory limitations were also an issue Steven had also encountered when trying to do the same anlalysis using [BS-Snper](https://github.com/hellbelly/BS-Snper). So, Steven created a reduced genome and ran the data through [`Bismark`](https://github.com/FelixKrueger/Bismark) using that genome.

- [Olurida_v081-mergecat98.fa](https://gannet.fish.washington.edu/seashell/bu-github/paper-oly-mbdbs-gen/data/bgdata/Olurida_v081-mergecat98.fa)

- [Olurida_v081-mergecat98 Bismark alignment data](https://gannet.fish.washington.edu/seashell/bu-mox/scrubbed/070322-olymerge-snp/)

Was finally able to run those BAMs through the [`EpiDiverse/snp`](https://github.com/EpiDiverse/snp) Nextflow pipeline, but the "Substitutions" plot looked like this:

![bar plot of SNP substitutions showing a large bar in only C>T SNPs and nothing in other types of substitutions](https://gannet.fish.washington.edu/Atumefaciens/20220707-olur-epidiverse/snps/stats/zr1394_10_s456_trimmed_bismark_bt2.deduplicated/substitutions.0.png)

These results didn't look like what we'd expected (expected a more equal distribution on SNPs...); which triggered a rabbit hole of exploration and testing. Performed the following runs to see if I could identify the source of this skewed SNP distribution:

- [Different data set (geoduck)](https://gannet.fish.washington.edu/Atumefaciens/20220715-pgen-epdiverse-snp-bismark/)

- Original Oly trimmed FastQs through [`EpiDiverse/wgbs`](https://gannet.fish.washington.edu/Atumefaciens/20220715-olur-zr1394_all_trimmed-nextflow_epidiverse-wgbs/), followed by [`EpiDiverse/snp`](https://gannet.fish.washington.edu/Atumefaciens/20220716-olur-zr1394-all-epidiverse-snp/).

- Raw FastQs trimmed with default settings in the [`EpiDiverse/wgbs` pipeline](https://gannet.fish.washington.edu/Atumefaciens/20220720-olur-zr1394_all_untrimmed-nextflow_epidiverse-wgbs-conda/) followed by the [`EpiDiverse/snp` pipeline](https://gannet.fish.washington.edu/Atumefaciens/20220717-olur-zr1394_all_untrimmed-nextflow_epidiverse-snp/)

- Raw FastQs trimmed with additional hard clipping of 10bp from 5' end to match how original trimming on 20180503 had been performed (trimming regimen is what's recommended by [`TrimGalore`](https://github.com/FelixKrueger/TrimGalore) for this type of data) using the [`EpiDiverse/wgbs` pipeline](https://gannet.fish.washington.edu/Atumefaciens/20220721-olur-zr1394_all_untrimmed-nextflow_epidiverse-wgbs-conda-trim_10bp_5prime/), followed by [`EpiDiverse/snp` pipeline](https://gannet.fish.washington.edu/Atumefaciens/20220721-olur-zr1394_all_untrimmed-nextflow_epidiverse-snp-conda-trim_10bp_5prime/)


---

#### RESULTS


Summary in table form might be the easiest way to present this:

| Oly Bismark                                                                                                                                                                                                                       | Geoduck Bismark                                                                                                                                                                                                                                    | Oly EpiDiverse Adaptor Trim                                                                                                                                                                                                               | Oly EpiDiverse Adaptor and 10bp 5’ Trim                                                                                                                                                                                                                         | Oly EpiDiverse Adaptor and 10bp 5’/3’ trim                                                                                                                                                                                                                                 |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ![Substitions barplot showing almost only C>T subsitutions](https://gannet.fish.washington.edu/Atumefaciens/20220713-olu-epidiverse-snp-all/snps/stats/zr1394_1_s456_trimmed_bismark_bt2.deduplicated.sorted/substitutions.0.png) | ![Subsitutions barplot showing expected distribution of SNPs](https://gannet.fish.washington.edu/Atumefaciens/20220715-pgen-epdiverse-snp-bismark/snps/stats/EPI-205_S26_L004_R1_001_val_1_bismark_bt2_pe.deduplicated.sorted/substitutions.0.png) | ![Substituions barplot showing better, but still skewed SNP distributions](https://gannet.fish.washington.edu/Atumefaciens/20220720-olur-zr1394_all_untrimmed-nextflow_epidiverse-snp-conda/snps/stats/zr1394_1_s456/substitutions.0.png) | ![Substitutions barplot showing similar skewing to default EpiDiverse trimming](https://gannet.fish.washington.edu/Atumefaciens/20220721-olur-zr1394_all_untrimmed-nextflow_epidiverse-snp-conda-trim_10bp_5prime/snps/stats/zr1394_1_s456/substitutions.0.png) | ![Substitutions barplot showing very similar skew as the original Oly Bismark plot](https://gannet.fish.washington.edu/Atumefaciens/20220726-olur-zr1394_all_untrimmed-nextflow_epidiverse-snp-conda-trim_10bp_5-and-3-prime/snps/stats/zr1394_1_s456/substitutions.0.png) |
