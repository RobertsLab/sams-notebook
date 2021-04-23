---
layout: post
title: Singularity - RStudio Server Container on Mox
date: '2021-04-23 10:18'
tags: 
  - computing
  - Rstudio Server
  - mox
  - singularity
categories: 
  - Miscellaneous
---

[Singularity installation guide](https://github.com/hpcng/singularity/issues/4765#issuecomment-814564188) (GitHub Issue).

Build as sandbox:

`singularity build --sandbox rstudio-4.0.2.sandbox.simg docker://rocker/rstudio:4.0.2`


Need root access inside the container:

`sudo singularity shell rstudio-4.0.2.sandbox.simg/`

![screenshot showing differences in singularity with/without sudo]()

And, needs to be writable:

![screenshot of not writable]()

![screenshot of writable]()

Install libxml2

`apt install libxml2`

Install libz-dev

`apt install libz-dev`

Start R and install stuff:

BioConductor:

```R
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install(version = "3.12")
```

DESeq2:

```R
BiocManager::install("DESeq2")
```

Errors:

![first error]()

![second error]()

MatrixGenerics:

```R
BiocManager::install("MatrixGenerics")
```

Error:

![matrixStats version too old]()

matrixStats:

```R
install.packages("https://cran.rstudio.com/src/contrib/matrixStats_0.58.0.tar.gz", repos=NULL, type="source")
```

Methylkit:

```R
BiocManager::install("methylKit")
```

WGCNA:

```R
BiocManager::install("WGCNA")
```

Install libbz2:

`apt install libbz2-dev`

Install liblzma:

`apt install liblzma-dev`

Build container (from [StackOverFlow](https://stackoverflow.com/questions/60155573/how-to-export-a-container-in-singularity)):

`sudo singularity build rstudio-4.0.2.sjw-01 rstudio-4.0.2.sandbox.simg/`

[Rocker SLURM job example.](https://www.rocker-project.org/use/singularity/)

[Working SLURM script modified from this GitHub Issue](https://github.com/rocker-org/rocker-versioned2/issues/105#issuecomment-799848638).