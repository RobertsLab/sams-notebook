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
#!/bin/bash
## Job Name
#SBATCH --job-name=DEG_hemat_D12-vs-D26
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=01-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200207_hemat_DEG/D12-vs-D26

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Document programs in PATH (primarily for program version ID)

{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log


wd="$(pwd)"
timestamp=$(date +%Y%m%d)
species="hemat"
threads=28
comparison="${wd##*/}"


fasta_prefix="20200122.hemat.megan.Trinity"


## Set input file locations
trimmed_reads_dir="/gscratch/srlab/sam/data/Hematodinium/RNAseq"
salmon_out_dir="${wd}"
transcriptome_dir="/gscratch/srlab/sam/data/Hematodinium/transcriptomes"
transcriptome="${transcriptome_dir}/${fasta_prefix}.fasta"
fasta_seq_lengths="${transcriptome_dir}/${fasta_prefix}.fasta.seq_lens"
samples="${wd}/${comparison}.samples.txt"

trinotate_feature_map="/gscratch/scrubbed/samwhite/outputs/20200126_hemat_trinotate_megan/20200126.hemat.trinotate.annotation_feature_map.txt"
gene_map="${transcriptome_dir}/${fasta_prefix}.fasta.gene_trans_map"
salmon_gene_matrix="${salmon_out_dir}/salmon.gene.TMM.EXPR.matrix"
salmon_iso_matrix="${salmon_out_dir}/salmon.isoform.TMM.EXPR.matrix"
go_annotations="${transcriptome_dir}/20200126.hemat.trinotate.go_annotations.txt"


# Standard output/error files
diff_expr_stdout="diff_expr_stdout.txt"
diff_expr_stderr="diff_expr_stderr.txt"
matrix_stdout="matrix_stdout.txt"
matrix_stderr="matrix_stderr.txt"
salmon_stdout="salmon_stdout.txt"
salmon_stderr="salmon_stderr.txt"
tpm_length_stdout="tpm_length_stdout.txt"
tpm_length_stderr="tpm_length_stderr.txt"
trinity_DE_stdout="trinity_DE_stdout.txt"
trinity_DE_stderr="trinity_DE_stderr.txt"

edgeR_dir=""

#programs
trinity_home=/gscratch/srlab/programs/trinityrnaseq-v2.9.0
trinity_annotate_matrix="${trinity_home}/Analysis/DifferentialExpression/rename_matrix_feature_identifiers.pl"
trinity_abundance=${trinity_home}/util/align_and_estimate_abundance.pl
trinity_matrix=${trinity_home}/util/abundance_estimates_to_matrix.pl
trinity_DE=${trinity_home}/Analysis/DifferentialExpression/run_DE_analysis.pl
diff_expr=${trinity_home}/Analysis/DifferentialExpression/analyze_diff_expr.pl
trinity_tpm_length=${trinity_home}/util/misc/TPM_weighted_gene_length.py

# Create directory/sample list for ${trinity_matrix} command
trin_matrix_list=$(awk '{printf "%s%s", $2, "/quant.sf " }' "${samples}")

cd ${trimmed_reads_dir}
time ${trinity_abundance} \
--output_dir "${salmon_out_dir}" \
--transcripts ${transcriptome} \
--seqType fq \
--samples_file "${samples}" \
--SS_lib_type RF \
--est_method salmon \
--aln_method bowtie2 \
--gene_trans_map "${gene_map}" \
--prep_reference \
--thread_count "${threads}" \
1> "${salmon_out_dir}"/${salmon_stdout} \
2> "${salmon_out_dir}"/${salmon_stderr}

# Move output folders
mv ${trimmed_reads_dir}/D* \
"${salmon_out_dir}"

cd "${salmon_out_dir}"

# Convert abundance estimates to matrix
${trinity_matrix} \
--est_method salmon \
--gene_trans_map ${gene_map} \
--out_prefix salmon \
--name_sample_by_basedir \
${trin_matrix_list}
1> ${matrix_stdout} \
2> ${matrix_stderr}

# Integrate functional Trinotate functional annotations
"${trinity_annotate_matrix}" \
"${trinotate_feature_map}" \
salmon.gene.counts.matrix \
> salmon.gene.counts.annotated.matrix


# Generate weighted gene lengths
"${trinity_tpm_length}" \
--gene_trans_map "${gene_map}" \
--trans_lengths "${fasta_seq_lengths}" \
--TPM_matrix "${salmon_iso_matrix}" \
> Trinity.gene_lengths.txt \
2> ${tpm_length_stderr}

# Differential expression analysis
cd ${transcriptome_dir}
${trinity_DE} \
--matrix "${salmon_out_dir}"/salmon.gene.counts.matrix \
--method edgeR \
--samples_file "${samples}" \
1> ${trinity_DE_stdout} \
2> ${trinity_DE_stderr}

mv edgeR* "${salmon_out_dir}"


# Run differential expression on edgeR output matrix
# Set fold difference to 2-fold (ie. -C 1 = 2^1)
# P value <= 0.05
# Has to run from edgeR output directory

# Pulls edgeR directory name and removes leading ./ in find output
cd "${salmon_out_dir}"
edgeR_dir=$(find . -type d -name "edgeR*" | sed 's%./%%')
cd "${edgeR_dir}"
mv "${transcriptome_dir}/${trinity_DE_stdout}" .
mv "${transcriptome_dir}/${trinity_DE_stderr}" .
${diff_expr} \
--matrix "${salmon_gene_matrix}" \
--samples "${samples}" \
--examine_GO_enrichment \
--GO_annots "${go_annotations}" \
--include_GOplot \
--gene_lengths "${salmon_out_dir}"/Trinity.gene_lengths.txt \
-C 1 \
-P 0.05 \
1> ${diff_expr_stdout} \
2> ${diff_expr_stderr}
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
