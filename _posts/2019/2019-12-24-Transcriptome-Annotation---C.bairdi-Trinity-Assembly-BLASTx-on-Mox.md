---
layout: post
title: Transcriptome Annotation - C.bairdi Trinity Assembly BLASTx on Mox
date: '2019-12-24 20:36'
tags:
  - transcriptome
  - annotation
  - tanner crab
  - blastx
  - mox
  - Chionoecetes bairdi
categories:
  - Tanner Crab RNAseq
---
In preparation for complete transcriptome annotation of the [_C.bairdi_ _de novo_ assembly fro 20191218](https://robertslab.github.io/sams-notebook/2019/12/18/Transcriptome-Assembly-C.bairdi-Trimmed-RNAseq-Using-Trinity-on-Mox.html), I needed to run BLASTx. The assembly was BLASTed against the SwissProt database that comes with [Trinotate](https://github.com/Trinotate/Trinotate.github.io/wiki). Initial BLAST output format selected was format 11 (i.e. ASN format), as this allows for simple conversion between different formats later on, if desired.

SBATCH script (GitHub):

- [0191224_cbai_blastx_outfmt-11.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20191224_cbai_blastx_outfmt-11.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=blastx_cbai
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=25-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20191224_cbai_blastx_outfmt-11

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

# Paths to input/output files
blastx_out="${wd}/${timestamp}-20191218.C_bairdi.Trinity.fasta.blastx.asn"
sp_db="/gscratch/srlab/programs/Trinotate-v3.1.1/admin/uniprot_sprot.pep"

trinity_fasta="/gscratch/scrubbed/samwhite/outputs/20191218_cbai_trinity_RNAseq/trinity_out_dir/20191218.C_bairdi.Trinity.fasta"

# Paths to programs
blast_dir="/gscratch/srlab/programs/ncbi-blast-2.8.1+/bin"
blastx="${blast_dir}/blastx"

threads=28

# Run blastx on Trinity fasta
"${blastx}" \
-query "${trinity_fasta}" \
-db "${sp_db}" \
-max_target_seqs 1 \
-outfmt 11 \
-evalue 1e-4 \
-num_threads "${threads}" \
> "${blastx_out}"
```
---

#### RESULTS

This took a bit over 17hrs to complete:

![cbai blastx runtime screencap](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20191224_cbai_blastx_outfmt-11_runtime.png?raw=true)

I also realized, after the fact, that I need output format 6 to use in Trinotate, so I performed the formate conversion with the following command:

```shell
/gscratch/srlab/programs/ncbi-blast-2.8.1+/bin/blast_formatter \
-archive 20191224-20191218.C_bairdi.Trinity.fasta.blastx.asn \
-outfmt 6 \
-out 20191224-20191218.C_bairdi.Trinity.fasta.blastx.outfmt6
```

Output folder:

- [20191224_cbai_blastx_outfmt-11/](https://gannet.fish.washington.edu/Atumefaciens/20191224_cbai_blastx_outfmt-11/)

BLASTx output (ASN):

- [20191224_cbai_blastx_outfmt-11/20191224-20191218.C_bairdi.Trinity.fasta.blastx.asn](https://gannet.fish.washington.edu/Atumefaciens/20191224_cbai_blastx_outfmt-11/20191224-20191218.C_bairdi.Trinity.fasta.blastx.asn) (1.9GB)

BLASTx output (format 6):

- [20191224-20191218.C_bairdi.Trinity.fasta.blastx.outfmt6](https://gannet.fish.washington.edu/Atumefaciens/20191224_cbai_blastx_outfmt-11/20191224-20191218.C_bairdi.Trinity.fasta.blastx.outfmt6)

This BLASTx file will be used for complete transcriptome annotation using Trinotate.

BLAST is also capable of converting the ASN output format into any other BLAST output format (e.g. format 6), so having BLAST results in ASN format provides a bit more flexibility. However, conversion from ASN to another BLAST output format requires the BLAST database to exist in the same location as the initial BLAST! Thus, if using the ASN output format (i.e. format 11), it is imperative that the BLAST database is in the same directory as the output file! To illustrate this, I can now only convert between formats by running this on Mox and using the BLAST database located here: `/gscratch/srlab/programs/Trinotate-v3.1.1/admin/uniprot_sprot.pep`. This greatly hinders portability and reproducibility.
