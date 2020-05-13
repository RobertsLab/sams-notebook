---
layout: post
title: TransDecoder - C.bairdi Transcriptome v2.0 from 20200502 on Mox
date: '2020-05-08 08:13'
tags:
  - Chionoecetes bairdi
  - Tanner crab
  - mox
  - transdecoder
categories:
  - Miscellaneous
---
Need to run TransDecoder on Mox on the [_C.bairdi_ transcriptome v2.0 from 20200502](https://robertslab.github.io/sams-notebook/2020/05/02/Transcriptome-Assembly-C.bairdi-All-RNAseq-Data-Without-Taxonomic-Filters-with-Trinity-on-Mox.html).



SBATCH script (GitHub):

- [20200508_cbai_transdecoder_transcriptome-v2.0.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200508_cbai_transdecoder_transcriptome-v2.0.sh)


```
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
#SBATCH --time=1-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200508_cbai_transdecoder_transcriptome-v2.0


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
trinity_fasta="/gscratch/srlab/sam/data/C_bairdi/transcriptomes/20200507.C_bairdi.Trinity.fasta"
trinity_gene_map="/gscratch/srlab/sam/data/C_bairdi/transcriptomes/20200507.C_bairdi.Trinity.fasta.gene_trans_map"
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
```


---

#### RESULTS

Took a bit over four days to run (not including short downtime due to the initial job running out of time):

![TransDecoder runtime for v2.0 transcriptome](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200508_cbai_transdecoder_transcriptome-v2.0_runtime.png?raw=true)

Output folder:

- [20200508_cbai_transdecoder_transcriptome-v2.0/](https://gannet.fish.washington.edu/Atumefaciens/20200508_cbai_transdecoder_transcriptome-v2.0/)

BED (text; 102MB)

- [20200507.C_bairdi.Trinity.fasta.transdecoder.bed](https://gannet.fish.washington.edu/Atumefaciens/20200508_cbai_transdecoder_transcriptome-v2.0/20200507.C_bairdi.Trinity.fasta.transdecoder.bed]

CDS (FastA; 357MB)

- [20200507.C_bairdi.Trinity.fasta.transdecoder.cds](https://gannet.fish.washington.edu/Atumefaciens/20200508_cbai_transdecoder_transcriptome-v2.0/20200507.C_bairdi.Trinity.fasta.transdecoder.cds]

GFF3 (text; 367MB)

- [20200507.C_bairdi.Trinity.fasta.transdecoder.gff3](https://gannet.fish.washington.edu/Atumefaciens/20200508_cbai_transdecoder_transcriptome-v2.0/20200507.C_bairdi.Trinity.fasta.transdecoder.gff3]

Peptides (FastA; 184MB)

- [20200507.C_bairdi.Trinity.fasta.transdecoder.pep](https://gannet.fish.washington.edu/Atumefaciens/20200508_cbai_transdecoder_transcriptome-v2.0/20200507.C_bairdi.Trinity.fasta.transdecoder.pep]

---

The files linked below are needed as inputs for Trinotate:

BLASTp (text; outfmt6; 16MB):

- [20200508_cbai_transdecoder_transcriptome-v2.0/blastp_out/20200508.cbai.blastp.outfmt6](https://gannet.fish.washington.edu/Atumefaciens/20200508_cbai_transdecoder_transcriptome-v2.0/blastp_out/20200508.cbai.blastp.outfmt6)

pfam (420MB):

- [20200508_cbai_transdecoder_transcriptome-v2.0/pfam_out/20200508.cbai.pfam.domtblout](https://gannet.fish.washington.edu/Atumefaciens/20200508_cbai_transdecoder_transcriptome-v2.0/pfam_out/20200508.cbai.pfam.domtblout)

Longest Peptide ORFs (FastA; 209MB):

- [20200508_cbai_transdecoder_transcriptome-v2.0/20200507.C_bairdi.Trinity.fasta.transdecoder_dir/longest_orfs.pep](https://gannet.fish.washington.edu/Atumefaciens/20200508_cbai_transdecoder_transcriptome-v2.0/20200507.C_bairdi.Trinity.fasta.transdecoder_dir/longest_orfs.pep)
