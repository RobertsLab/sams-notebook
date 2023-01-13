---
layout: post
title: Daily Bits - January 2023
date: '2023-01-03 07:02'
tags: 
  - daily bits
categories: 
  - Daily Bits
---

20230112

- Spent a _very_ long time trying to update CEABIGR mean gene methylation CoV data frames in list so that I could add a delta of CoVs between comparison groups. Had to resort to using ChatGPT (OpenAI) and the bot solved it in less than a minute! Here was the successful solution:

```r
methylation.transposed.rownames.list <- lapply(methylation.transposed.rownames.list, function(df) {
  df$delta <- abs(df[,1] - df[,2])
  return(df)
})
```

I had something _very_ similar to this, but didn't have the `return()` aspect of the data the function. I think that was crucial, as I was getting the `delta` column by itself as the result, but wasn't getting the full data frames with the new `delta` column added to them.

---

20230111

- Messed around with plotting CEABIGR mean gene methylation CoV, via scatter plots. Trying to decide if this method provides any info or not. Also tried to figure out how to plot all data frames, as they are stored in a list.

---

20230110

- Worked extensively on troubleshooting "missing" row names in a list of data frames in CEABIGR project for coefficients of variaton of mean DNA methylation.

  - Turns out, the row names _were_ present the entire time (i.e. I had written the code correctly from the start), but I couldn't figure out how to view the data frames within a list so that the row names would be visible.

  - Additionally, the primary problem was that I wanted row names written in the output files. I in the `write.csv()`, I had the argument `row.names = FALSE`! Doh!

- Answered [Yaamini's question regarding retrieving FastA sequences from NCBI](https://github.com/RobertsLab/resources/discussions/1565).

---

20230109

- Read Ch.11 of "The Disordered Cosmos"

- Lab meeting

  - Discussed Ch.11 of "The Disordered Cosmos"

- Wrote recommendation letter draft for Dorothy.

- Updated Owl.

---

20230106

- Worked on Dorothy's recommendation letter.

- Science Hour.

---

20230105

- Long lab meeting discussing ways to improve lab "life" with suggestions from everyone on what they'd like to see. Really interesting/informative session!

- Continued to work on the [Roberts Lab Handbook transcriptome annotation](https://robertslab.github.io/resources/bio-Annotation/#transcriptome-trinity).

---

20230104

- Worked on Linda Rhodes project on figuring out how to use a pre-built SILVA 138 QIIME classifier.

  - ```
    qiime feature-classifier classify-sklearn \
    --i-reads nonchimeras.qza \
    --i-classifier silva-138.1-ssu-nr99-515f-806r-classifier.qza \
    --o-classification classifier-taxonomy-test.qza
    ```

  - This uses a _lot_ of memory. For the testing I was doing on Linda's marine mammals data set, it required 25GB of RAM, _per CPU_! As such, I couldn't run this with more than a single CPU without the command crashing.

    - Runtime was somewhere between 1.5 - 2 _days_.