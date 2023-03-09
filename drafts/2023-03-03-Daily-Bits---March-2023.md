---
layout: post
title: Daily Bits - March 2023
date: '2023-03-03 10:12'
tags: 
  - daily bits
categories: 
  - Daily Bits
---

20230308

- Spent all day (seriously) working on [this GitHub Issue to update our geoduck gene annotations file](https://github.com/RobertsLab/resources/issues/1602) to include GOslim and "aspect" (i.e. Biological Process, Molecular Function, or Celullar Component). Unfortunately, this is kind of complicated. Here's the process I'm (attempting) to employ:

  1. Get GOslims:

    - Doing this using GSEAbase (R/Bioconductor package). Process is easy, but I feel there's small bug where a GO ID doesn't get mapped to "itself" if it's a GOslim/parent ID.

    - Keeping gene IDs so that they can remain associated with the input GO IDs. This was solved in [this Bioconductor support forum](https://support.bioconductor.org/p/128430/).

  2. Join with the existing annotation file ([https://gannet.fish.washington.edu/Atumefaciens/20220419-pgen-gene_annotation_mapping/20220419-pgen-gene-accessions-gene_id-gene_name-gene_description-alt_gene_description-go_ids.tab](https://gannet.fish.washington.edu/Atumefaciens/20220419-pgen-gene_annotation_mapping/20220419-pgen-gene-accessions-gene_id-gene_name-gene_description-alt_gene_description-go_ids.tab)).

    - This _should_ be relatively straight forward (hopefully I didn't jinx myself!) once I'm able to get the "missing" GO/GOslim mapping problem resolved.

---

20230303

- Science Hour

  - Steven tested HiSat2 alignment rates when specifying (or not) exons and splice sites using some coral FastQs and the _M.capitata_ genome. Result - very little difference (< 1%).

- Oyster Epigenetics meeting w/Lotterhos Lab.

---

20230302

- In lab

  - Fixed an issue on Raven where an error message pops up during reboot indicating there's a fan response failure. This was a problem because there was no way to bypass/acknowledge this error remotely, thus preventing reboot without someone being physically at the computer to acknowledge the error. Turns out, [Dell has a support page on how to handle this issue](https://www.dell.com/support/kbdoc/en-us/000128139/precision-7920-tower-epsa-fan-error-the-fan-failed-to-respond-correctly), and the solution was to go into the Bios and turn off the HDD fans for fan power pins in which no fan was actually connected!

  - Attempted to fix issue on Raven where the desktop is not accessible. After reboot, the screen is just a series of lines of boot info with an `[OK]` printed at the beginning of each line. This does not affect remote access via `ssh`, but prevents users from trying to use the computer when physically sitting at Raven. I suspect, but haven't confirmed, that this also prevents remote desktop connections. Tried many, many things (altering `/etc/default/grub`, switching to `lightdm` from `dgm3` and back, installing the correct video drivers for the video card - AMD Radeon PRO WX 2100, trying to boot in safe graphics mode) all to no avail.

    I did find [a Dell knowledge base solution addressing this](https://www.dell.com/support/kbdoc/en-us/000132211/ubuntu-18-04-fails-to-boot-and-hangs-on-a-black-screen) and the solution is to reinstall the OEM operating system with the monitor plugged into a different video card!

---

20230301

- Transferred trimmed _C.magister_ RNA-seq data from Google Drive to our HPC (Mox) using `rclone`. This was a great suggestion from Giles Goetz! Additionally, the `rclone` website has [a great explanation on how to configure a connection to Google Drive](https://rclone.org/drive/). The key to doing this, though, was specifying `--drive-shared-with-me` option. Without that, the shared drive was not visible/accessible. In the code below, `noaa-crab` is the name of the configuration I set up following the instructions linked above.

    ```shell
    rclone-v1.61.1-linux-amd64/rclone \
    copy \
    --progress \
    --drive-shared-with-me \
    noaa-crab:202301-dungeness_crab-transcriptome/ \
    ./
    ```

- Worked on, and finished, generating the comprehensive CEABIGR CSV [Steven requested in this GitHub Issue](https://github.com/RobertsLab/resources/issues/1566).