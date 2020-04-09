---
layout: post
title: Transcriptome Annotation - Trinotate Hematodinium MEGAN6 Taxonomic-specific Trinity Assembly on Mox
date: '2020-04-08 09:22'
tags:
  - Trinotate
  - Hematodinium
  - annotate
  - transcriptome
  - mox
categories:
  - Miscellaneous
---
After performing [_de novo_ assembly on our _Hematodinium_ MEGAN6 taxonomic-specific RNAseq data on 20200330](https://robertslab.github.io/sams-notebook/2020/03/30/Transcriptome-Assembly-Hematodinium-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html) and performing [BLASTx annotation on 20200331](https://robertslab.github.io/sams-notebook/2020/03/31/Transcriptome-Annotation-Hematodinium-MEGAN-Trinity-Assembly-Using-DIAMOND-BLASTx-on-Mox.html), I continued the annotation process by running [Trinotate](https://github.com/Trinotate/Trinotate.github.io/wiki).

Trinotate will perform functional annotation of the transcriptome assembly, including GO terms and an annotation feature map that can be used in subsequent Trinity-based differential gene expression analysis so that functional annotations are carried downstream through that process.

SBATCH script (GitHub):

- [20200408_hemat_trinotate_megan.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200408_hemat_trinotate_megan.sh)


```
#!/bin/bash
## Job Name
#SBATCH --job-name=trinotate_hemat
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=05-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200408_hemat_trinotate_megan

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

prefix="${timestamp}.${species}.trinotate"


## Paths to input/output files

## New folders for working directory
rnammer_out_dir="${wd}/RNAmmer_out"
signalp_out_dir="${wd}/signalp_out"
tmhmm_out_dir="${wd}/tmhmm_out"

# Input files
blastp_out="/gscratch/scrubbed/samwhite/outputs/20200407_hemat_transdecoder_megan/blastp_out/20200408.hemat.blastp.outfmt6"
blastx_out="/gscratch/scrubbed/samwhite/outputs/20200331_hemat_diamond_blastx_megan/20200408.hemat.megan.Trinity.blastx.outfmt6"
pfam_out="/gscratch/scrubbed/samwhite/outputs/20200407_hemat_transdecoder_megan/pfam_out/20200408.hemat.pfam.domtblout"
lORFs_pep="/gscratch/scrubbed/samwhite/outputs/20200407_hemat_transdecoder_megan/20200408.hemat.megan.Trinity.fasta.transdecoder_dir/longest_orfs.pep"
trinity_fasta="/gscratch/srlab/sam/data/Hematodinium/transcriptomes/20200408.hemat.megan.Trinity.fasta"
trinity_gene_map="/gscratch/srlab/sam/data/Hematodinium/transcriptomes/20200408.hemat.megan.Trinity.fasta.gene_trans_map"

rnammer_prefix=${trinity_fasta##*/}

# Output files
rnammer_out="${rnammer_out_dir}/${rnammer_prefix}.rnammer.gff"
signalp_out="${signalp_out_dir}/${prefix}.signalp.out"
tmhmm_out="${tmhmm_out_dir}/${prefix}.tmhmm.out"
trinotate_report="${wd}/${prefix}_annotation_report.txt"

# Paths to programs
rnammer_dir="/gscratch/srlab/programs/RNAMMER-1.2"
rnammer="${rnammer_dir}/rnammer"
signalp_dir="/gscratch/srlab/programs/signalp-4.1"
signalp="${signalp_dir}/signalp"
tmhmm_dir="/gscratch/srlab/programs/tmhmm-2.0c/bin"
tmhmm="${tmhmm_dir}/tmhmm"
trinotate_dir="/gscratch/srlab/programs/Trinotate-v3.1.1"
trinotate="${trinotate_dir}/Trinotate"
trinotate_rnammer="${trinotate_dir}/util/rnammer_support/RnammerTranscriptome.pl"
trinotate_GO="${trinotate_dir}/util/extract_GO_assignments_from_Trinotate_xls.pl"
trinotate_features="${trinotate_dir}/util/Trinotate_get_feature_name_encoding_attributes.pl"
trinotate_sqlite_db="Trinotate.sqlite"

# Make output directories
mkdir "${rnammer_out_dir}" "${signalp_out_dir}" "${tmhmm_out_dir}"

# Copy sqlite database template

cp ${trinotate_dir}/admin/Trinotate.sqlite .

# Run signalp
${signalp} \
-f short \
-n "${signalp_out}" \
${lORFs_pep}

# Run tmHMM
${tmhmm} \
--short \
< ${lORFs_pep} \
> "${tmhmm_out}"

# Run RNAmmer
cd "${rnammer_out_dir}" || exit
${trinotate_rnammer} \
--transcriptome ${trinity_fasta} \
--path_to_rnammer ${rnammer}
cd "${wd}" || exit

# Run Trinotate
## Load transcripts and coding regions into database
${trinotate} \
${trinotate_sqlite_db} \
init \
--gene_trans_map "${trinity_gene_map}" \
--transcript_fasta "${trinity_fasta}" \
--transdecoder_pep "${lORFs_pep}"

## Load BLAST homologies
"${trinotate}" \
"${trinotate_sqlite_db}" \
LOAD_swissprot_blastp \
"${blastp_out}"

"${trinotate}" \
"${trinotate_sqlite_db}" \
LOAD_swissprot_blastx \
"${blastx_out}"

## Load Pfam
"${trinotate}" \
"${trinotate_sqlite_db}" \
LOAD_pfam \
"${pfam_out}"

## Load transmembrane domains
"${trinotate}" \
"${trinotate_sqlite_db}" \
LOAD_tmhmm \
"${tmhmm_out}"

## Load signal peptides
"${trinotate}" \
"${trinotate_sqlite_db}" \
LOAD_signalp \
"${signalp_out}"

## Load RNAmmer
"${trinotate}" \
"${trinotate_sqlite_db}" \
LOAD_rnammer \
"${rnammer_out}"

## Creat annotation report
"${trinotate}" \
"${trinotate_sqlite_db}" \
report \
> "${trinotate_report}"

# Extract GO terms from annotation report
"${trinotate_GO}" \
--Trinotate_xls "${trinotate_report}" \
-G \
--include_ancestral_terms \
> "${prefix}".go_annotations.txt

# Make transcript features annotation map
"${trinotate_features}" \
"${trinotate_report}" \
> "${prefix}".annotation_feature_map.txt
```

---

#### RESULTS

Very quick, only 6.5 minutes:

![Hemat Trinotate runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200408_hemat_trinotate_megan_runtime.png?raw=true)

Output folder:

- [20200408_hemat_trinotate_megan/](https://gannet.fish.washington.edu/Atumefaciens/20200408_hemat_trinotate_megan/)


Annotation feature map. [This can be used to update Trinity-based gene expression matrices like so](https://github.com/trinityrnaseq/trinityrnaseq/wiki/Functional-Annotation-of-Transcripts):

- ```${TRINITY_HOME}/Analysis/DifferentialExpression/rename_matrix_feature_identifiers.pl Trinity_trans.counts.matrix annot_feature_map.txt > Trinity_trans.counts.wAnnot.matrix```

- [20200408.hemat.trinotate.annotation_feature_map.txt](https://gannet.fish.washington.edu/Atumefaciens/20200408_hemat_trinotate_megan/20200408.hemat.trinotate.annotation_feature_map.txt)

Annotation report (CSV)

- [20200408.hemat.trinotate_annotation_report.txt](https://gannet.fish.washington.edu/Atumefaciens/20200408_hemat_trinotate_megan/20200408.hemat.trinotate_annotation_report.txt)

Gene ontology (GO) annotations (TXT)

- [20200408.hemat.trinotate.go_annotations.txt](https://gannet.fish.washington.edu/Atumefaciens/20200408_hemat_trinotate_megan/20200408.hemat.trinotate.go_annotations.txt)

SQlite database:

- [Trinotate.sqlite](https://gannet.fish.washington.edu/Atumefaciens/20200408_hemat_trinotate_megan/Trinotate.sqlite)
