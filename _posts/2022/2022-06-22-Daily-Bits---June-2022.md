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

20220624

- Gave some consideration/responses to [Anamica's GitHub issue regarding PacBio data for SNP analysis in bacterial cell lines](https://github.com/RobertsLab/resources/issues/1486#event-6859604758)

- Added some useful code for writing multiple data frames to CSV in R to avoid having to have individual code for each one:

```R

# Add data frames to list
# Wraps ls() with grep to allow for needed perl regex (the  "^(?!list).*" aspect) because
# ls() doesn't support perl regex
# Regex excludes any results beginning with the word "list"
list_transcript_counts_dfs <- mget(grep("^(?!list).*", ls(pattern = "transcript_counts_per_gene_per_sample"), value = TRUE, perl = TRUE))

# Write data frames to CSVs in ../analyses/dir
# Uses names of data frames as names of output files.
sapply(names(list_transcript_counts_dfs),
       function(x) write.csv(list_transcript_counts_dfs[[x]],
                             file = file.path("../analyses/", paste(x, "csv", sep=".")),
                             quote = FALSE,
                             row.names = FALSE)
```

---

20220623

DAY OFF

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