---
layout: post
title: Containers - Apptainer Explorations
date: '2023-04-28 14:25'
tags: 
  - apptainer
  - singularity
  - klone
  - mox
categories: 
  - Miscellaneous
---


Create base image:

```bash
apptainer build \
--sandbox \
--fakeroot \
/tmp/ubuntu-22.04.sandbox ./ubuntu-22.04.def \
&& apptainer build \
/tmp/ubuntu-22.04.sif /tmp/ubuntu-22.04.sandbox \
&& mv /tmp/ubuntu-22.04.sif .
```

Create `bedtools` container, based on base image above:

```bash
apptainer build \
/tmp/bedtools-2.29.1.sif ./bedtools-2.29.1.def \
&& mv /tmp/bedtools-2.29.1.sif .
```



