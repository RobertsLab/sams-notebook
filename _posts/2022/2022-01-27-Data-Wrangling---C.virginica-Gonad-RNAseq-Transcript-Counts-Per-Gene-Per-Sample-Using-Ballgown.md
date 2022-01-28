---
layout: post
title: Data Wrangling - C.virginica Gonad RNAseq Transcript Counts Per Gene Per Sample Using Ballgown
date: '2022-01-27 11:11'
tags: 
  - data wrangling
  - Crassostrea virginica
  - eastern oyster
  - R
  - ballgown
categories: 
  - Miscellaneous
---
As we continue to work on the analysis of impacts of OA on [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) gonads via [DNA methylation and RNAseq](https://github.com/epigeneticstoocean/2018_L18-adult-methylation) (GitHub repo), we decided to [compare the number of transcripts expressed per gene per sample](https://github.com/RobertsLab/resources/issues/1369) (GitHub Issue). As it turns out, it was quite the challenge. Ultimately, I wasn't able to solve it myself, and turned to StackOverflow for a solution. I should've just done this at the beginning, as I got a response (and solution) less than five minutes after posting! Regardless, the data wrangling progress (struggle?) was documented in the following GitHub Discussion:

- [Help with unwiedldy table(https://github.com/RobertsLab/resources/discussions/1370)

The final data wrangling was performed using `R` and documented in this R Markdown file:

- [`transcript-counts.Rmd`](https://github.com/epigeneticstoocean/2018_L18-adult-methylation/blob/main/code/transcript-counts.Rmd)


---

#### RESULTS

Output file (CSV):

- [`transcript-counts_per-gene-per-sample.csv`](https://github.com/epigeneticstoocean/2018_L18-adult-methylation/blob/main/analyses/transcript-counts_per-gene-per-sample.csv)

Ultimately, the solution came down to this tiny bit of code (see the R Markdown file linked above for actual info about it):

```r
whole_tx_table %>%
select(starts_with(c("gene_name", "FPKM"))) %>%
group_by(gene_name) %>%
summarise((across(everything(), ~sum(. > 0))))
```

That's it!

