---
layout: post
title: Daily Bits - January 2023
date: '2023-01-03 07:02'
tags: 
  - daily bits
categories: 
  - Daily Bits
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