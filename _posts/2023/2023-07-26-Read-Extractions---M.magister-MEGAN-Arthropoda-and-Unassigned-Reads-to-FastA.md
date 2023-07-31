---
layout: post
title: Read Extractions - M.magister MEGAN Arthropoda and Unassigned Reads to FastA
date: '2023-07-26 06:50'
tags: 
  - Metacarcinus magister
  - Dungeness crab
  - MEGAN
categories: 
  - DuMOAR
---
After [converting DIAMOND BLASTx/MEGAN DAA files to RMA6 and looking at the taxonomic breakdown of each sample](https://robertslab.github.io/sams-notebook/2023/07/02/File-Conversion-M.magister-MEGANized-DAA-to-RMA6.html) (notebook entry), it was decided we should extract reads from `Arthropoda` (and all taxonomies below) and all `Unassigned` reads from each sample. To do so, I used [MEGAN6 Community Edition](https://software-ab.cs.uni-tuebingen.de/download/megan6/welcome.html).

Unfortunately, the Community Edition doesn't provide command-line tools to perform this task, so it had to be done via the GUI. As such, it took a couple of days to go through all of these. See the [MEGAN log file](#megan-log) for a computer-generated record of what was selected in the GUI for each file. Reads are extracted as FastAs. After FastA extraction, I'll go back to the trimmed FastQs and use the FastAs to extract reads in FastQ format.

---

#### RESULTS

Output folder:

- [20230726-mmag-read_extraction](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/)

#### MEGAN Log

- [MEGAN-log.txt](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/)

  - Since extractions were performed using the GUI, this file is the only computer-generated record of what was selected for extraction.

#### FastA Files

- [CH01-06.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH01-06.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (608M)

  - MD5: `cf5c9f9f4ca98e49ad92eb57f4a0de0b`

- [CH01-06.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH01-06.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (612M)

  - MD5: `66df16af1a44a7491d053cb1995c5880`

- [CH01-14.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH01-14.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (1.1G)

  - MD5: `fd81ac48f2dfbb1e9baee926265660e6`

- [CH01-14.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH01-14.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (1.1G)

  - MD5: `12facf9917b418952bc732e5772d7f3a`

- [CH01-22.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH01-22.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (696M)

  - MD5: `124e669eae1bbc652134ce50a2e4d2f7`

- [CH01-22.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH01-22.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (705M)

  - MD5: `87aeab58b98dc88143ca3fbfc9dd063a`

- [CH01-38.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH01-38.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (1.2G)

  - MD5: `8f5cd5b04c9e5261463a0a9c5b32974e`

- [CH01-38.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH01-38.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (1.2G)

  - MD5: `8ab6a162f5cbc114d05e560500e51232`

- [CH03-04.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH03-04.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (610M)

  - MD5: `27fd7754c2ccfe956cb43759bdf863be`

- [CH03-04.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH03-04.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (614M)

  - MD5: `e64bc93b265e2f6a8e0ce2ec0cecde9a`

- [CH03-15.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH03-15.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (813M)

  - MD5: `c3a15b025b50c75364a61aa22ef92d9d`

- [CH03-15.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH03-15.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (825M)

  - MD5: `8863c6a6187b4f1f34ea0e71e336ecc2`

- [CH03-33.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH03-33.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (712M)

  - MD5: `54c123113c083d9dd180ad6222421597`

- [CH03-33.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH03-33.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (725M)

  - MD5: `1dba4ed96ab54702cea1e489fa3a7de5`

- [CH05-01.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH05-01.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (755M)

  - MD5: `3150af6e6c5cd1aeeb35ff2d6f405509`

- [CH05-01.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH05-01.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (764M)

  - MD5: `d42008f8d4f639e24a3544f9a97c4dac`

- [CH05-06.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH05-06.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (621M)

  - MD5: `eae6beacf4d3d22b87972fa21556078c`

- [CH05-06.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH05-06.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (626M)

  - MD5: `6909396b60061064a67145a80629a75d`

- [CH05-07.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH05-07.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (711M)

  - MD5: `f8a99d6cb069ad3ad46028cfe7fb2250`

- [CH05-07.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH05-07.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (724M)

  - MD5: `ac1adb6163fb13f3819c4b739b96a905`

- [CH05-09.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH05-09.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (986M)

  - MD5: `1ecd8619aecae2d58b78a907f6327d93`

- [CH05-09.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH05-09.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (1001M)

  - MD5: `53cf5394bf9a62c8f5166ad8bb69b2ff`

- [CH05-14.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH05-14.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (893M)

  - MD5: `09a54301f35be158319d573204593ad8`

- [CH05-14.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH05-14.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (899M)

  - MD5: `81513f5fbe5355214b048fdd0f164fa7`

- [CH05-21.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH05-21.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (935M)

  - MD5: `f45a8fbffd7b11da5d759be094ff5344`

- [CH05-21.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH05-21.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (942M)

  - MD5: `d97de57f53b5dd68458321241b151b26`

- [CH05-29.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH05-29.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (874M)

  - MD5: `b1253087cf5a1fafcad44f82ced38d4c`

- [CH05-29.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH05-29.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (870M)

  - MD5: `eec7ff7b2c92d917e7988f0942abf0c3`

- [CH07-04.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH07-04.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (476M)

  - MD5: `f8c8b987cc670d22a50ac35c170e8ca1`

- [CH07-04.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH07-04.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (481M)

  - MD5: `8a2eace9f9ba3fd667dbdca122a5bb61`

- [CH07-06.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH07-06.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (743M)

  - MD5: `166cf4c77153cce2f833c1a72b3708b9`

- [CH07-06.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH07-06.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (751M)

  - MD5: `64fb965ee601684d31853ff893ba6848`

- [CH07-08.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH07-08.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (1.4G)

  - MD5: `0445b88359d8c69b34e7f3b4646c5a9f`

- [CH07-08.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH07-08.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (1.4G)

  - MD5: `0fe5862a38b3bda04c7f4970af02aa3c`

- [CH07-11.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH07-11.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (1.1G)

  - MD5: `7e09213400e7236bae3e60e411cac0bf`

- [CH07-11.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH07-11.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (1.1G)

  - MD5: `20af48e7b983eb2a17573081cea677da`

- [CH07-24.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH07-24.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (1.1G)

  - MD5: `407e067299e23609e4ff353e81705e63`

- [CH07-24.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH07-24.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (1.1G)

  - MD5: `016cda1c262b3970d383acc1d3083545`

- [CH09-02.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH09-02.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (638M)

  - MD5: `8eb16a939fae131088d15ffcf71f0158`

- [CH09-02.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH09-02.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (643M)

  - MD5: `c17336b0b30c07bf3bda6c7c4ca95aa2`

- [CH09-13.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH09-13.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (690M)

  - MD5: `ed2167d64e530500146b972c901d5bc7`

- [CH09-13.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH09-13.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (699M)

  - MD5: `71a617b64cedfc0b5c8e8a6440fe5da7`

- [CH09-28.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH09-28.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (607M)

  - MD5: `ad131a6ce4aaf4ffbb414c203a960e04`

- [CH09-28.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH09-28.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (625M)

  - MD5: `03133926a760ad8f05652865c84261dc`

- [CH10-08.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH10-08.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (818M)

  - MD5: `f8cc75f2083fe580ba4ff66adce7da48`

- [CH10-08.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH10-08.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (823M)

  - MD5: `d25cf1241dc19f592e5f202ed9a8a1bb`

- [CH10-11.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH10-11.trimmed.R1-MEGAN_summarized_reads-arthropoda_NA.fasta) (795M)

  - MD5: `873ec46bc3dcd1e5bd4a5c75d64da9d4`

- [CH10-11.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta](https://gannet.fish.washington.edu/Atumefaciens/20230726-mmag-read_extraction/CH10-11.trimmed.R2-MEGAN_summarized_reads-arthropoda_NA.fasta) (810M)

  - MD5: `3ee44831768928ce43b7188a06072199`