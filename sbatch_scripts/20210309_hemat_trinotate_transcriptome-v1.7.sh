#!/bin/bash
## Job Name
#SBATCH --job-name=20210309_hemat_trinotate_transcriptome-v1.7
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210309_hemat_trinotate_transcriptome-v1.7


# Script to run Trinotate on Hematodinium transcriptome:
# v1.7

###################################################################################
# These variables need to be set by user

# Input files
## BLASTx
blastx_out="/gscratch/scrubbed/samwhite/outputs/20210308_hemat_diamond_blastx_v1.6_v1.7/hemat_transcriptome_v1.7.fasta.blastx.outfmt6"

## TransDecoder
transdecoder_dir="/gscratch/scrubbed/samwhite/outputs/20210309_hemat_transdecoder_transcriptomes_v1.6_v1.7/20210309_hemat_transcriptome_v1.7.fasta.transdecoder"
blastp_out="${transdecoder_dir}/20210309_hemat_transcriptome_v1.6.fasta.blastp_out/20210309_hemat_transcriptome_v1.7.fasta.blastp.outfmt6"
pfam_out="${transdecoder_dir}/20210309_hemat_transcriptome_v1.7.fasta.pfam_out/20210309_hemat_transcriptome_v1.7.fasta.pfam.domtblout"
lORFs_pep="${transdecoder_dir}/hemat_transcriptome_v1.7.fasta.transdecoder_dir/longest_orfs.pep"

## Transcriptomics
transcriptomes_dir="/gscratch/srlab/sam/data/Hematodinium/transcriptomes"
trinity_fasta="${transcriptomes_dir}/hemat_transcriptome_v1.7.fasta"
trinity_gene_map="${transcriptomes_dir}/hemat_transcriptome_v1.7.fasta.gene_trans_map"

###################################################################################

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

# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log
