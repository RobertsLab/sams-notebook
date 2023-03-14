---
layout: post
title: Data Received - Trimmed M.magister RNA-seq from NOAA
date: '2023-03-01 13:27'
tags: 
  - Metacarcinus magister
  - dungeness crab
  - RNAseq
  - rclone
categories: 
  - Data Received
---
Transferred trimmed _C.magister_ RNA-seq data from Google Drive to our HPC (Mox) using [`rclone`](https://rclone.org). This was a great suggestion from Giles Goetz!

Additionally, the `rclone` website has [a great explanation on how to configure a connection to Google Drive](https://rclone.org/drive/). The key to doing this, though, was specifying `--drive-shared-with-me` option. Without that, the shared drive was not visible/accessible. In the code below, `noaa-crab` is the name of the configuration I set up following the instructions linked above.

    ```shell
    rclone-v1.61.1-linux-amd64/rclone \
    copy \
    --progress \
    --drive-shared-with-me \
    noaa-crab:202301-dungeness_crab-transcriptome/ \
    ./
    ```
This data will end up being used with MEGAN6 to perform taxonomic classification of reads. Steven was curious what this might look like and the process is very low friction, so he just wanted to see.

---

#### RESULTS

Output folder:

- [20230301-mmag-trimmed_rnaseq_from_noaa/](https://gannet.fish.washington.edu/Atumefaciens/20230301-mmag-trimmed_rnaseq_from_noaa/)

  - #### MD5 checksums (text)

    - [20230301-mmag-trimmed_rnaseq_from_noaa/md5s.txt](https://gannet.fish.washington.edu/Atumefaciens/20230301-mmag-trimmed_rnaseq_from_noaa/20230301-mmag-trimmed_rnaseq_from_noaa/)

