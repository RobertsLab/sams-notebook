---
layout: post
title: Gene Expression - C.bairdi MEGAN6 with Trinity and EdgeR
date: '2020-02-07 05:45'
tags:
  - Trinity
  - EdgeR
  - Tanner crab
  - Chionoecetes bairdi
  - gene expression
  - goseq
  - gene ontology
  - GO
  - enrichment
categories:
  - Tanner Crab RNAseq
---
After completing [annotation of the _C.bairdi_ MEGAN6 taxonomic-specific Trinity assembly using Trinotate on 20200126](https://robertslab.github.io/sams-notebook/2020/01/26/Transcriptome-Annotation-Trinotate-C.bairdi-MEGAN6-Taxonomic-specific-Trinity-Assembly-on-Mox.html), I performed differential gene expression analysis and gene ontology (GO) term enrichment analysis using Trinity's scripts to run EdgeR and GOseq, respectively, across all of the various treatment comparisons. The comparison are listed below and link to each individual SBATCH script (GitHub) used to run these on Mox.

- [D12_infected-vs-D12_uninfected](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200207_cbai_DEG_D12_infected-vs-D12_uninfected.sh)

- [D12_infected-vs-D26_infected](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200207_cbai_DEG_D12_infected-vs-D26_infected.sh)

- [D12_uninfected-vs-D26_uninfected](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200207_cbai_DEG_D12_uninfected-vs-D26_uninfected.sh)

- [D12-vs-D26](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200207_cbai_DEG_D12-vs-D26.sh)

- [D26_infected-vs-D26_uninfected](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200207_cbai_DEG_D26_infected-vs-D26_uninfected.sh)

- [infected-vs-uninfected](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200128_cbai_DEG_inf-vs-uninf.sh)

It should be noted that most of these comparisons do not have any replicate samples (e.g. D12 infected vs D12 uninfected). I made a weak attempt to coerce some results from these by setting a `dispersion` value in the edgeR command. However, I'm not expecting much, nor am I certain I would really trust the results from those particular comparisons.



---

#### RESULTS

Output folder:

- [20200207_cbai_DEG/](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/)

Comparisons:

---

D12_infected-vs-D12_uninfected

Took a little less than 20mins to run:

![Mox runtime for D12 infected vs D12 uninfeced](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_cbai_DEG_D12_infected-vs-D12_uninfected_runtime.png?raw=true)

- [D12_infected-vs-D12_uninfected/](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D12_infected-vs-D12_uninfected)

Only a single DEG, which is upregulated in the infected set:

![MA/volcano plot of D12 infected vs D12 uninfeced](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_cbai_DEG_D12_infected-vs-D12_uninfected_MA-plot.png?raw=true)

- [salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.DE.subset](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D12_infected-vs-D12_uninfected/edgeR.24484.dir/salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.DE.subset)

TRINITY_DN10191_c0_g1 - [SPID: Q36421](https://www.uniprot.org/uniprot/Q36421) (Cyctochrome c oxidase I)


---

D12_infected-vs-D26_infected

Took ~18mins to run:

![D12 infected vs D26 infected runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_cbai_DEG_D12_infected-vs-D26_infected_runtime.png?raw=true)

- [D12_infected-vs-D26_infected/](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D12_infected-vs-D26_infected)

No differentially expressed genes between these two groups.

NOTE: Since no DEGs, that's why this run shows as `FAILED` in the above runtime screencap. This log file captures the error message that kills the job and generates the `FAILED` indicator:

- [20200207_cbai_DEG/D12_infected-vs-D26_infected/edgeR.21680.dir/diff_expr_stderr.txt](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D12_infected-vs-D26_infected/edgeR.21680.dir/diff_expr_stderr.txt)

`Error, no differentially expressed transcripts identified at cuttoffs: P:0.05, C:1 at /gscratch/srlab/programs/trinityrnaseq-v2.9.0/Analysis/DifferentialExpression/analyze_diff_expr.pl line 203.`

---

D12_uninfected-vs-D26_uninfected


Took ~18mins to run:

![D12 uninfected vs D26 uninfected runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_cbai_DEG_D12_uninfected-vs-D26_uninfected_runtime.png?raw=true)


- [D12_uninfected-vs-D26_uninfected/](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D12_uninfected-vs-D26_uninfected)

No differentially expressed genes between these two groups.

NOTE: Since no DEGs, that's why this run shows as `FAILED` in the above runtime screencap. This log file captures the error message that kills the job and generates the `FAILED` indicator:

- [20200207_cbai_DEG/D12_uninfected-vs-D26_uninfected/edgeR.27147.dir/diff_expr_stderr.txt](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D12_uninfected-vs-D26_uninfected/edgeR.27147.dir/diff_expr_stderr.txt)

`Error, no differentially expressed transcripts identified at cuttoffs: P:0.05, C:1 at /gscratch/srlab/programs/trinityrnaseq-v2.9.0/Analysis/DifferentialExpression/analyze_diff_expr.pl line 203.`

---


D12-vs-D26

Took ~40mins to run:

![D12 vs D26 runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_cbai_DEG_D12-vs-D26_runtime.png?raw=true)

- [D12-vs-D26/](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D12-vs-D26)

![D12 vs D26 expression heatmap](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_cbai_DEG_D12-vs-D26_trinity_heatmap.png?raw=true)

D12 upregulated genes:

- [20200207_cbai_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D12-UP.subset](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D12-UP.subset)

- Five genes:

  - TRINITY_DN4239_c0_g1 - No annotation

  - TRINITY_DN4669_c0_g2 - No annotation

  - TRINITY_DN5346_c0_g2 - No annotation

  - TRINITY_DN12453_c0_g1 - [SP ID: Q6ING4](https://www.uniprot.org/uniprot/Q6ING4)(DEP domain-containing protein 1A)

  - TRINITY_DN8311_c0_g1 - No annotation

D12 GO enrichment identified zero enriched and five depleted:

- [20200207_cbai_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D12-UP.subset.GOseq.enriched](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D12-UP.subset.GOseq.enriched)

- [20200207_cbai_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D12-UP.subset.GOseq.depleted](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D12-UP.subset.GOseq.depleted)

  - Only one of these five is in the "biological process" category and it is uncharacterized (i.e. is identified as "biological process").


D26 upregulated genes:

- [20200207_cbai_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D26-UP.subset](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D26-UP.subset)

- 11 genes:

  - TRINITY_DN4610_c0_g1 - [SP ID: Q9MFN9](https://www.uniprot.org/uniprot/Q9MFN9)(Cytochrome b)

  - TRINITY_DN10370_c0_g1 - [SP ID: P20241](https://www.uniprot.org/uniprot/P20241)(Neuroglian)

  - TRINITY_DN2559_c1_g1 - No annotation.

  - TRINITY_DN5386_c0_g1 - No annotation.

  - TRINITY_DN400_c2_g1 - [SP ID: Q8N587](https://www.uniprot.org/uniprot/Q8N587)(Zinc finger protein 561)

  - TRINITY_DN2969_c0_g2 - No annotation.

  - TRINITY_DN4328_c0_g1 - No annotation.

  - TRINITY_DN8_c11_g1 - No annotation.

  - TRINITY_DN1107_c1_g1 - No annotation.

  - TRINITY_DN2373_c0_g1 - [SP ID: Q4AEI0](https://www.uniprot.org/uniprot/Q4AEI0)(Glutathione peroxidase 2)

  - TRINITY_DN2730_c0_g1 - No annotation.

D26 GO enrichment identified four up-regulated enriched GO terms (all in the "molecular function" category) and five up-regulated depleted GO terms (all in the "biological process" category).

- [20200207_cbai_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D26-UP.subset.GOseq.enriched](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D26-UP.subset.GOseq.enriched)

- [20200207_cbai_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D26-UP.subset.GOseq.depleted](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D26-UP.subset.GOseq.depleted)

---

D26_infected-vs-D26_uninfected

- [D26_infected-vs-D26_uninfected/](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D26_infected-vs-D26_uninfected)

No differentially expressed genes between these two groups.

NOTE: Since no DEGs, that's why this run shows as `FAILED` in the above runtime screencap. This log file captures the error message that kills the job and generates the `FAILED` indicator:

[20200207_cbai_DEG/D26_infected-vs-D26_uninfected/edgeR.20733.dir/diff_expr_stderr.txt](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/D26_infected-vs-D26_uninfected/edgeR.20733.dir/diff_expr_stderr.txt)

`Error, no differentially expressed transcripts identified at cuttoffs: P:0.05, C:1 at /gscratch/srlab/programs/trinityrnaseq-v2.9.0/Analysis/DifferentialExpression/analyze_diff_expr.pl line 203.`

---

infected-vs-uninfected

Took ~40mins to run:

![infected vs uninfected runtim](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_cbai_DEG_infected-vs-uninfected_runtime.png?raw=true)

Output folder:

- [infected-vs-uninfected/](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/infected-vs-uninfected)

![infected vs uninfected expression heatmap](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_cbai_DEG_infected-vs-uninfected_trinity_heatmap.png?raw=true)

Infected upregulated DEGs:

- [20200207_cbai_DEG/infected-vs-uninfected/edgeR.2317.dir/salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.infected-UP.subset](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/infected-vs-uninfected/edgeR.2317.dir/salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.infected-UP.subset)

  - 345 genes

Infected GO enrichment identified 374 enriched GO terms:

- [20200207_cbai_DEG/infected-vs-uninfected/edgeR.2317.dir/salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.infected-UP.subset.GOseq.enriched](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/infected-vs-uninfected/edgeR.2317.dir/salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.infected-UP.subset.GOseq.enriched)

Uninfected upregulated genes:

- [20200207_cbai_DEG/infected-vs-uninfected/edgeR.2317.dir/salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.uninfected-UP.subset](https://gannet.fish.washington.edu/Atumefaciens/20200207_cbai_DEG/infected-vs-uninfected/edgeR.2317.dir/salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.uninfected-UP.subset)

  - 20 genes

Uninfected GO enrichment identified zero enriched GO terms.
