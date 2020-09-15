---
layout: post
title: qPCR - Geoduck Normalizing Gene Primer Checks
date: '2020-09-14 10:22'
tags:
  - geoduck
  - Panopea generosa
  - CFX Connect
  - qPCR
categories:
  - Miscellaneous
---
[Shelly ordered some new primers (designed by Sam Gurr)](https://github.com/RobertsLab/resources/issues/988) (GitHub Issue) to potentially use as normalizing genes for her geoduck reproduction gene expression project and asked that I test them out.

Primers tested:

| SRID | Primer_Name |
|------|-------------|
| 1803 | 28s_v1_FWD  |
| 1802 | 28s_v1_REV  |
| 1801 | 28s_v2_FWD  |
| 1800 | 28s_v2_REV  |
| 1799 | 28s_v3_FWD  |
| 1798 | 28s_v3_REV  |
| 1797 | 28s_v4_FWD  |
| 1796 | 28s_v4_REV  |
| 1795 | EF1a_v1_FWD |
| 1794 | EF1a_v1_REV |
| 1793 | EF1a_v2_FWD |
| 1792 | EF1a_v2_REV |
| 1791 | EF1a_v3_FWD |
| 1790 | EF1a_v3_REV |
| 1789 | EF1a_v4_FWD |
| 1788 | EF1a_v4_REV |


I used pooled cDNA, created by combining 2uL from a variety of cDNA previously made by Kaitlyn (sorry, didn't document which samples contributed this time...).



I also used a 1:10 dilution of [geoduck gDNA (162ng/uL; from 20170105)](https://robertslab.github.io/sams-notebook/2017/01/05/dna-isolation-geoduck-gdna-for-illumina-initiated-sequencing-project.html) as a potential positive control, and/or as confirmation that these primers will/not amplify gDNA.

Master mix calcs are here:

- [200200914_qPCR_geoduck_28s-v1-4_EF1a-v1-4](https://docs.google.com/spreadsheets/d/1WmQ9sJ0ANz5Z0d94BJ_2QOu1mr2XEGGN0Iol-jteTEY/edit?usp=sharing) (Google Sheet)

All qPCR reactions were run in duplicate. See qPCR Report (Results section below) for plate layout, cycling params, etc.


---

#### RESULTS

qPCR Report (PDF):

- [sam_2020-09-14_10-15-48_BR006896.pdf](https://owl.fish.washington.edu/Athaliana/qPCR_data/qPCR_reports/sam_2020-09-14_10-15-48_BR006896.pdf)

CFX Data File (PCRD):

- [sam_2020-09-14_10-15-48_BR006896.pcrd](https://owl.fish.washington.edu/scaphapoda/qPCR_data/cfx_connect_data/sam_2020-09-14_10-15-48_BR006896.pcrd)


CFX Results File (CSV):

- [sam_2020-09-14_10-15-48_BR006896_Quantification-Cq-Results.csv](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_Quantification-Cq-Results.csv)


![28s-v1 amp plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_28s-v1_amp_plots.png)

![28s-v1 melt plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_28s-v1_melt_plots.png)

![28s-v2 amp plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_28s-v2_amp_plots.png)

![28s-v2 melt plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_28s-v2_melt_plots.png)

![28s-v3 amp plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_28s-v3_amp_plots.png)

![28s-v3 melt plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_28s-v3_melt_plots.png)

![28s-v4 amp plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_28s-v4_amp_plots.png)

![28s-v4 melt plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_28s-v4_melt_plots.png)

![EF1a-v1 amp plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_EF1a-v1_amp_plots.png)

![EF1a-v1 melt plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_EF1a-v1_melt_plots.png)

![EF1a-v2 amp plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_EF1a-v2_amp_plots.png)

![EF1a-v2 melt plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_EF1a-v2_melt_plots.png)

![EF1a-v3 amp plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_EF1a-v3_amp_plots.png)

![EF1a-v3 melt plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_EF1a-v3_melt_plots.png)

![EF1a-v4 amp plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_EF1a-v4_amp_plots.png)

![EF1a-v4 melt plots.png ](https://owl.fish.washington.edu/Athaliana/qPCR_data/sam_2020-09-14_10-15-48_BR006896_EF1a-v4_melt_plots.png)
