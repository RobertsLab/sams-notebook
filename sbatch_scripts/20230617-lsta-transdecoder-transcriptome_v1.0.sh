#!/bin/bash
## Job Name
#SBATCH --job-name=20230617-lsta-transdecoder-transcriptome_v1.0
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=05-00:00:00
## Memory per node
#SBATCH --mem=200G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230617-lsta-transdecoder-transcriptome_v1.0


###################################################################################
# These variables need to be set by user

## Assign Variables

threads=28

# Paths to input/output files
blastp_out_dir="${wd}/blastp_out"
transdecoder_out_dir="${wd}/Trinity.fasta.transdecoder_dir"
pfam_out_dir="${wd}/pfam_out"
blastp_out="${blastp_out_dir}/blastp.outfmt6"

pfam_out="${pfam_out_dir}/pfam.domtblout"
lORFs_pep="${transdecoder_out_dir}/longest_orfs.pep"
pfam_db="/gscratch/srlab/programs/Trinotate-v3.1.1/admin/Pfam-A.hmm"
sp_db="/gscratch/srlab/programs/Trinotate-v3.1.1/admin/uniprot_sprot.pep"

trinity_fasta="/gscratch/scrubbed/samwhite/outputs/20230616-lsta-trinity-RNAseq/lsta-de_novo-transcriptome_v1.0.fasta"
trinity_gene_trans_map="/gscratch/scrubbed/samwhite/outputs/20230616-lsta-trinity-RNAseq/lsta-de_novo-transcriptome_v1.0.fasta.gene_trans_map"

# Paths to programs
blast_dir="/gscratch/srlab/programs/ncbi-blast-2.8.1+/bin"
blastp="${blast_dir}/blastp"
hmmer_dir="/gscratch/srlab/programs/hmmer-3.2.1/src"
hmmscan="${hmmer_dir}/hmmscan"
transdecoder_dir="/gscratch/srlab/programs/TransDecoder-v5.5.0"
transdecoder_lORFs="${transdecoder_dir}/TransDecoder.LongOrfs"
transdecoder_predict="${transdecoder_dir}/TransDecoder.Predict"
###################################################################################


# Load Python Mox module for Python module availability
module load intel-python3_2017


wd="$(pwd)"


# Make output directories
mkdir --parents ${blastp_out_dir}
mkdir --parents ${pfam_out_dir}

# Extract long open reading frames
${transdecoder_lORFs} \
-t ${trinity_fasta} \
--gene_trans_map ${trinity_gene_trans_map}

# Run blastp on long ORFs
${blastp} \
-query ${lORFs_pep} \
-db ${sp_db} \
-max_target_seqs 1 \
-outfmt 6 \
-evalue 1e-5 \
-num_threads ${threads} \
> ${blastp_out}

# Run pfam search
${hmmscan} \
--cpu ${threads} \
--domtblout ${pfam_out} \
${pfam_db} \
${lORFs_pep}

# Run Transdecoder with blastp and Pfam results
${transdecoder_predict} \
-t ${trinity_fasta} \
--retain_pfam_hits ${pfam_out} \
--retain_blastp_hits ${blastp_out}

####################################################################

# Capture program options
if [[ "${#programs_array[@]}" -gt 0 ]]; then
  echo "Logging program options..."
  for program in "${!programs_array[@]}"
  do
    {
    echo "Program options for ${program}: "
    echo ""
    # Handle samtools help menus
    if [[ "${program}" == "samtools_index" ]] \
    || [[ "${program}" == "samtools_sort" ]] \
    || [[ "${program}" == "samtools_view" ]]
    then
      ${programs_array[$program]}

    # Handle DIAMOND BLAST menu
    elif [[ "${program}" == "diamond" ]]; then
      ${programs_array[$program]} help

    # Handle NCBI BLASTx menu
    elif [[ "${program}" == "blastx" ]]; then
      ${programs_array[$program]} -help

    # Handle fastp menu
    elif [[ "${program}" == "fastp" ]]; then
      ${programs_array[$program]} --help
    fi
    ${programs_array[$program]} -h
    echo ""
    echo ""
    echo "----------------------------------------------"
    echo ""
    echo ""
  } &>> program_options.log || true

    # If MultiQC is in programs_array, copy the config file to this directory.
    if [[ "${program}" == "multiqc" ]]; then
      cp --preserve ~/.multiqc_config.yaml multiqc_config.yaml
    fi
  done
fi


# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log
