---
layout: post
title: Gene Expression - Hematodinium MEGAN6 with Trinity and EdgeR
date: '2020-02-07 13:17'
tags:
  - Trinity
  - EdgeR
  - Hematodinium
  - gene expression
  - GOseq
  - gene ontology
  - GO
  - enrichment
categories:
  - Miscellaneous
---
After completing [annotation of the _Hematodinium_ MEGAN6 taxonomic-specific Trinity assembly using Trinotate on 20200126](https://robertslab.github.io/sams-notebook/2020/01/26/Transcriptome-Annotation-Trinotate-Hematodinium-MEGAN6-Taxonomic-specific-Trinity-Assembly-on-Mox.html), I performed differential gene expression analysis and gene ontology (GO) term enrichment analysis using Trinity's scripts to run EdgeR and GOseq, respectively. The comparison listed below is the only comparison possible, as there were no reads present in the uninfected _Hematodinium_ extractions.

It should be noted that this comparison does not have any replicate samples. I made a weak attempt to coerce some results from these by setting a `dispersion` value in the edgeR command. However, I'm not expecting much, nor am I certain I would really trust the results from those particular comparisons.


SBATCH script (GitHub):

- [D12-vs-D26](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200207_hemat_DEG_D12-vs-D26.sh)

```shell

```


---

#### RESULTS

Output folder:

- [20200207_hemat_DEG/](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/)

Comparisons:

---

D12_infected-vs-D12_uninfected

Took a little less than 18mins to run:

![Mox runtime for D12 infected vs D12 uninfeced](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_hemat_DEG_D12_infected-vs-D12_uninfected_runtime.png?raw=true)

- [D12_infected-vs-D12_uninfected/](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/D12_infected-vs-D12_uninfected)

No differentially expressed genes between these two groups.

NOTE: Since no DEGs, that's why this run shows as `FAILED` in the above runtime screencap. This log file captures the error message that kills the job and generates the `FAILED` indicator:

- [20200207_hemat_DEG/D12_infected-vs-D12_uninfected/edgeR.932.dir/diff_expr_stderr.txt](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/D12_infected-vs-D12_uninfected/edgeR.932.dir/diff_expr_stderr.txt)

`Error, no differentially expressed transcripts identified at cuttoffs: P:0.05, C:1 at /gscratch/srlab/programs/trinityrnaseq-v2.9.0/Analysis/DifferentialExpression/analyze_diff_expr.pl line 203.`

---

D12_infected-vs-D26_infected

Took a little less than 18mins to run:

![D12 infected vs D26 infected runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_hemat_DEG_D12_infected-vs-D26_infected_runtime.png?raw=true)

- [D12_infected-vs-D26_infected/](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/D12_infected-vs-D26_infected)

No differentially expressed genes between these two groups.

NOTE: Since no DEGs, that's why this run shows as `FAILED` in the above runtime screencap. This log file captures the error message that kills the job and generates the `FAILED` indicator:

- [20200207_hemat_DEG/D12_infected-vs-D26_infected/edgeR.17500.di/diff_expr_stderr.txt](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/D12_infected-vs-D26_infected/edgeR.17500.di/diff_expr_stderr.txt)

`Error, no differentially expressed transcripts identified at cuttoffs: P:0.05, C:1 at /gscratch/srlab/programs/trinityrnaseq-v2.9.0/Analysis/DifferentialExpression/analyze_diff_expr.pl line 203.`

---

D12_uninfected-vs-D26_uninfected


Took a little less than 18mins to run:

![D12 uninfected vs D26 uninfected runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_hemat_DEG_D12_uninfected-vs-D26_uninfected_runtime.png?raw=true)


- [D12_uninfected-vs-D26_uninfected/](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/D12_uninfected-vs-D26_uninfected)

No differentially expressed genes between these two groups.

NOTE: Since no DEGs, that's why this run shows as `FAILED` in the above runtime screencap. This log file captures the error message that kills the job and generates the `FAILED` indicator:

- [20200207_hemat_DEG/D12_uninfected-vs-D26_uninfected/edgeR.12032.dir/diff_expr_stderr.txt](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/D12_uninfected-vs-D26_uninfected/edgeR.12032.dir/diff_expr_stderr.txt)

`Error, no differentially expressed transcripts identified at cuttoffs: P:0.05, C:1 at /gscratch/srlab/programs/trinityrnaseq-v2.9.0/Analysis/DifferentialExpression/analyze_diff_expr.pl line 203.`

---


D12-vs-D26

Took ~40mins to run:

![D12 vs D26 runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_hemat_DEG_D12-vs-D26_runtime.png?raw=true)

- [D12-vs-D26/](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/D12-vs-D26)

![D12 vs D26 expression heatmap](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_hemat_DEG_D12-vs-D26_trinity_heatmap.png?raw=true)

D12 upregulated genes:

- [20200207_hemat_DEG/D12-vs-D26/edgeR.27819.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D12-UP.subset](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/D12-vs-D26/edgeR.27819.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D12-UP.subset)

- Two genes:

  - TRINITY_DN4415_c0_g1 - No annotation

	- TRINITY_DN4652_c0_g2 - No annotation

D12 GO enrichment identified zero enriched:

- [20200207_hemat_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D12-UP.subset.GOseq.enriched](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D12-UP.subset.GOseq.enriched)




D26 upregulated genes:

- [20200207_hemat_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D26-UP.subset](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D26-UP.subset)

- Three genes:

  - TRINITY_DN4610_c0_g1 - [SP ID: P20241](https://www.uniprot.org/uniprot/P20241)(Neuroglian)

	- TRINITY_DN5205_c0_g1 - No annotation

	- TRINITY_DN3009_c0_g2 - No annotation

D26 GO enrichment identified zero up-regulated enriched GO terms.

- [20200207_hemat_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D26-UP.subset.GOseq.enriched](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/D12-vs-D26/edgeR.21229.dir/salmon.gene.counts.matrix.D12_vs_D26.edgeR.DE_results.P0.05_C1.D26-UP.subset.GOseq.enriched)


---

D26_infected-vs-D26_uninfected

- [D26_infected-vs-D26_uninfected/](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/D26_infected-vs-D26_uninfected)

No differentially expressed genes between these two groups.

NOTE: Since no DEGs, that's why this run shows as `FAILED` in the above runtime screencap. This log file captures the error message that kills the job and generates the `FAILED` indicator:

[20200207_hemat_DEG/D26_infected-vs-D26_uninfected/edgeR.21116.dir/diff_expr_stderr.txt](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/D26_infected-vs-D26_uninfected/edgeR.21116.dir/diff_expr_stderr.txt)

`Error, no differentially expressed transcripts identified at cuttoffs: P:0.05, C:1 at /gscratch/srlab/programs/trinityrnaseq-v2.9.0/Analysis/DifferentialExpression/analyze_diff_expr.pl line 203.`

---

infected-vs-uninfected

Took ~40mins to run:

![infected vs uninfected runtim](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_hemat_DEG_infected-vs-uninfected_runtime.png?raw=true)

Output folder:

- [infected-vs-uninfected/](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/infected-vs-uninfected)

![infected vs uninfected expression heatmap](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200207_hemat_DEG_infected-vs-uninfected_trinity_heatmap.png?raw=true)

Infected upregulated DEGs:

- [20200207_hemat_DEG/infected-vs-uninfected/edgeR.30324.dir/salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.infected-UP.subset](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/infected-vs-uninfected/edgeR.30324.dir/salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.infected-UP.subset)

  - 345 genes

Infected GO enrichment identified 176 enriched GO terms:

- [20200207_hemat_DEG/infected-vs-uninfected/edgeR.30324.dir/salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.infected-UP.subset.GOseq.enriched](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/infected-vs-uninfected/edgeR.30324.dir/salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.infected-UP.subset.GOseq.enriched)

Uninfected upregulated genes:

- [20200207_hemat_DEG/infected-vs-uninfected/edgeR.30324.dir/salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.uninfected-UP.subset](https://gannet.fish.washington.edu/Atumefaciens/20200207_hemat_DEG/infected-vs-uninfected/edgeR.30324.dir/salmon.gene.counts.matrix.infected_vs_uninfected.edgeR.DE_results.P0.05_C1.uninfected-UP.subset)

  - 21 genes

Uninfected GO enrichment identified zero enriched GO terms.
