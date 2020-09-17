---
layout: post
title: qPCR - Geoduck Normalizing Gene Primers 28s-v4 and EF1a-v1 Tests
date: '2020-09-16 07:06'
tags:
  - geoduck
  - Panopea generosa
  - qPCR
  - CFX Connect
categories:
  - Miscellaneous
---
On Monday (20200914), I [checked a set of 28s and EF1a primer sets](https://robertslab.github.io/sams-notebook/2020/09/14/qPCR-Geoduck-Normalizing-Gene-Primer-Checks.html) and determined that 28s-v4 and EF1a-v1 were probably the best of the bunch, although they all looked great. So, I needed to test these out on some individual cDNA samples to see if they might be useful as normalizing genes - should have consistent Cq values across all samples/treatments.

Primers tested:

| SRID | Primer_Name |
|------|-------------|
| 1797 | 28s_v4_FWD  |
| 1796 | 28s_v4_REV  |
| 1795 | EF1a_v1_FWD |
| 1794 | EF1a_v1_REV |

I tested them on a set of _P.generosa_ hemolymph [cDNA made by Kaitlyn on 20200212](https://genefish.wordpress.com/2020/02/12/kaitlyns-notebook-testing-new-primers-on-geoduck-hemolymph-rna/).

I also used a 1:10 dilution of [geoduck gDNA (162ng/uL; from 20170105)](https://robertslab.github.io/sams-notebook/2017/01/05/dna-isolation-geoduck-gdna-for-illumina-initiated-sequencing-project.html) as a positive control, as gDNA was amplified by all the primer sets on Monday.

Master mix calcs are here:

- [200200916_qPCR_geoduck_28s-4_EF1a-v1](https://docs.google.com/spreadsheets/d/1JzsMf3iLz01wbwjqYCCCpHoFNqFgMO-EVtax_hXq4Ss/edit?usp=sharing) (Google Sheet)

All qPCR reactions were run in duplicate. See qPCR Report (Results section below) for plate layout, cycling params, etc.

---

#### RESULTS

qPCR Report (PDF):

- [sam_2020-09-16_04-57-06_BR006896.pdf](https://owl.fish.washington.edu/Athaliana/qPCR_data/qPCR_reports/sam_2020-09-16_04-57-06_BR006896.pdf)

CFX Data File (PCRD):

- [sam_2020-09-16_04-57-06_BR006896.pcrd](https://owl.fish.washington.edu/scaphapoda/qPCR_data/cfx_connect_data/sam_2020-09-16_04-57-06_BR006896.pcrd)


CFX Results File (CSV):

- [sam_2020-09-16_04-57-06_BR006896_Quantification-Cq-Results.csv](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-16_04-57-06_BR006896_Quantification-Cq-Results.csv)

28s-v4 melt plots aren't great and might even possibly have a slight shoulder, suggesting a secondary product. Not great. Additionally, the samples have a fairly large Cq range; not good for a normalizing gene.

EF1a-v1 melt plots look great, but the amplification also exhibits a Cq range that's too large for a normalizing gene.

With all of that said, I'm starting to think it would be best to re-quant the source RNA and remake cDNA.

Amplifcation and melt plots for each primer set are below. Color coding:

- RED: No Template Control (NTC)

- CHARTREUSE: gDNA

- OTHER: cDNA

##### 28s v4

AMPLIFICATION PLOTS

![28s-v4 amp plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-16_04-57-06_BR006896_28s-v4_amp_plots.png)

MELT PLOTS

![28s-v4 melt plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-16_04-57-06_BR006896_28s-v4_melt_plots.png)

##### EF1a v1

AMPLIFICATION PLOTS

![EF1a-v1 amp plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-16_04-57-06_BR006896_EF1a-v1_amp_plots.png)

MELT PLOTS

![EF1a-v1 melt plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-16_04-57-06_BR006896_EF1a-v1_melt_plots.png)
