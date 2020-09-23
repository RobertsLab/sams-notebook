---
layout: post
title: Data Wrangling - Subsetting cbai_genome_v1.0 Assembly with faidx
date: '2020-09-23 11:17'
tags:
  - faidx
  - Tanner crab
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
[Previously assembled `cbai_genome_v1.0.fasta` with our NanoPore Q7 reads on 20200917](https://robertslab.github.io/sams-notebook/2020/09/17/Genome-Assembly-C.bairdi-cbai_v1.0-Using-All-NanoPore-Data-With-Flye-on-Mox.html) and noticed that there were numerous sequences that were well shorter than the expected 500bp threshold that the assembler ([Flye](https://github.com/fenderglass/Flye)) was supposed to spit out. I [created an Issue on the Flye GitHub page](https://github.com/fenderglass/Flye/issues/304) to find out why. The developer responded and determined it was an issue with the assembly polisher and that sequences <500bp could be safely ignored.

So, I've decided to subset the `cbai_genome_v1.0.fasta` to exclude all sequences <1000bp, as that seems like a more reasonable minimum length for potential genes. I did not run this in a Jupyter Notebook, due to the brevity of the commands. Here are the commands, using [```faidx```](https://github.com/mdshw5/pyfaidx):


#### >1kbp subsetting
```
faidx --size-range 1000,1000000000 cbai_genome_v1.0.fasta > cbai_genome_v1.01.fasta
```

#### Index new FastA
```
faidx Pgenerosa_v071.fasta
```

```shell
samb@mephisto:~/data/C_bairdi/genomes$ sort -nk2,2 cbai_genome_v1.01.fasta.fai | head

contig_4272	1000	15642836	60	61
contig_4503	1000	16422183	60	61
contig_4429	1001	16145927	60	61
contig_1038	1002	230201	60	61
contig_1691	1005	1716551	60	61
contig_2992	1005	7322005	60	61
contig_3284	1006	9674445	60	61
contig_1810	1008	2050977	60	61
contig_408	1008	15069716	60	61
contig_1616	1009	1549839	60	61
```

Subsetting looks like it worked.

Looking at sequence counts in FastAs:

```shell
samb@mephisto:~/data/C_bairdi/genomes$ for file in *.fasta; do grep --with-filename -c ">" $file; done

cbai_genome_v1.01.fasta:2431
cbai_genome_v1.0.fasta:3294
```

---

#### MD5 checksums
`5a08d8b0651484e3ff75fcf032804596  cbai_genome_v1.01.fasta`

---

Any future work with _C.bairdi_ genome assemblies will be with `cbai_genome_v1.01.fasta` (until a better assembly comes along).

All files were copied to our [genomic databank](http://owl.fish.washington.edu/halfshell/genomic-databank/) on Owl.

See our [Genomic Resources wiki (GitHub)](https://github.com/RobertsLab/resources/wiki/Genomic-Resources) for a more concise overview.
