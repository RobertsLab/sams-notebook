---
layout: post
title: RNAseq Reads Extractions - C.bairdi Taxonomic Reads Extractions with MEGAN6 on swoose
date: '2020-01-14 10:36'
tags:
  - Tanner crab
  - MEGAN6
  - taxonomy
  - Chionoecetes bairdi
  - swoose
categories:
  - Miscellaneous
---
[I previously ran BLASTx and "meganized" the output DAA files on 20200103](https://robertslab.github.io/sams-notebook/2020/01/03/Transcriptome-Annotation-C.bairdi-Using-DIAMOND-BLASTx-on-Mox-and-MEGAN6-Meganizer.html) (for reference, these include RNAseq data using a newly established "shorthand": 2018, 2019) and now need to use MEGAN6 to bin the results into the proper taxonomies. This is accomplished using the MEGAN6 graphical user interface (GUI). This is how the process goes:

1. File > Import from BLAST...

2. Select all "meganized" DAA files for a given set of sequencing (e.g. `304428_S1_L001_R1_001.blastx.daa`, `304428_S1_L001_R2_001.blastx.daa`, `304428_S1_L002_R1_001.blastx.daa`, `304428_S1_L001_R2_001.blastx.daa` )

3. Check the "Paired Reads" box. (I don't think this actually does anything, though...)

4. Click "Next"

5. Check the "Analyze Taxonomy Content" box.

6. Click "Load Accession mapping file" and find the mapping file used for "meganizing the DAA file": `prot_acc2tax-Jul2019X1.abin`

7. Click "Next"

8. Click "Load Accession mapping file" and find the mapping file used for "meganizing the DAA file": `acc2eggnog-Jul2019X.abin`

9. Click "Next"

10. Click "Load Accession mapping file" and find the mapping file used for "meganizing the DAA file": `acc2interpro-Jul2019X.abin`

11. Click "Next" twice, to advance to the "SEED" tab.

12. Click "Load Accession mapping file" and find the mapping file used for "meganizing the DAA file": `acc2seed-May2015XX.abin`

13. Click "Next" twice, to advance to the "LCA Params" tab.

14. Click "Apply"

This will initiate the import process and will create a special MEGAN file: RMA6.

NOTE: This will take a long time _and_ will require a significant amount of disk space! The final files aren't ridiculously large, but the intermediate file that gets generated quickly becomes extremely large (i.e. hundreds of GB)!


After that has completed, use the MEGAN6 GUI to "Open" the RMA6 file. Once the file loads, you will get a nice looking taxonomic tree! From here, you can select any part of the taxonomic tree by right-clicking on the desired taxonomy and "Extract reads...". Here, you have the option to include "Summarized reads". This option allows you to extract just the reads that are part of the exact classification you've selected or all those within and "below" the classification you've selected (i.e. summarized reads).

Extracted reads will be generated as FastA files.

Example:

If you select _Arthropoda_ and _do not_ check the box for "Summarized Reads" you will _only get reads classified as Arthropoda_! You will not get any reads with more specific taxonomies. However, if you select _Arthropoda_ and you _do_ check the box for "Summarized Reads", you will get all reads classified as _Arthropoda_ _AND_ all reads in more specific taxonomic classifications, down to the species level.

I will extract reads from two phyla:

- _Arthropoda_ (for crabs)

- _Alveolata_ (for _Hematodinium_)

---

#### RESULTS

I put the RMA6 files in [the original DIAMOND BLASTx/meganization folder from 20200103](https://robertslab.github.io/sams-notebook/2020/01/03/Transcriptome-Annotation-C.bairdi-Using-DIAMOND-BLASTx-on-Mox-and-MEGAN6-Meganizer.html), as it seemed to make most sense organizational-wise to keep those together.

Output folder:

- [20200103_cbai_diamond_blastx/](https://gannet.fish.washington.edu/Atumefaciens/20200103_cbai_diamond_blastx/)


I put the extracted reads (FastA) here:

- [20200114_cbai_MEGAN_read_extractions/](https://gannet.fish.washington.edu/Atumefaciens/20200114_cbai_MEGAN_read_extractions/)


One good thing to see was that the samples that were considered "uninfected" (based on PCR/qPCR data) had no reads classified as _Alveolata_ (see samples 329775 and 329777 below).


#### Taxonomic Trees

##### 304428

![304428 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200103_cbai_diamond_blastx_MEGAN_import_304428.png?raw=true)

---

##### 329774

![329774 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200103_cbai_diamond_blastx_MEGAN_import_329774.png?raw=true)

---

##### 329775

![329775 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200103_cbai_diamond_blastx_MEGAN_import_329775.png?raw=true)

---

##### 329776

![329776 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200103_cbai_diamond_blastx_MEGAN_import_329776.png?raw=true)

---

##### 329777

![329777 MEGAN6 taxonomic tree](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200103_cbai_diamond_blastx_MEGAN_import_329777.png?raw=true)

---
