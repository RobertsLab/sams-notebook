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
[Aidan recently needed to use R on a machine with more memory](https://github.com/RobertsLab/resources/discussions/1180). Additionally, it would be ideal if he could use RStudio. So, I managed to figure out how to set up a Singularity container running [rocker/rstudio](https://github.com/rocker-org/rocker).

For those of you not interested in the process, just jump over to our [handbook guide on how to use the container to run RStudio Server on Mox (or, build your own)](https://robertslab.github.io/resources/mox_RStudio-Server/).

Now, for the lengthy, and probably unneccessary, parts... Sometimes it's useful to document the pain. 

The UW high-perfomance computing (HPC) cluster, Hyak, used to have an RStudio Server module installed, as well as instructions on how to get it going. However, that module no longer exists, so wasn't usable. I hit up UW IT and they directed me to this [Rocker SLURM job example.](https://www.rocker-project.org/use/singularity/).  After a few different attempts to get this work, I finally found someone else who's had the same issue! 

I created a [functional SLURM script modified from this GitHub Issue](https://github.com/rocker-org/rocker-versioned2/issues/105#issuecomment-799848638) and it totally worked! Except, due to the fact that a SLURM script is run on a [execute/compute node on Mox](https://robertslab.github.io/resources/mox_Node-Types/#execute-node), there's no internet access; which means no installing new packages via RStudio Server when it's running on Mox. Although I haven't documented it yet, I was unable to get this to work on [build node on Mox](https://robertslab.github.io/resources/mox_Node-Types/#build-node) (which _does_ have internet access) because parts of the process require the use of `sudo` which isn't available on Mox.

So, I turned to installing Singularity on my own computer and building/updating the container locally. Singularity installation didn't go as smoothly as I would've hoped, but I eventually found this [Singularity installation guide](https://github.com/hpcng/singularity/issues/4765#issuecomment-814564188) (GitHub Issue) which took care of any issues I had encountered.

To retrieve the container from Rocker _and make it accessible_, I needed to build it as a sandbox. The command below also specifies to pull Rstudio with R v4.0.2.

`singularity build --sandbox rstudio-4.0.2.sandbox.simg docker://rocker/rstudio:4.0.2`

From here, I learned how to get into the container, which would potentially allow me to update/install system and R packages, but you need root access inside the container. To get that, I ran:

`sudo singularity shell rstudio-4.0.2.sandbox.simg/`

![screenshot showing differences in singularity with/without sudo](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210423_singularity_rstudio_root.png?raw=true)

I also quickly learned that the container needs to be writable:

![screenshot of not writable](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210423_singularity_rstudio_root-not-enough.png?raw=true)

![screenshot of writable](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210423_singularity_rstudio_root-writable.png?raw=true)

After making some feable attempt to install some R packages, I encountered a number of errors indicating missing system packages. Those were installed via the shell in the container:

Install libbz2:

`apt install libbz2-dev`

Install liblzma:

`apt install liblzma-dev`

Install libxml2

`apt install libxml2`

Install libz-dev

`apt install libz-dev`

Install libxtst6 to allow R Markdown image rendering:

`apt install libxtst6`

After resolving those issues, I could start R and install stuff:

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

![first error](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210423_singularity_rstudio_deseq2-delayedarray.png?raw=true)

![second error](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210423_singularity_rstudio_deseq2-matrixgenerics.png?raw=true)

MatrixGenerics:

```R
BiocManager::install("MatrixGenerics")
```

Error:

![matrixStats version too old](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210423_singularity_rstudio_deseq2-matrixstats.png?raw=true)

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

tidyverse:

```R
install.packages("tidyverse")
```


After getting all the desired packages installed, I needed to actually build the container image. The image is a single file, whereas the sandbox representation is actually a way to interact with all the system directories.


Build container (from [StackOverFlow](https://stackoverflow.com/questions/60155573/how-to-export-a-container-in-singularity)):

`sudo singularity build rstudio-4.0.2.sjw-01 rstudio-4.0.2.sandbox.simg/`

This container image was then rsync'd to the following Mox location for everyone to access:

`/gscratch/srlab/programs/singularity_containers`

This will suffice for now to allow people to play around/test/use it for some things. However, there are other things I'd like to work on:

- Ideally, get this set up to be able to build containers on a Mox build node.

- Get Singularity installed on one of the birds (e.g. Emu, Roadrunner) so that people can build their own containers. Singularity is only avialbe for Linux, thus most other lab members won't be able to use their own computers to build containers; they'll need one of the birds which run Ubuntu.