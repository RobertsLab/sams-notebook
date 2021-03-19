---
layout: post
title: Transcriptome Annotation - Trinotate on C.bairdi Transcriptome v4.0 on Mox
date: '2021-03-18 20:25'
tags:
  - trinotate
  - Chionoecetes bairdi
  - Tanner crab
  - transcriptome
  - annotation
  - mox
categories:
  - Miscellaneous
---
Continued annotation of `cbai_transcriptome_v4.0.fasta` [Trinity _de novo_ assembly from 20210317(https://robertslab.github.io/sams-notebook/2021/03/17/Transcriptome-Assembly-C.bairdi-Transcriptome-v4.0-Using-Trinity-on-Mox.html)] using [`Trinotate`](https://github.com/Trinotate/Trinotate.github.io/wiki) on Mox. This will provide a thorough annotation, including genoe ontology (GO) term assignments to each contig.

One thing to note is that upon initial run, RNAmmer caused the script to exit with an error due to not having produced any results. The developer responded to the [GitHub issue I posted](https://github.com/Trinotate/Trinotate/issues/71) and indicated the lack of results was a bit unexpected, but suggested I add the "or" bash notation (`||`) to the end of the RNammer command to allow the Trinotate pipeline to proceed without any RNAmmer info. It's still surprising that there weren't _any_ matches...

SBATCH script (GitHub):

- [20210318_cbai_trinotate_transcriptome-v4.0.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210318_cbai_trinotate_transcriptome-v4.0.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210318_cbai_trinotate_transcriptome-v4.0
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=7-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210318_cbai_trinotate_transcriptome-v4.0


# Script to run Trinotate on C.bairdi transcriptome v4.0

# NOTE: RNAMMER appears to not find any matches, so have added "||" at end of RNAMMER
# command to allow annotation to proceed.

###################################################################################
# These variables need to be set by user

# Input files
## BLASTx
blastx_out="/gscratch/scrubbed/samwhite/outputs/20210318_cbai_diamond_blastx_transcriptome-v4.0/cbai_transcriptome_v4.0.blastx.outfmt6"

## TransDecoder
transdecoder_dir="/gscratch/scrubbed/samwhite/outputs/20210317_cbai_transdecoder_transcriptome_v4.0"
blastp_out="${transdecoder_dir}/blastp_out/cbai_transcriptome_v4.0.fasta.blastp.outfmt6"
pfam_out="${transdecoder_dir}/pfam_out/cbai_transcriptome_v4.0.fasta.pfam.domtblout"
lORFs_pep="${transdecoder_dir}/cbai_transcriptome_v4.0.fasta.transdecoder_dir/longest_orfs.pep"

## Transcriptomics
transcriptomes_dir="/gscratch/srlab/sam/data/C_bairdi/transcriptomes"
trinity_fasta="${transcriptomes_dir}/cbai_transcriptome_v4.0.fasta"
trinity_gene_map="${transcriptomes_dir}/cbai_transcriptome_v4.0.fasta.gene_trans_map"

###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017

# SegFault fix?
export THREADS_DAEMON_MODEL=1


wd="$(pwd)"
timestamp=$(date +%Y%m%d)


## Paths to input/output files

## New folders for working directory
rnammer_out_dir="${wd}/RNAmmer_out"
signalp_out_dir="${wd}/signalp_out"
tmhmm_out_dir="${wd}/tmhmm_out"


rnammer_prefix=${trinity_fasta##*/}
prefix="${timestamp}.${rnammer_prefix}.trinotate"

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

# Generate FastA checksum, for reference if needed.
md5sum ${trinity_fasta} > fasta.checksum.md5

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
# Has "||" operator due to previous lack of matches
# Need "||" to continue with annotation.
cd "${rnammer_out_dir}" || exit
${trinotate_rnammer} \
--transcriptome ${trinity_fasta} \
--path_to_rnammer ${rnammer} \
|| cd "${wd}" || exit

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

# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log
```
---

#### RESULTS

Runtime was pretty quick; just less than an hour:

![Trinotate runtime for C.bairdi transcriptome v4.0 on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210318_cbai_trinotate_transcriptome-v4.0_runtime.png?raw=true)

Output folder:

- [20210318_cbai_trinotate_transcriptome-v4.0](https://gannet.fish.washington.edu/Atumefaciens/20210318_cbai_trinotate_transcriptome-v4.0)

  - Annotation feature map (5MB; text):

      - [20210318.cbai_transcriptome_v4.0.fasta.trinotate.annotation_feature_map.txt](https://gannet.fish.washington.edu/Atumefaciens/20210318_cbai_trinotate_transcriptome-v4.0/20210318.cbai_transcriptome_v4.0.fasta.trinotate.annotation_feature_map.txt)

      - [This can be used to update Trinity-based gene expression matrices like so](https://github.com/trinityrnaseq/trinityrnaseq/wiki/Functional-Annotation-of-Transcripts):

        - ```${TRINITY_HOME}/Analysis/DifferentialExpression/rename_matrix_feature_identifiers.pl Trinity_trans.counts.matrix annot_feature_map.txt > Trinity_trans.counts.wAnnot.matrix```

  - Annotation report (45MB; CSV)

    - [20210318.cbai_transcriptome_v4.0.fasta.trinotate_annotation_report.txt](https://gannet.fish.washington.edu/Atumefaciens/20210318_cbai_trinotate_transcriptome-v4.0/20210318.cbai_transcriptome_v4.0.fasta.trinotate_annotation_report.txt)

  - Gene ontology (GO) annotations (12MB; text)

    - [20210318.cbai_transcriptome_v4.0.fasta.trinotate.go_annotations.txt](https://gannet.fish.washington.edu/Atumefaciens/20210318_cbai_trinotate_transcriptome-v4.0/20210318.cbai_transcriptome_v4.0.fasta.trinotate.go_annotations.txt)

  - SQlite database (542MB; SQLITE):

    - [Trinotate.sqlite](https://gannet.fish.washington.edu/Atumefaciens/20210318_cbai_trinotate_transcriptome-v4.0/Trinotate.sqlite)
