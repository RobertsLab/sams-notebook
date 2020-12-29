---
layout: post
title: Data Received - C.bairdi RNAseq Data from Genewiz
date: '2020-03-18 10:07'
tags:
  - Tanner crab
  - RNAseq
  - genewiz
  - Chionoecetes bairdi
categories:
  - Data Received
---
We received the RNAseq data from the [RNA that was sent out by Grace on 20200212](https://grace-ac.github.io/sent-crab-rna-genewiz/).

Sequencing is 150bp PE.

Grace has a Google Sheet that describes what the samples constitute (e.g. ambient/cold/warm, infected/uninfect, day, etc.)

- [02122020-samples-sent-to-genewiz
](https://docs.google.com/spreadsheets/d/1hXMY1rg5qYNTsqvO7PXbRgM7LF06ntEp27N2Efc9gSo/edit?usp=sharing)

Genewiz report:

| Project      | Sample ID | Barcode Sequence  | # Reads    | Yield (Mbases) | Mean Quality Score | % Bases >= 30 |
|--------------|-----------|-------------------|------------|----------------|--------------------|---------------|
| 30-343338329 | 72        | ACTCGCTA+TCGACTAG | 27,249,335 | 8,175          | 34.16              | 85.82         |
| 30-343338329 | 73        | ACTCGCTA+TTCTAGCT | 25,856,008 | 7,757          | 33.87              | 84.36         |
| 30-343338329 | 113       | ACTCGCTA+CCTAGAGT | 31,638,462 | 9,492          | 32.38              | 77.77         |
| 30-343338329 | 118       | ACTCGCTA+GCGTAAGA | 29,253,455 | 8,776          | 33.50              | 82.62         |
| 30-343338329 | 127       | ACTCGCTA+CTATTAAG | 27,552,329 | 8,266          | 33.14              | 81.13         |
| 30-343338329 | 132       | ACTCGCTA+AAGGCTAT | 27,518,702 | 8,256          | 34.86              | 88.87         |
| 30-343338329 | 151       | ACTCGCTA+GAGCCTTA | 33,430,314 | 10,029         | 35.01              | 89.35         |
| 30-343338329 | 173       | ACTCGCTA+TTATGCGA | 33,262,459 | 9,979          | 34.45              | 87.06         |
| 30-343338329 | 178       | GGAGCTAC+TCGACTAG | 29,495,389 | 8,849          | 35.01              | 89.62         |
| 30-343338329 | 221       | GGAGCTAC+TTCTAGCT | 25,902,415 | 7,771          | 34.76              | 88.40         |
| 30-343338329 | 222       | GGAGCTAC+CCTAGAGT | 53,808,137 | 16,142         | 30.90              | 71.11         |
| 30-343338329 | 254       | GGAGCTAC+GCGTAAGA | 16,771,613 | 5,031          | 35.14              | 90.03         |
| 30-343338329 | 272       | GGAGCTAC+CTATTAAG | 27,818,893 | 8,346          | 33.30              | 81.70         |
| 30-343338329 | 280       | GGAGCTAC+AAGGCTAT | 61,008,799 | 18,303         | 30.85              | 70.86         |
| 30-343338329 | 294       | GGAGCTAC+GAGCCTTA | 28,539,233 | 8,562          | 35.12              | 90.04         |
| 30-343338329 | 334       | GGAGCTAC+TTATGCGA | 25,916,895 | 7,775          | 34.98              | 89.39         |
| 30-343338329 | 349       | GCGTAGTA+TCGACTAG | 32,868,756 | 9,861          | 33.53              | 82.69         |
| 30-343338329 | 359       | GCGTAGTA+TTCTAGCT | 27,274,149 | 8,182          | 34.96              | 89.20         |
| 30-343338329 | 425       | GCGTAGTA+CCTAGAGT | 66,224,932 | 19,867         | 29.54              | 65.13         |
| 30-343338329 | 427       | GCGTAGTA+GCGTAAGA | 18,918,640 | 5,676          | 33.31              | 80.87         |
| 30-343338329 | 445       | GCGTAGTA+CTATTAAG | 30,745,388 | 9,224          | 33.07              | 80.83         |
| 30-343338329 | 463       | GCGTAGTA+AAGGCTAT | 19,531,145 | 5,859          | 34.27              | 86.08         |
| 30-343338329 | 481       | GCGTAGTA+GAGCCTTA | 50,592,084 | 15,178         | 31.92              | 75.59         |
| 30-343338329 | 485       | GCGTAGTA+TTATGCGA | 26,010,208 | 7,803          | 34.63              | 87.48         |

Confirmed that SFTP transfer from Genewiz to `owl/nightingales/C_bairdi/` was successful:

![screencap of md5sum output](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200318_cbai_rnaseq_genewiz_md5_checks.png?raw=true)


---

#### RESULTS

Output folder:

- [owl/nightingales/C_bairdi/](https://owl.fish.washington.edu/nightingales/C_bairdi)

Will update the [nightingales Google Sheet](http://b.link/nightingales) with the appropriate info shortly.
