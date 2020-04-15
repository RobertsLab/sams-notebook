#!/bin/bash
## Job Name
#SBATCH --job-name=DEG_cbai_inf-vs-uninf
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=04-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200415_cbai_salmon_abundance

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
species="cbai"
threads=28


fasta_prefix="20200408.C_bairdi.megan.Trinity"


## Set input file locations
trimmed_reads_dir="/gscratch/srlab/sam/data/C_bairdi/RNAseq"
transcriptome_dir="/gscratch/srlab/sam/data/C_bairdi/transcriptomes"
transcriptome="${transcriptome_dir}/${fasta_prefix}.fasta"
fasta_seq_lengths="${transcriptome_dir}/${fasta_prefix}.fasta.seq_lens"

trinotate_feature_map="${transcriptome_dir}/20200409.cbai.trinotate.annotation_feature_map.txt"
gene_map="${transcriptome_dir}/${fasta_prefix}.fasta.gene_trans_map"
salmon_gene_matrix="${salmon_out_dir}/salmon.gene.TMM.EXPR.matrix"
salmon_iso_matrix="${salmon_out_dir}/salmon.isoform.TMM.EXPR.matrix"
go_annotations="${transcriptome_dir}/20200409.cbai.trinotate.go_annotations.txt"


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

# Rsync trimmed reads
rsync \
--archive \
--verbose \
${trimmed_reads_dir}/3297*trim*.gz .

# Concatenate reads
for fastq in *R1*.gz
do
  gunzip --to-stdout ${fastq} >> reads_1.fq
done

for fastq in *R2*.gz
do
  gunzip --to-stdout ${fastq} >> reads_2.fq
done

# Runs salmon and stranded library option
${trinity_abundance} \
--output_dir "${salmon_out_dir}" \
--transcripts ${transcriptome} \
--seqType fq \
--left reads_1.fq \
--right reads_2.fq \
--SS_lib_type RF \
--est_method salmon \
--gene_trans_map "${gene_map}" \
--prep_reference \
--thread_count "${threads}" \
1> ${salmon_stdout} \
2> ${salmon_stderr}


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
