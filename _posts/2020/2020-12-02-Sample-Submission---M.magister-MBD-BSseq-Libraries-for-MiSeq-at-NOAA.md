---
layout: post
title: Sample Submission - M.magister MBD BSseq Libraries for MiSeq at NOAA
date: '2020-12-02 09:13'
tags:
  - Metacarcinus magister
  - MiSeq
  - NOAA
  - MBD
  - BSseq
  - Dungeness crab
categories:
  - Samples Submitted
---
[Earlier today I quantified the libraries with the Qubit](https://robertslab.github.io/sams-notebook/2020/12/02/Library-Quantification-M.magister-MBD-BSseq-Libraries-with-Qubit.html) in preparation for sample pooling and sequencing. Before performing a full sequencing run, Mac wanted to select a subset of the libraries based on the experimental treatments to have an equal representation of samples. She also wanted to do a quick run on the MiSeq at NOAA to evaluate how well libraries map and to make sure libraries appear to be sequencing at relatively equal levels.

I created 4nM aliquots of all samples, using the average fragment length calculated by the Bioanalyzer region setting I created. The formula for determining molarity from concentration is:


<code>Sample_Nameconcentration(ng/uL) * (660(g/mole/bp) * frag_len(bp))<sup>-1</sup> * 1000000(uL/L) = molarity(nM)</code>

After creating 4nM aliquots, I combined 1uL from each aliquot (per Mac's typical procedure) and gave the pooled libraries to Mac to sequence at NOAA.

The following samples are those that were _not_ used in the library pool:

- `CH05-26`

- `CH09-11`

- `CH09-29`

- `CH10-19`


All these library calculations are in the principal spreadsheet for this project:

- [OA Crab Sample Collection 071119](https://docs.google.com/spreadsheets/d/1ym0XnYVts98tIUCn0kIaU6VuvqxzV7LoSx9RHwLdiIs/edit#gid=1430155532) (Google Sheet)

- Specific columns:

  - `qubit_concentration(ng/uL)`

  - `qubit_molarity(nM)`

  - `library_4nM_Vi(uL)`: Library volume needed for 4nM in 25uL aliquot.

  - `library_4nM_Vf(uL)`: Final volume of library aliquot (25uL).

  - `library_4nM_Cf(nM)`: Final concentration of library aliquot (4nM).

  - `library_4nM_H2O(uL)`: Water needed to bring aliquot to 25uL.

Additional details are available in this GitHub repo:

- [project-dungeness-crab](https://github.com/RobertsLab/project-dungeness-crab)
