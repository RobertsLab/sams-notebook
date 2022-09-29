---
layout: post
title: Daily Bits - September 2022
date: '2022-09-02 07:37'
tags: 
  - daily bits
  - September
categories: 
  - Daily Bits
---

20220928

- Worked extensively on Circos stuff for CEABIGR project again. Primarily generating Circos-formatted gene expression/methylation files. See [CEABIGR `50-circos-formatting` directory](https://github.com/sr320/ceabigr/tree/main/output/50-circos-formatting).

---

20220927

- Worked extensively on Circos stuff for CEABIGR project. Had to fix some R code, as well as file formatting, bash scripts, and learning how to manipulate the `circos.conf` file. Actually generated a plot:

  ![Circos plot showing the C.virginica chromosome, NC_035781.1, as the black outer ring, with control female mean gene expression values (black inner ring) and exposed female mean gene expression values (green inner ring)](https://user-images.githubusercontent.com/4514104/192628263-9272ef7f-c73c-473d-a7b1-970cb3014e86.png)

---

20220926

- `epidiverse/snp` pipeline completed, so transferred data and wrote up [notebook entry]().

- Generated CEABIGR mean gene expression files, formatted for Circos usage.


---

20220923

- Resubmitted `epidiverse/snp` pipeline on Mox for [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) because I forgot that the pipeline has an aritficial cap of 10 BAMs. Edited the `nextflow.config` file to increase cap to 50 _and_ added code in the `bio_DNA-methylation.md` doc to count the number of BAMs and specify the `epidiverse/snp` command to use that number of BAMs. Prevents the aritficial limit from having any impact.

- Science Hour. Helped Matt with some Mox/Trinity (system `$PATH` stuff).

---

20220922

- Updated [ceabigr predominant isoform R Markdown](https://github.com/sr320/ceabigr/blob/main/code/42-predominant-isoform.Rmd) (GitHub) to generate files for control/exposed female samples.

- Due to issue with R loading a package and getting this error: `libgsl.so.23: cannot open shared object file: No such file or directory`, I came across some suggestions that if your current version of R was built with a previous version of Ubuntu (which happens to be my case, since I upgraded Ubuntu earlier this month), I decided to upgrade and build R. Took awhile to compile... I also ended up having to re-install packages. Ugh!

- Initiated `epidiverse/snp` pipeline on Mox for [_Crassostrea virginica_ (Eastern oyster)](https://en.wikipedia.org/wiki/Eastern_oyster) Bismark BAMs, per [this GitHub Issue](https://github.com/sr320/ceabigr/issues/69).

---

20220921

- Updated [ceabigr predominant isoform R Markdown](https://github.com/sr320/ceabigr/blob/main/code/42-predominant-isoform.Rmd) (GitHub) to include vectors containing sample types, as well as generate files for control/exposed male samples.

- Finished [notebook entry for geoduck HISAT2 alignments for lncRNA](https://robertslab.github.io/sams-notebook/2022/09/14/RNAseq-Alignments-P.generosa-Alignments-and-Alternative-Transcript-Identification-Using-Hisat2-and-StringTie-on-Mox.html).

- Read more Circos info.

---

20220920

- [ceabigr](https://github.com/sr320/ceabigr) meeting with Yaamini. Decided to generate list of genes with differing predominant isoforms between females and males - these were the only two comparisons Steven had produced so far. List will also use a binary system (i.e. `0` or `1` to indicate no different or different, respectively).

  - Generated file(s). See [this Jupyter Notebook](https://github.com/sr320/ceabigr/blob/main/code/20220920-cvir-ceabigr-predominant_isoform-female_male.ipynb) (GitHub).

---

20220919

- Did I finally fix the [SBATCH script for geoduck Hisat2 alignments](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms.sh)? It's looking that way...

- CEABIGR Circos stuff

  - `awk 'BEGIN {OFS="\t"} {print "cvir"$1, $2, $3}' C_virginica-3.0_Gnomon_genes.bed > C_virginica-3.0_Gnomon_genes.bed.circos`

  - Continued reading documentation.

- Got distracted exploring how to get a list of all existing GO IDs. The idea being to then map all GOslims to the GO IDs and create a "flat" file that can be used for joining. Mostly reading about using the `GO.db` library in R and how to extract information.

---

20220916

- Science Hour

- Continued troubleshooting [SBATCH script for geoduck Hisat2 alignments](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms.sh). Despite declaring success yesterday, still realized the script wasn't running properly. Grrrrrr....

---

20220915

- Retrieved GOslims for single cell RNAseq (scRNAseq) project, per [this GitHub Issue](https://github.com/RobertsLab/resources/issues/1523).

- Pub-a-thon

- Permanantly fixed [SBATCH script for geoduck Hisat2 alignments](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms.sh) and succsufully ran, as part of the lncRNA identification.

---

20220914

- Installed [Circos](http://circos.ca/support/getting_started/) on my computer (VM Ubuntu 22.04LTS):

  - Couldn't install needed library:

    ```shell
    sudo apt-get -y install libgd2-xpm-dev
    E: Unable to locate package libgd2-xpm-dev
    ```

    Possible fix is: `sudo apt-get -y install libgd-dev`

  - Missing Perl modules:

    ```shell
    sam@computer:~/programs/circos-0.69-9/bin$ ./circos -modules
    ok       1.52 Carp
    ok       0.45 Clone
    missing            Config::General
    ok       3.80 Cwd
    ok      2.179 Data::Dumper
    ok       2.58 Digest::MD5
    ok       2.85 File::Basename
    ok       3.80 File::Spec::Functions
    ok     0.2311 File::Temp
    ok       1.52 FindBin
    missing            Font::TTF::Font
    missing            GD
    missing            GD::Polyline
    ok       2.52 Getopt::Long
    ok       1.46 IO::File
    missing            List::MoreUtils
    ok       1.55 List::Util
    missing            Math::Bezier
    ok   1.999818 Math::BigFloat
    missing            Math::Round
    missing            Math::VecStat
    ok    1.03_01 Memoize
    ok       1.97 POSIX
    missing            Params::Validate
    ok       2.01 Pod::Usage
    missing            Readonly
    missing            Regexp::Common
    missing            SVG
    missing            Set::IntSpan
    missing            Statistics::Basic
    ok       3.23 Storable
    ok       1.23 Sys::Hostname
    ok       2.04 Text::Balanced
    missing            Text::Format
    ok     1.9767 Time::HiRes
    ```
    Needed to install `cpanm`:

    `apt-get install cpanminus`

    Then:

    `sudo cpanm Clone Config::General Font::TTF::Font GD GD::Polyline List::MoreUtils Math::Bezier Math::Round Math::VecStat Params::Validate Readonly Regexp::Common SVG Set::IntSpan Statistics::Basic Text::Format`

    Got me to this:

    ```shell
    sam@computer:~/programs/circos-0.69-9/bin$ ./circos -modules
    ok       1.52 Carp
    ok       0.45 Clone
    ok       2.65 Config::General
    ok       3.80 Cwd
    ok      2.179 Data::Dumper
    ok       2.58 Digest::MD5
    ok       2.85 File::Basename
    ok       3.80 File::Spec::Functions
    ok     0.2311 File::Temp
    ok       1.52 FindBin
    ok       0.39 Font::TTF::Font
    ok       2.76 GD
    ok        0.2 GD::Polyline
    ok       2.52 Getopt::Long
    ok       1.46 IO::File
    ok      0.430 List::MoreUtils
    ok       1.55 List::Util
    ok       0.01 Math::Bezier
    ok   1.999818 Math::BigFloat
    ok       0.07 Math::Round
    ok       0.08 Math::VecStat
    ok    1.03_01 Memoize
    ok       1.97 POSIX
    ok       1.30 Params::Validate
    ok       2.01 Pod::Usage
    ok       2.05 Readonly
    ok 2017060201 Regexp::Common
    ok       2.87 SVG
    ok       1.19 Set::IntSpan
    ok     1.6611 Statistics::Basic
    ok       3.23 Storable
    ok       1.23 Sys::Hostname
    ok       2.04 Text::Balanced
    ok       0.62 Text::Format
    ok     1.9767 Time::HiRes
    ```

    Successfully generated test images!

- Tidied up a bunch of things in the [SBATCH script for geoduck RNAseq HiSat alignments](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms.sh) in order to get it to run properly. Currently waiting in queue...

- Updated (circos_pgen_karyotype.sh)[https://github.com/RobertsLab/sams-notebook/blob/master/bash_scripts/circos_pgen_karyotype.sh] bash script to allow passing arguments for species abbreviation and FastA index file.

---

20220913

- ceabigr meeting

- Finished (I hope!) [SBATCH script for geoduck RNAseq HiSat alignments](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20220914-pgen-hisat2-Panopea-generosa-v1.0-index-align-stringtie_isoforms.sh) for [eventual lncRNA id](https://github.com/RobertsLab/resources/issues/1434). Lots of ins and outs and what-have-yous for this thing... Will execute tomorrow when Mox is back online (offline today for maintenance).

---

20220912

- Lab meeting.

- Oyster gene expression (ceabigr) meeting with Steven & Yaamini.

  - Need to [make some CIRCOS plots](https://github.com/sr320/ceabigr/issues/70)

  - Need to [revist Epi-Diverse stuff and add to wiki](https://github.com/sr320/ceabigr/issues/69)

- Continued work on SBATCH script for geoduck RNAseq HiSat alignments for [eventual lncRNA id](https://github.com/RobertsLab/resources/issues/1434).

---

20220909

- Science Hour and Pub-a-thon

- Started working on SBATCH script for geoduck RNAseq HiSat alignments for [eventual lncRNA id](https://github.com/RobertsLab/resources/issues/1434).

---

20220908

- lab meeting

- transferred data to Mox, prepared SBATCH script and trimmed geoduck RNAseq data in preparation for [identifying long non-coding RNA](https://github.com/RobertsLab/resources/issues/1434)

---

20220907

- Computer maintenance: upgraded my laptop Ubuntu virtual machine from 20.04LTS to 22.04LTS.

- ProCard reconcilation.

- transferred geoduck RNAseq files to Mox in preparation for long non-coding RNA identification.

---

20220906

- Computer maintenance: backed up my laptop virtual machine (took a very long time) to my home server.

- Helped with [Zach's GitHub Issue regarding PCR caps vs. films](https://github.com/RobertsLab/resources/issues/1520).

- Helped with [Marta's GitHub Issue with running a support script in `stacks`](https://github.com/RobertsLab/resources/issues/1516#issuecomment-1238614587).

- ProCard reconciliation.

- Technical issue with accessing the Lab Safety Report Dashboard. Resolved late this afternoon.

---

20220901

- Continued to mess around with [Mixomics R package tutorials](https://mixomicsteam.github.io/Bookdown/pls.html). Here's R Markdown used, as well as some of the plots that were produced (PCA and sparse PCA). Overall, sex is driving factor of differences in gene expression (FPKM) and average gene methylation.

Put together a quick R Markdown doc to go through the tutorial using our gene FPKM expression data and average gene methylation data (generated by Steven):

[https://rpubs.com/kubu4/cvir-gonad-oa-mixomics_testing](https://rpubs.com/kubu4/cvir-gonad-oa-mixomics_testing)

Some screenshots of plots generated:

![PCA plot comparing impacts of average gene methylation, OA exposure, and sex. Orange shapes are males. Blue shapes are female. Circles are control water conditions. Triangles are exposed to OA water conditions. Oranges (males) are all grouped together on the left side of the PCA plot. Females are all grouped together on the right side of the PCA plot.](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20220901-daily_bits-mixomics-gene_methylation-PCA.png?raw=true)

![Sparse PCA plot (sPCA) comparing impacts of average gene methylation, OA exposure, and sex. Orange shapes are males. Blue shapes are female. Circles are control water conditions. Triangles are exposed to OA water conditions. Oranges (males) are all grouped together on the upper left side of the sPCA plot. Females are all grouped together on the upper right side of the sPCA plot. A single, blue triangle is on the bottom right side of the sPCA plot.](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20220901-daily_bits-mixomics-gene_methylation-sPCA.png?raw=true)


![Screenshot showing list of genes and the sPCA loading values contributing the most to the sPCA Comp 1 from above. List is followed by bar plot to visualize the loadings in the list above.](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20220901-daily_bits-mixomics-gene_methylation-sPCA-loadings_comp1.png?raw=true)


![A Sparse Projection to Latent Structure (sPLS) plot of C.virginica gonad gene expression (FPKM) values and gene average methylation values. Blue letters are control water conditions. Orange letters are exposed OA water conditions. The letter 'F' represents females. The letter 'M' represents males. All females are tightly clusterd in the lower left corner. All males are tightly clustered in the lower right corner.](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20220901-daily_bits-mixomics-gene_methylation-sPLS.png?raw=true)