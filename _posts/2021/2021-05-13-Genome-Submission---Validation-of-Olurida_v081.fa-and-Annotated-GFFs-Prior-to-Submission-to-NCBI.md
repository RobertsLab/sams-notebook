---
layout: post
title: Genome Submission - Validation of Olurida_v081.fa and Annotated GFFs Prior to Submission to NCBI
date: '2021-05-13 13:34'
tags: 
  - NCBI
  - Ostrea lurida
  - Olympia oyster
  - jupyter notebook
categories: 
  - Olympia Oyster Genome Assembly
---
[Per this GitHub Issue](https://github.com/RobertsLab/resources/issues/1159), Steven has asked to get our [_Ostrea lurida_ (Olympia oyster)](http://en.wikipedia.org/wiki/Pacific_oyster) genome assembly (`Olurida_v081.fa`) submitted to NCBI with annotations. The first step in the submission process is to use the NCBI `table2asn_GFF` software to validate the FastA assembly, as well as the GFF annotations file. Once the software has been run, it will point out any errors which need to be corrected prior to submission.

The validation was run on my local computer in the following Jupyter Notebook:


Jupyter Notebook (GitHub):

- [20210513_olur_NCBI_genome-submission-prep.ipynb](https://github.com/RobertsLab/code/blob/master/notebooks/sam/20210513_olur_NCBI_genome-submission-prep.ipynb)

Jupyter Notebook (NBviewer):

- [20210513_olur_NCBI_genome-submission-prep.ipynb](https://nbviewer.jupyter.org/github/RobertsLab/code/blob/master/notebooks/sam/20210513_olur_NCBI_genome-submission-prep.ipynb)


<iframe src="https://nbviewer.jupyter.org/github/RobertsLab/code/blob/master/notebooks/sam/20210513_olur_NCBI_genome-submission-prep.ipynb" width="100%" height="2000" scrolling="yes"></iframe>


---

#### RESULTS

Output folder:

- [20210513_olur_NCBI_genome-submission-prep/](https://gannet.fish.washington.edu/Atumefaciens/20210513_olur_NCBI_genome-submission-prep/)

  - Discrepancy Report (text; 46MB)

    - [20210513_olur_NCBI_genome-submission-prep/20210513_Olurida-v081.dr](https://gannet.fish.washington.edu/Atumefaciens/20210513_olur_NCBI_genome-submission-prep/20210513_Olurida-v081.dr)

 

  - Validation Report (text; 867B)

    - [20210513_olur_NCBI_genome-submission-prep/20210513_Olurida-v081.stats](https://gannet.fish.washington.edu/Atumefaciens/20210513_olur_NCBI_genome-submission-prep/20210513_Olurida-v081.stats)



Alrighty, let's take a look at the results.

---

### Discrepancy report:

```
Discrepancy Report Results

Summary
COUNT_NUCLEOTIDES: 159429 nucleotide Bioseqs are present
LONG_NO_ANNOTATION: 46845 bioseqs are longer than 5000nt and have no features
NO_ANNOTATION: 133211 bioseqs have no features
GAPS: 114914 sequences contain gaps
LOW_QUALITY_REGION: 809 sequences contain low quality region
FEATURE_COUNT: CDS: 32210 present
FEATURE_COUNT: gene: 32210 present
FEATURE_COUNT: mRNA: 32210 present
PROTEIN_NAMES: All proteins have same name "hypothetical protein"
BAD_GENE_STRAND: 3 feature locations conflict with gene location strands
FATAL: CONTAINED_CDS: 10 coding regions are completely contained in another coding region, but on the opposite strand.
FEATURE_LOCATION_CONFLICT: 16978 features have inconsistent gene locations.
FATAL: BACTERIAL_JOINED_FEATURES_NO_EXCEPTION: 29207 coding regions with joined locations have no exceptions
SHORT_INTRON: 726 introns are shorter than 10 nt
FEATURE_LIST: Feature List

Detailed Report
```

[Here's the NCBI resource guide to the understanding the Discrepancy Report.](https://www.ncbi.nlm.nih.gov/genbank/asndisc/#evaluating_the_output) as well as a [guide to common errors](https://www.ncbi.nlm.nih.gov/genbank/new_asndisc_examples/).

We see that there are two lines beginning with `FATAL`, but they're actually not a big deal:

- `FATAL: BACTERIAL_JOINED_FEATURES_NO_EXCEPTION`: This can be ignored, as it only applies to prokaryotes.

- `FATAL: CONTAINED_CDS`: These will require inspection and confirmation that the annotations are indeed correct and/or fixed.

Here are other problems which will need to be addressed:

- `LOW_QUALITY_REGION`: Indicates stretches of N's. Will need to remove N's and replace with gap "feature".

- `BAD_GENE_STRAND`: Not sure whether or not this is critical, as it's not documented in either of those links above. I'll have to contact NCBI regarding this.

- `FEATURE_LOCATION_CONFLICT`: Not sure whether or not this is critical, as it's not documented in either of those links above. I'll have to contact NCBI regarding this.

- `SHORT_INTRON`: Not sure whether or not this is critical, as it's not documented in either of those links above. I'll have to contact NCBI regarding this.

---

### Validation report

```
Total messages:		293302

=================================================================
35926 WARNING-level messages exist

SEQ_INST.TerminalGap:	2
SEQ_INST.LeadingX:	1
SEQ_FEAT.NotSpliceConsensusDonor:	12488
SEQ_FEAT.NotSpliceConsensusAcceptor:	10811
SEQ_FEAT.IntervalBeginsOrEndsInGap:	72
SEQ_FEAT.ShortExon:	1182
SEQ_FEAT.PartialProblemNotSpliceConsensus3Prime:	6154
SEQ_FEAT.PartialProblemNotSpliceConsensus5Prime:	5214
SEQ_FEAT.PartialProblem5Prime:	2

=================================================================
257376 ERROR-level messages exist

SEQ_INST.ShortSeq:	2
SEQ_DESCR.BioSourceMissing:	26218
SEQ_DESCR.NoPubFound:	1
SEQ_DESCR.NoSourceDescriptor:	1
GENERIC.MissingPubRequirement:	1
SEQ_FEAT.IllegalDbXref:	230426
SEQ_FEAT.FeatureBeginsOrEndsInGap:	1
SEQ_FEAT.ShortIntron:	726

=================================================================
```

[Here's the NCBI guide to validation errors](https://www.ncbi.nlm.nih.gov/genbank/genome_validation/). All errors will need to be resolved prior to submission.

- `SEQ_INST.ShortSeq`: This is not documented in the link above. I'll have to contact NCBI regarding this.

- `SEQ_DESCR.BioSourceMissing`: "Suggestion: Provide an organism name for each sequence in your submission." Not sure if this needs to be done in the FastA, GFF, or both. Or, maybe it needs to be supllied when running the `table2asn_GFF` command, using the `-j` option? Will investigate both files and see which sequences this crops up on, as well as a modified run of the `table2asn_GFF`.

- `SEQ_DESCR.NoPubFound`: "Suggestion: Include the template when you create the .sqn submission file. You can create a template here: https://submit.ncbi.nlm.nih.gov/genbank/template/submission/ ." I'll create a template file.

- `SEQ_DESCR.NoSourceDescriptor`: This is not documented in the link above. I'll have to contact NCBI regarding this. However, I have a sneaking suspicion that this is related to the need for a template file.

- `GENERIC.MissingPubRequirement`: This is not documented in the link above. I'll have to contact NCBI regarding this. However, I have a sneaking suspicion that this is related to the need for a template file.

- `SEQ_FEAT.IllegalDbXref`: This is not documented in the link above. I'll have to contact NCBI regarding this. However, it's likely due to incorrect formatting or invalid database cross reference, according to [this NCBI DbXref guide](https://www.ncbi.nlm.nih.gov/genbank/collab/db_xref/%20).

- `SEQ_FEAT.FeatureBeginsOrEndsInGap`: This is not documented in the link above. I'll have to contact NCBI regarding this. However, it seems obvious that the problem is that a feature is beginning/ending in a stretch of N's. Will look at GFF to see what's happening.

- `SEQ_FEAT.ShortIntron`: This is not documented in the link above. I'll have to contact NCBI regarding this. However, it's clear that some introns are considered too short. This was identified in the Discrepancy Report above, but the documentation for that suggests that this might not need to be corrected. But, documentation indicates that all errors in the validation need to be eliminated...