---
layout: post
title: Data Wrangling - Create P.verrucosa GCA_014529365.1 Karyotype File
date: '2023-02-15 12:04'
tags: 
  - Pocillopora verrucosa
  - coral
  - jupyter
  - GCA_014529365.1
  - karyotype
categories: 
  - E5
---
[Steven asked that I create a karyotype file](https://github.com/RobertsLab/resources/issues/1580) (GitHub Issue) from the NCBI _P.verrucosa_ genome ([GCA_014529365.1](https://www.ncbi.nlm.nih.gov/data-hub/genome/GCA_014529365.1/)) in the following format:

`name\tlength` (read: `name` `<tab>` `length`)

This was a very quick process, using the FastA Index file and `awk`. In fact, the Jupyter Notebook entry and this notebook entry have taken me far, far longer to put together than the commands to generate the desired output file. The commands were recorded in the following Jupyter Notebook file.

- [20230215-pver-GCA_014529365.1-karyotype.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20230215-pver-GCA_014529365.1-karyotype.ipynb) (GitHub)

- [20230215-pver-GCA_014529365.1-karyotype.ipynb](https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230215-pver-GCA_014529365.1-karyotype.ipynb) (NBviewer)


<iframe src="https://nbviewer.org/github/RobertsLab/code/blob/master/notebooks/sam/20230215-pver-GCA_014529365.1-karyotype.ipynb" width="100%" height="1000" scrolling="yes"></iframe>


---

#### RESULTS

Output folder:

- [20230215-pver-GCA_014529365.1-karytoype/](https://gannet.fish.washington.edu/Atumefaciens/20230215-pver-GCA_014529365.1-karytoype/)

  #### Output file (txt)

  - [20230215-pver-GCA_014529365.1-karytoype/GCA_014529365.1-pver-karytotype-name_length.tab](https://gannet.fish.washington.edu/Atumefaciens/20230215-pver-GCA_014529365.1-karytoype/GCA_014529365.1-pver-karytotype-name_length.tab)

    - Preview:

      ```
      JAAVTL010000001.1 	 2095917
      JAAVTL010000002.1 	 2081954
      JAAVTL010000003.1 	 1617595
      JAAVTL010000004.1 	 1576134
      JAAVTL010000005.1 	 1560107
      JAAVTL010000006.1 	 1451149
      JAAVTL010000007.1 	 1442001
      JAAVTL010000008.1 	 1404416
      JAAVTL010000009.1 	 1375744
      JAAVTL010000010.1 	 1318009
      ```

    - MD5 checksum: `5aafd422505f26c0793a3b88abe0359f`

