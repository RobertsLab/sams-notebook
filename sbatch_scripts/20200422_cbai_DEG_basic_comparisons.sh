#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_DEG_basic
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200422_cbai_DEG_basic_comparisons

# This is a script to identify differentially expressed genes (DEGs) in C.bairdi
# using pairwise comparisions of from just the "2020-GW" (i.e. just Genewiz) RNAseq data
# which has been taxonomically selected for all Arthropoda reads. See Sam's notebook from 20200419
# https://robertslab.github.io/sams-notebook/

# Script will run Trinity's builtin differential gene expression analysis using:
# - Salmon alignment-free transcript abundance estimation
# - edgeR
# Cutoffs of 2-fold difference in expression and FDR of <=0.05.

###################################################################################
# These variables need to be set by user
fastq_dir="/gscratch/srlab/sam/data/C_bairdi/RNAseq/"
fasta_prefix="20200408.C_bairdi.megan.Trinity"
transcriptome_dir="/gscratch/srlab/sam/data/C_bairdi/transcriptomes"
trinotate_feature_map="${transcriptome_dir}/20200409.cbai.trinotate.annotation_feature_map.txt"
go_annotations="${transcriptome_dir}/20200409.cbai.trinotate.go_annotations.txt"

# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
comparisons_array=(
infected-uninfected \
D9-D12 \
D9-D26 \
D12-D26 \
ambient-cold \
ambient-warm \
cold-warm
)

# Functions
# Expects input (i.e. "$1") to be in the following format:
# e.g. 20200413.C_bairdi.113.D9.uninfected.cold.megan_R2.fq
get_day () { day=$(echo "$1" | awk -F"." '{print $4}'); }
get_inf () { inf=$(echo "$1" | awk -F"." '{print $5}'); }
get_temp () { temp=$(echo "$1" | awk -F"." '{print $6}'); }

###################################################################################


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
threads=28


## Designate input file locations
transcriptome="${transcriptome_dir}/${fasta_prefix}.fasta"
fasta_seq_lengths="${transcriptome_dir}/${fasta_prefix}.fasta.seq_lens"
samples="${wd}/${comparison}.samples.txt"
gene_map="${transcriptome_dir}/${fasta_prefix}.fasta.gene_trans_map"
salmon_gene_matrix="${comparison_dir}/salmon.gene.TMM.EXPR.matrix"
salmon_iso_matrix="${comparison_dir}/salmon.isoform.TMM.EXPR.matrix"
transcriptome="${transcriptome_dir}/${fasta_prefix}.fasta"


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

# Loop through each comparison
# Will create comparison-specific direcctories and copy
# appropriate FastQ files for each comparison.

# After file transfer, will create necessary sample list file for use
# by Trinity for running differential gene expression analysis and GO enrichment.
for comparison in "${!comparisons_array[@]}"
do

  # Assign variables
  cond1_count=0
  cond2_count=0
  comparison=${comparisons_array[${comparison}]}
  samples="${comparison}.samples.txt"
  comparison_dir="${wd}/${comparison}/"

  # Extract each comparison from comparisons array
  # Conditions must be separated by a "-"
  cond1=$(echo "${comparison}" | awk -F"-" '{print $1}')
  cond2=$(echo "${comparison}" | awk -F"-" '{print $2}')


  mkdir --parents "${comparison}"

  cd "${comparison}" || exit

  # Series of if statements to identify which FastQ files to rsync to working directory
  if [[ "${comparison}" == "infected-uninfected" ]]; then
    rsync --archive --verbose ${fastq_dir}*.fq .
  fi

  if [[ "${comparison}" == "D9-D12" ]]; then
    for fastq in "${fastq_dir}"*.fq
    do
      get_day "${fastq}"
      if [[ "${day}" == "D9" || "${day}" == "D12" ]]; then
        rsync --archive --verbose "${fastq}" .
      fi
    done
  fi

  if [[ "${comparison}" == "D9-D26" ]]; then
    for fastq in "${fastq_dir}"*.fq
    do
      get_day "${fastq}"
      if [[ "${day}" == "D9" || "${day}" == "D26" ]]; then
        rsync --archive --verbose "${fastq}" .
      fi
    done
  fi

  if [[ "${comparison}" == "D12-D26" ]]; then
    for fastq in "${fastq_dir}"*.fq
    do
      get_day "${fastq}"
      if [[ "${day}" == "D12" || "${day}" == "D26" ]]; then
        rsync --archive --verbose "${fastq}" .
      fi
    done
  fi

  if [[ "${comparison}" == "ambient-cold" ]]; then
    #statements
    for fastq in "${fastq_dir}"*.fq
    do
      get_temp "${fastq}"
      if [[ "${temp}" == "ambient" || "${temp}" == "cold" ]]; then
        rsync --archive --verbose "${fastq}" .
      fi
    done
  fi

  if [[ "${comparison}" == "ambient-warm" ]]; then
    for fastq in "${fastq_dir}"*.fq
    do
      get_temp "${fastq}"
      if [[ "${temp}" == "ambient" || "${temp}" == "warm" ]]; then
        rsync --archive --verbose "${fastq}" .
      fi
    done
  fi

  if [[ "${comparison}" == "cold-warm" ]]; then
    for fastq in "${fastq_dir}"*.fq
    do
      get_temp "${fastq}"
      if [[ "${temp}" == "cold" || "${temp}" == "warm" ]]; then
        rsync --archive --verbose "${fastq}" .
      fi
    done
  fi

  # Create reads array
  # Paired reads files will be sequentially listed in array (e.g. 111_R1 111_R2)
  reads_array=(*.fq)

  echo ""
  echo "Created reads_array"

  # Loop to create sample list file
  # Sample file list is tab-delimited like this:

  # cond_A    cond_A_rep1    A_rep1_left.fq    A_rep1_right.fq
  # cond_A    cond_A_rep2    A_rep2_left.fq    A_rep2_right.fq
  # cond_B    cond_B_rep1    B_rep1_left.fq    B_rep1_right.fq
  # cond_B    cond_B_rep2    B_rep2_left.fq    B_rep2_right.fq



  # Increment by 2 to process next pair of FastQ files
  for (( i=0; i<${#reads_array[@]} ; i+=2 ))
  do
    echo ""
    echo "Evaluating ${reads_array[i]} and ${reads_array[i+1]}"
    get_day "${reads_array[i]}"
    get_inf "${reads_array[i]}"
    get_temp "${reads_array[i]}"

    echo ""
    echo "Got day (${day}), infection status (${inf}), and temp (${temp})."
    echo ""
    echo "Condition 1 is: ${cond1}"
    echo "condition 2 is: ${cond2}"

    # Evaluate specified treatment conditions and format sample file list appropriately.
    if [[ "${cond1}" == "${day}" || "${cond1}" == "${inf}" || "${cond1}" == "${temp}" ]]; then
      ((cond1_count++))

      echo ""
      echo "Condition 1 evaluated."
      # Create tab-delimited samples file.
      printf "%s\t%s%02d\t%s\t%s\n" "${cond1}" "${cond1}_" "${cond1_count}" "${comparison_dir}${reads_array[i]}" "${comparison_dir}${reads_array[i+1]}" \
      >> "${samples}"
    elif [[ "${cond2}" == "${day}" || "${cond2}" == "${inf}" || "${cond2}" == "${temp}" ]]; then
      ((cond2_count++))

      echo ""
      echo "Condition 2 evaluated."
      # Create tab-delimited samples file.
      printf "%s\t%s%02d\t%s\t%s\n" "${cond2}" "${cond2}_" "${cond2_count}" "${comparison_dir}${reads_array[i]}" "${comparison_dir}${reads_array[i+1]}" \
      >> "${samples}"
    fi

    # Copy sample list file to transcriptome directory
    cp "${samples}" "${transcriptome_dir}"
  done

  echo "Created ${comparison} sample list file."


  # Create directory/sample list for ${trinity_matrix} command
  trin_matrix_list=$(awk '{printf "%s%s", $2, "/quant.sf " }' "${samples}")


  # Determine transcript abundances using Salmon alignment-free
  # abundance estimate.
  ${trinity_abundance} \
  --output_dir "${comparison_dir}" \
  --transcripts ${transcriptome} \
  --seqType fq \
  --samples_file "${samples}" \
  --est_method salmon \
  --aln_method bowtie2 \
  --gene_trans_map "${gene_map}" \
  --prep_reference \
  --thread_count "${threads}" \
  1> "${comparison_dir}"${salmon_stdout} \
  2> "${comparison_dir}"${salmon_stderr}

  # Convert abundance estimates to matrix
  ${trinity_matrix} \
  --est_method salmon \
  --gene_trans_map ${gene_map} \
  --out_prefix salmon \
  --name_sample_by_basedir \
  ${trin_matrix_list} \
  1> ${matrix_stdout} \
  2> ${matrix_stderr}

  # Integrate Trinotate functional annotations
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
  1> ${tpm_length_stdout} \
  2> ${tpm_length_stderr}

  # Differential expression analysis
  # Utilizes edgeR.
  # Needs to be run in same directory as transcriptome.
  cd ${transcriptome_dir} || exit
  ${trinity_DE} \
  --matrix "${comparison_dir}"/salmon.gene.counts.matrix \
  --method edgeR \
  --samples_file "${samples}" \
  1> ${trinity_DE_stdout} \
  2> ${trinity_DE_stderr}

  mv edgeR* "${comparison_dir}"


  # Run differential expression on edgeR output matrix
  # Set fold difference to 2-fold (ie. -C 1 = 2^1)
  # P value <= 0.05
  # Has to run from edgeR output directory

  # Pulls edgeR directory name and removes leading ./ in find output
  # Using find is required because edgeR names directory using PID
  # and I don't know how to find that out
  cd "${comparison_dir}" || exit
  edgeR_dir=$(find . -type d -name "edgeR*" | sed 's%./%%')
  cd "${edgeR_dir}" || exit
  mv "${transcriptome_dir}/${trinity_DE_stdout}" .
  mv "${transcriptome_dir}/${trinity_DE_stderr}" .
  ${diff_expr} \
  --matrix "${salmon_gene_matrix}" \
  --samples "${samples}" \
  --examine_GO_enrichment \
  --GO_annots "${go_annotations}" \
  --include_GOplot \
  --gene_lengths "${comparison_dir}"/Trinity.gene_lengths.txt \
  -C 1 \
  -P 0.05 \
  1> ${diff_expr_stdout} \
  2> ${diff_expr_stderr}



  cd "${wd}" || exit
done
