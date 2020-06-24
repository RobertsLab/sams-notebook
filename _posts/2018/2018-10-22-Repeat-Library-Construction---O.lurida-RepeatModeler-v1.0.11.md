---
layout: post
title: Repeat Library Construction - O.lurida RepeatModeler v1.0.11
date: '2018-10-22'
tags:
  - emu
  - repeatmodeler
  - jupyter notebook
  - Ostrea lurida
  - olympia oyster
categories:
  - Olympia Oyster Genome Sequencing
---

In further attempts to improve our _Ostrea lurida_ genome annotation, I decided to generate a species-specific repeat library for use with MAKER genome annotation using [RepeatModeler](https://www.repeatmasker.org/RepeatModeler/).

Ran on both versions of our _O.lurida_ genome assemblies. Details on assemblies can be found on our [Genomic Resources wiki (GitHub)](https://github.com/RobertsLab/resources/wiki/Genomic-Resources#ostrea-lurida).

- [Olurida_v080.fa](https://owl.fish.washington.edu/halfshell/genomic-databank/Olurida_v080.fa)

- [Olurida_v081.fa (only contigs >1000bp)](https://owl.fish.washington.edu/halfshell/genomic-databank/Olurida_v081.fa)

Tasks were run on Emu (Apple Xserve; Ubuntu 16.04). All operations were performed in the following Jupyter Notebook (GitHub):

- [20181022_emu_oly_repeatmodeler.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20181022_emu_oly_repeatmodeler.ipynb)

---

#### RESULTS

Each run took ~1.5days to complete.

Output folders:

- [20181022_Olurida_v080_repeatmodeler/](https://gannet.fish.washington.edu/Atumefaciens/20181022_Olurida_v080_repeatmodeler/)

- [20181022_Olurida_v081_repeatmodeler/](https://gannet.fish.washington.edu/Atumefaciens/20181022_Olurida_v081_repeatmodeler/)

Repeats FastAs:

- [Ostrea_lurida_v080-families.fa (1.3MB)](https://gannet.fish.washington.edu/Atumefaciens/20181022_Olurida_v080_repeatmodeler/Ostrea_lurida_v080-families.fa)

- [Ostrea_lurida_v081-families.fa (1.3MB)](https://gannet.fish.washington.edu/Atumefaciens/20181022_Olurida_v081_repeatmodeler/Ostrea_lurida_v081-families.fa)

Will use these repeat libraries in subsequent MAKER genome annotations.
