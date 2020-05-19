#!/bin/bash
## Job Name
#SBATCH --job-name=transdecoder_cbai
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200519_cbai_transdecoder_transcriptome-v3.0


# Exit script if a command fails
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

# Set workind directory as current directory
wd="$(pwd)"

# Capture date as YYYYMMDD
timestamp=$(date +%Y%m%d)

# Set input file locations and species designation
trinity_fasta="/gscratch/srlab/sam/data/C_bairdi/transcriptomes/cbai_transcriptome_v3.0.fasta"
trinity_gene_map="/gscratch/srlab/sam/data/C_bairdi/transcriptomes/cbai_transcriptome_v3.0.fasta.gene_trans_map"
species="cbai"

# Capture trinity file name
trinity_fasta_name=${trinity_fasta##*/}



# Paths to input/output files
blastp_out_dir="${wd}/blastp_out"
transdecoder_out_dir="${wd}/${trinity_fasta_name}.transdecoder_dir"
pfam_out_dir="${wd}/pfam_out"
blastp_out="${blastp_out_dir}/${timestamp}.${species}.blastp.outfmt6"
pfam_out="${pfam_out_dir}/${timestamp}.${species}.pfam.domtblout"
lORFs_pep="${transdecoder_out_dir}/longest_orfs.pep"
pfam_db="/gscratch/srlab/programs/Trinotate-v3.1.1/admin/Pfam-A.hmm"
sp_db="/gscratch/srlab/programs/Trinotate-v3.1.1/admin/uniprot_sprot.pep"



# Paths to programs
blast_dir="/gscratch/srlab/programs/ncbi-blast-2.8.1+/bin"
blastp="${blast_dir}/blastp"
hmmer_dir="/gscratch/srlab/programs/hmmer-3.2.1/src"
hmmscan="${hmmer_dir}/hmmscan"
transdecoder_dir="/gscratch/srlab/programs/TransDecoder-v5.5.0"
transdecoder_lORFs="${transdecoder_dir}/TransDecoder.LongOrfs"
transdecoder_predict="${transdecoder_dir}/TransDecoder.Predict"

# Capture FastA MD5 checksum for future reference
md5sum "${trinity_fasta}" >> fasta.checksum.md5

# Make output directories
mkdir "${blastp_out_dir}"
mkdir "${pfam_out_dir}"

# Extract long open reading frames
"${transdecoder_lORFs}" \
--gene_trans_map "${trinity_gene_map}" \
-t "${trinity_fasta}"

# Run blastp on long ORFs
"${blastp}" \
-query "${lORFs_pep}" \
-db "${sp_db}" \
-max_target_seqs 1 \
-outfmt 6 \
-evalue 1e-5 \
-num_threads 28 \
> "${blastp_out}"

# Run pfam search
"${hmmscan}" \
--cpu 28 \
--domtblout "${pfam_out}" \
"${pfam_db}" \
"${lORFs_pep}"

# Run Transdecoder with blastp and Pfam results
"${transdecoder_predict}" \
-t "${trinity_fasta}" \
--retain_pfam_hits "${pfam_out}" \
--retain_blastp_hits "${blastp_out}"
