---
layout: post
title: Daily Bits - February 2023
date: '2023-02-01 08:22'
tags: 
  - daily bits
categories: 
  - Daily Bits
---

20230209

- Worked with Danielle Becker, as part of the Coral E5 project, to transfer data related to [this repo](https://github.com/hputnam/Becker_E5), from her HPC (Univ. of Rhode Island; Andromeda) to ours (Univ. of Washington; Mox) in order to eventually transfer to Gannet so that these files are publicly accessible to all members of the Coral E5 project.

  - GlobusConnect did not work. Couldn't figure out how to make URI endpoint accessible.

  - URI IT provide a solution via [rclone](https://rclone.org/), involving transferring the data from an Amazon S3 bucket. `rclone` setup info is below, but I've removed the access key info:

    ```
    [becker]
    type = s3
    provider = Ceph
    access_key_id = C6IHOMBWWBAC10UY4I87
    secret_access_key = Y24jMNaMZCiw9Wr2GftibTC+ue+a5y
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