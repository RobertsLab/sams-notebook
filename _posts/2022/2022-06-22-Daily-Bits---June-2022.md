---
layout: post
title: Daily Bits - June 2022
date: '2022-06-22 10:51'
tags: 
  - 
categories: 
  - Daily Bits
---


---

20220622

As part of [the CEABIGR project](https://github.com/sr320/ceabigr), I parsed and formatted data using `awk` to put into R vector. Will print comma-separated, quoted lists of the sample names I wanted (from [this file](https://github.com/epigeneticstoocean/2018_L18-adult-methylation/blob/main/data/adult-meta.csv)):

```shell
# Get Exposed female ample names from second column
awk -F"," '$3 == "Exposed" && $2~"F"{printf "%s%s%s, ", "\"", $2, "\""}' adult-meta.csv
```

```shell
# Get Control females from second column
awk -F"," '$3 == "Control" && $2~"F"{printf "%s%s%s, ", "\"", $2, "\""}' adult-meta.csv
```

```shell
# Get Control female sample names from second column
awk -F"," '$3 == "Control" && $2~"M"{printf "%s%s%s, ", "\"", $2, "\""}' adult-meta.csv
```


```shell
# Get Exposed male sample names from second column
awk -F"," '$3 == "Exposed" && $2~"M"{printf "%s%s%s, ", "\"", $2, "\""}' adult-meta.csv
```

```shell
# Get all Exposed sample names from second column
awk -F"," '$3 == "Exposed" {printf "%s%s%s, ", "\"", $2, "\""}' adult-meta.csv
```

```shell
# Get all Control sample names from second column
awk -F"," '$3 == "Control" {printf "%s%s%s, ", "\"", $2, "\""}' adult-meta.csv
```