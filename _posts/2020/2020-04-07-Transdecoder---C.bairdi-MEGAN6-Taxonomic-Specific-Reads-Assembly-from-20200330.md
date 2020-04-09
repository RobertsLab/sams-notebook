---
layout: post
title: Transdecoder - C.bairdi MEGAN6 Taxonomic-Specific Reads Assembly from 20200330
date: '2020-04-07 11:47'
tags:
  - transdecoder
  - mox
  - Tanner crab
  - Chionoecetes bairdi
categories:
  - Miscellaneous
---
[Ran Trinity to _de novo_ assembly on the the _Arthropoda_ MEGAN6 taxonomic-specific RNAseq data on 20120330](https://robertslab.github.io/sams-notebook/2020/03/30/Transcriptome-Assembly-C.bairdi-with-MEGAN6-Taxonomy-specific-Reads-with-Trinity-on-Mox.html) and now will begin annotating the transcriptome using TransDecoder on Mox.



SBATCH script (GitHub):

- [20200407_cbai_transdecoder_megan.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200407_cbai_transdecoder_megan.sh)

```shell
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200407_cbai_transdecoder_megan


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
trinity_fasta="/gscratch/srlab/sam/data/C_bairdi/transcriptomes/20200408.C_bairdi.megan.Trinity.fasta"
trinity_gene_map="/gscratch/srlab/sam/data/C_bairdi/transcriptomes/20200408.C_bairdi.megan.Trinity.fasta.gene_trans_map"
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

Took about 7.75hrs:

![cbai transdecoder runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200407_cbai_transdecoder_megan_runtime.png?raw=true)

Output folder:

- [20200407_cbai_transdecoder_megan/](https://gannet.fish.washington.edu/Atumefaciens/20200407_cbai_transdecoder_megan/)

Coding Sequences (FastA):

- [20200408.C_bairdi.megan.Trinity.fasta.transdecoder.cds](https://gannet.fish.washington.edu/Atumefaciens/20200407_cbai_transdecoder_megan/20200408.C_bairdi.megan.Trinity.fasta.transdecoder.cds)

Peptide Sequences (FastA):

- [20200408.C_bairdi.megan.Trinity.fasta.transdecoder.pep](https://gannet.fish.washington.edu/Atumefaciens/20200407_cbai_transdecoder_megan/20200408.C_bairdi.megan.Trinity.fasta.transdecoder.pep)

BLASTp output (tab):

- [20200407_cbai_transdecoder_megan/blastp_out/20200408.C_bairdi.blastp.outfmt6](https://gannet.fish.washington.edu/Atumefaciens/20200407_cbai_transdecoder_megan/blastp_out/20200408.C_bairdi.blastp.outfmt6)

Pfam output:

- [20200407_cbai_transdecoder_megan/pfam_out/20200408.C_bairdi.pfam.domtblout](https://gannet.fish.washington.edu/Atumefaciens/20200407_cbai_transdecoder_megan/pfam_out/20200408.C_bairdi.pfam.domtblout)

Will get ready to run Trinotate with these output files.
