---
layout: post
title: ORF Identification - L.staminea De Novo Transcriptome Assembly v1.0 Using Transdecoder on Mox
date: '2023-06-17 15:27'
tags: 
  - Leukoma staminea
  - little neck clam
  - transdecoder
  - mox
categories: 
  - Miscellaneous
---
After [performing a _de novo_ transcriptome assembly with _L.staminea_ RNA-seq data](https://robertslab.github.io/sams-notebook/2023/06/16/Transcriptome-Assembly-De-Novo-L.staminea-Trimmed-RNAseq-Using-Trinity-on-Mox.html), the [`Trinity`](https://github.com/trinityrnaseq/trinityrnaseq/wiki) assembly stats were quite a bit more "exaggerated" than normally expected. In an attempt to get a better sense of which contigs might be more useful candidates for downstream analysis, I decided to run the assembly through [Transdecoder](https://github.com/TransDecoder/TransDecoder/wiki) to identify open reading frames (ORFs). This was run on Mox.

SLURM script (GitHub):

- [20230617-lsta-transdecoder-transcriptome_v1.0.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20230617-lsta-transdecoder-transcriptome_v1.0.sh)

```bash
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

# Transdecoder to identify ORFs and "functional" contigs from 20230616 L.staminea
# de novo transcriptome assembly v1.0.

###################################################################################
# These variables need to be set by user

## Assign Variables

threads=28


# Paths to input/output files

trinity_fasta="/gscratch/scrubbed/samwhite/outputs/20230616-lsta-trinity-RNAseq/lsta-de_novo-transcriptome_v1.0.fasta"
trinity_gene_trans_map="/gscratch/scrubbed/samwhite/outputs/20230616-lsta-trinity-RNAseq/lsta-de_novo-transcriptome_v1.0.fasta.gene_trans_map"

blastp_out_dir="blastp_out"
transdecoder_out_dir="${trinity_fasta##*/}.transdecoder_dir"
pfam_out_dir="pfam_out"
blastp_out="${blastp_out_dir}/blastp.outfmt6"

pfam_out="${pfam_out_dir}/pfam.domtblout"
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
###################################################################################


# Load Python Mox module for Python module availability
module load intel-python3_2017


# Make output directories
mkdir --parents "${blastp_out_dir}"
mkdir --parents "${pfam_out_dir}"

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
```


---

#### RESULTS

Run time was nearly 20hrs.

![Screencap of L.staminea Transdecoder run time on Mox showing a run time of 19hrs, 12mins, 51secs](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20230617-lsta-transdecoder-transcriptome_v1.0-runtime.png?raw=true)

Output folder:

- [20230617-lsta-transdecoder-transcriptome_v1.0/](https://gannet.fish.washington.edu/Atumefaciens/20230617-lsta-transdecoder-transcriptome_v1.0/)

  #### BED (text)
  - [lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.bed](https://gannet.fish.washington.edu/Atumefaciens/20230617-lsta-transdecoder-transcriptome_v1.0/lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.bed) (30M)

    - MD5: `02497568c87e65279e83551ba8fb43ae`

  #### Coding Sequences (FastA)
  - [lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.cds](https://gannet.fish.washington.edu/Atumefaciens/20230617-lsta-transdecoder-transcriptome_v1.0/lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.cds) (98M)

    - MD5: `1517d724b18d0bd8759cbccc0487e460`

  #### GFF (text)
  - [lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.gff3](https://gannet.fish.washington.edu/Atumefaciens/20230617-lsta-transdecoder-transcriptome_v1.0/lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.gff3) (99M)

    - MD5: `901ab1c9ca1c0998714ff9cd602b2063`

  #### Peptide Sequences (FastA)
  - [lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.pep](https://gannet.fish.washington.edu/Atumefaciens/20230617-lsta-transdecoder-transcriptome_v1.0/lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.pep) (52M)

    - MD5: `53752bdb28bf2f89a04620bcee109a4f`

  #### Pfam output (text)
  - [pfam.domtblout](https://gannet.fish.washington.edu/Atumefaciens/20230617-lsta-transdecoder-transcriptome_v1.0/pfam_out/pfam.domtblout) (132M)

  - MD5: `18cd0fdff4993ed7f1d8f7d36f83e1d6`

  #### BLASTp output (format 6; text)
  - [blastp.outfmt6](https://gannet.fish.washington.edu/Atumefaciens/20230617-lsta-transdecoder-transcriptome_v1.0/blastp_out/blastp.outfmt6) (6.2M)

  - MD5: `c416fbe543555672083f1a63a4935ed0`

When counting complete ORFs (`awk -F"\t" '$3=="gene"' lsta-de_novo-transcriptome_v1.0.fasta.transdecoder.gff3 | grep -c "complete"`), the result is 28,451. This is a _significant_ reduction in potential genes compared to what [Trinity identified in the _do novo_ assembly from yesterday](https://robertslab.github.io/sams-notebook/2023/06/16/Transcriptome-Assembly-De-Novo-L.staminea-Trimmed-RNAseq-Using-Trinity-on-Mox.html) (502,826 "genes"). Additionally, this is a much more realistic number of genes. Overall, ORF identification broke out like so:

```
74533 CDS
74533 exon
35983 five_prime_UTR
74533 gene
74533 mRNA
43403 three_prime_UTR
```

These numbers include partial ORFs. Even including the partial OFRs, these counts are much more realistic compared to the Trinity _de novo_ assembly stats. 