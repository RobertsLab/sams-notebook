---
layout: post
title: Data Received - P.verrucosa RNA-seq and WGBS Full Data from Danielle Becker
date: '2023-02-10 22:45'
tags: 
  - RNAseq
  - WGBS
  - Pocillipora verrucosa
  - E5
categories: 
  - E5
  - Data Received
---
Worked with Danielle Becker, as part of the Coral E5 project, to transfer data related to [her repo](https://github.com/hputnam/Becker_E5), from her HPC (Univ. of Rhode Island; Andromeda) to ours (Univ. of Washington; Mox) in order to eventually transfer to Gannet so that these files are publicly accessible to all members of the Coral E5 project.

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

    Transfer was estimated to take ~12hrs, so I just let it run.
  
  After it completed, I transferred data from Mox to Gannet:

- [hputnam-Becker_E5/](https://gannet.fish.washington.edu/Atumefaciens/hputnam-Becker_E5/)

    - NOTE: There are no README files, so I can only glean info regarding contents from directory/file names. However, [Danielle's repo](https://github.com/hputnam/Becker_E5) is very nicely organized/documented, so information can be figured out relatively easily by perusing it. Will potentially discuss contents in more detail with Danielle at a later date.

