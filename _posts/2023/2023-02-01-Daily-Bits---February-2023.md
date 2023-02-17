---
layout: post
title: Daily Bits - February 2023
date: '2023-02-01 08:22'
tags: 
  - daily bits
categories: 
  - Daily Bits
---


20230217

- Science Hour

- [Created _C.goreaui_ (_P.verrucosa_ endosymbiont) GTF](https://robertslab.github.io/sams-notebook/2023/02/17/Data-Wrangling-C.goreaui-Genome-GFF-to-GTF-Using-gffread.html) and added to [Genomic Resources Handbook page](https://robertslab.github.io/resources/Genomic-Resources/).

- Read a lot about container usage in order to be able to effectively use `coenv` node on Klone...

---

20230216

- Pub-a-thon

- Long meeting with Emma Strand trying to troubleshoot conda install of EpiDiverse/snp on her HPC cluster. No luck. Advised her to talk with her IT dept.

- Downloaded _P.verrucosa_ endosymbiont genome and GFF files.

- Began [`HISAT2`](https://daehwankimlab.github.io/hisat2/) alignments and StringTie analysis using E5 _P.verrucosa_ [trimmed RNA-seq data]((https://robertslab.github.io/sams-notebook/2023/02/15/FastQ-Trimming-and-QC-P.verrucosa-RNA-seq-Data-from-Danielle-Becker-in-Hollie-Putnam-Lab-Using-fastp-FastQC-and-MultiQC-on-Mox.html)).

---

20230215

- Long Slack chat with Danielle Becker regarding her E5 _P.verrucosa_ RNA-seq data.

  - [Trimming doesn't look like it worked](https://gannet.fish.washington.edu/Atumefaciens/hputnam-Becker_E5/Becker_RNASeq/data/trimmed/trimmed_qc/multiqc_report.html) (MultiQC Report; HTML).

  - I trimmed raw data:

    - [https://robertslab.github.io/sams-notebook/2023/02/15/FastQ-Trimming-and-QC-P.verrucosa-RNA-seq-Data-from-Danielle-Becker-in-Hollie-Putnam-Lab-Using-fastp-FastQC-and-MultiQC-on-Mox.html](https://robertslab.github.io/sams-notebook/2023/02/15/FastQ-Trimming-and-QC-P.verrucosa-RNA-seq-Data-from-Danielle-Becker-in-Hollie-Putnam-Lab-Using-fastp-FastQC-and-MultiQC-on-Mox.html)

---

20230214

- Helped with an issue that Marta Gomez-Buckley [was having trying to install RAxML-NG on the UW HPC (Klone)](https://github.com/RobertsLab/resources/issues/1578).

- Continued to help Emma Strand with her issue getting EpiDiverse/snp installed on their HPC at URI.

---

20230213

- Lab meeting.

- CEABIGR meeting w/Yaamini.

  - Just worked on adding text (Methods) to manuscript.

- Continued to help Emma Strand with her issue getting EpiDiverse/snp installed on their HPC at URI.

---

20230210

- Worked a lot with Emma Strand from URI to try to troubleshoot her usage of the Nextflow [EpiDiverse/snp pipeline](https://github.com/EpiDiverse/snp). Read [this notebook entry of hers](https://github.com/emmastrand/EmmaStrand_Notebook/blob/master/_posts/2023-02-06-EpiDiverse-Bleaching-Pairs-Analysis.md#troubleshooting) for some details on the error. Seems to be related to use of Singularity (now Apptainer) container; particularly after she ran the pipeline using the `test` command and got the same error message as when she ran with her own data set.

- Transferred Danielle Becker Coral E5 data from Mox to Gannet:

  - [hputnam-Becker_E5/](https://gannet.fish.washington.edu/Atumefaciens/hputnam-Becker_E5/)

    - NOTE: There are no README files, so I can only glean info regarding contents from directory names. Will potentially discuss contents in more detail with Danielle at a later date.

---

20230209

- Worked with Danielle Becker, as part of the Coral E5 project, to transfer data related to [this repo](https://github.com/hputnam/Becker_E5), from her HPC (Univ. of Rhode Island; Andromeda) to ours (Univ. of Washington; Mox) in order to eventually transfer to Gannet so that these files are publicly accessible to all members of the Coral E5 project.

  - GlobusConnect did not work. Couldn't figure out how to make URI endpoint accessible.

  - URI IT provide a solution via [rclone](https://rclone.org/), involving transferring the data from an Amazon S3 bucket. `rclone` setup info is below, but I've removed the access key info:

    ```
    [becker]
    type = s3
    provider = Ceph
    access_key_id = <redacted>
    secret_access_key = <redacted>
    endpoint = https://sdsc.osn.xsede.org/
    ```

    Ran this command to initiate transfer:

    ```shell
    rclone --progress copy becker:uri-inbre/Becker/ ./Becker
    ```

    This copied all of the data (~1.1TB!!)to this directory on Mox: `/gscratch/srlab/sam/data/Becker`

    Transfer was estimated to take ~12hrs, so I just let it run. Will transfer to Gannet tomorrow...

- Pub-a-thon.

---

20230208

- Worked on Ariana's [Tidy Tuesday assignment](https://github.com/RobertsLab/resources/discussions/1574) for lab meeting next week.

---

20230207

- In lab helping Laura & Steven get supplies ready for cod sampling in Oregon tomorrow.

- Worked on Ariana's [Tidy Tuesday assignment](https://github.com/RobertsLab/resources/discussions/1574) for lab meeting next week.

---

20230206

- Read Ch. 13 of "The Disordered Cosmos."

- Lab meeting.

- Weekly CEABIGR meeting.

  - Decision is to spend time on manuscript.

---

20230203

- Comlete and total lack of motivation. Ugh.

---

20230202

- Pub-a-thon.

---

20230201

- Added CEABIGR mean gene methylation coefficients of variation (CoV) scatter plots to [our Miro board](https://miro.com/app/board/uXjVPYZDgxw=/).