---
layout: post
title: Annotation - Olurida_v081 MAKER Functional Annotations on Mox
date: '2019-01-09 11:10'
tags:
  - Ostrea lurida
  - Olympia oyster
  - mox
  - MAKER
  - Olurida_v081
  - annotation
categories:
  - Olympia Oyster Genome Sequencing
---
Believe it or not, full, proper annotation of the Olympia oyster genome is nearly complete! Here's where it stands:

- [ X ] [Gene prediction/modelling with MAKER and SNAP](https://robertslab.github.io/sams-notebook/2018/11/27/Annotation-Olurida_v081-MAKER-on-Mox.html)

- [ X ] [Renaming output files to use NCBI-friendly naming scheme](https://robertslab.github.io/sams-notebook/2019/01/08/Annotation-Olurida_v081-MAKER-ID-Mapping.html)

- [ X ] [Functional annotation using BLASTp](https://robertslab.github.io/sams-notebook/2019/01/08/Annotation-Olurida_v081-MAKER-Proteins-BLASTp.html)

- [ X ] [Functional domain and GO term annotation using InterProScan5](https://robertslab.github.io/sams-notebook/2019/01/08/Annotation-Olurida_v081-MAKER-Proteins-InterProScan5-on-Mox.html)

- [  ] Combine the functional annotations in to final FastA and GFF files.

I ran the following SBATCH script on Mox to tackle that last item:

- [20190109_oly_maker_functional_annotation/20190109_oly_maker_functional_annotation.sh](https://gannet.fish.washington.edu/Atumefaciens/20190109_oly_maker_functional_annotation/20190109_oly_maker_functional_annotation.sh) (text file)

<pre><code>
#!/bin/bash
## Job Name
#SBATCH --job-name=maker
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=15-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --workdir=/gscratch/scrubbed/samwhite/outputs/20190109_oly_maker_functional_annotation

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Load Open MPI module for parallel, multi-node processing

module load icc_19-ompi_3.1.2

# SegFault fix?
export THREADS_DAEMON_MODEL=1

# Document programs in PATH (primarily for program version ID)

date >> system_path.log
echo "" >> system_path.log
echo "System PATH for $SLURM_JOB_ID" >> system_path.log
echo "" >> system_path.log
printf "%0.s-" {1..10} >> system_path.log
echo ${PATH} | tr : \\n >> system_path.log

# Variables
maker_dir=/gscratch/srlab/programs/maker-2.31.10/bin

maker_prot_fasta=/gscratch/scrubbed/samwhite/outputs/20190108_oly_maker_id_mapping/20181127_oly_genome_snap02.all.maker.proteins.renamed.fasta
maker_put_prot_fasta=20181127_oly_genome_snap02.all.maker.proteins.renamed.putative_function.fasta
maker_transcripts_fasta=/gscratch/scrubbed/samwhite/outputs/20190108_oly_maker_id_mapping/20181127_oly_genome_snap02.all.maker.transcripts.renamed.fasta
maker_put_transcripts_fasta=20181127_oly_genome_snap02.all.maker.transcripts.renamed.putative_function.fasta
snap02_gff=/gscratch/scrubbed/samwhite/outputs/20190108_oly_maker_id_mapping/20181127_oly_genome_snap02.all.renamed.gff
snap02_put_gff=20181127_oly_genome_snap02.all.renamed.putative_function.gff
snap02_put_domains_gff=20181127_oly_genome_snap02.all.renamed.putative_function.domain_added.gff
snap02_put_domains_visible_gff=20181127_oly_genome_snap02.all.renamed.visible_ips_domains.gff
blastp_out=/gscratch/scrubbed/samwhite/outputs/20190108_oly_maker_blastp/20190108_blastp.outfmt6
maker_ips=/gscratch/scrubbed/samwhite/outputs/20190108_oly_maker_interproscan/20190108_oly_maker_proteins_ips.tsv
sp_db=/gscratch/srlab/blastdbs/UniProtKB_20190109/uniprot_sprot.fasta



## Add putative gene functions
### GFF
${maker_dir}/maker_functional_gff \
${sp_db} \
${blastp_out} \
${snap02_gff} \
> ${snap02_put_gff}

### Proteins
${maker_dir}/maker_functional_fasta \
${sp_db} \
${blastp_out} \
${maker_prot_fasta} \
> ${maker_put_prot_fasta}

### Transcripts
${maker_dir}/maker_functional_fasta \
${sp_db} \
${blastp_out} \
${maker_transcripts_fasta} \
> ${maker_put_transcripts_fasta}

## Add InterProScan domain info
### Add searchable tags
${maker_dir}/ipr_update_gff \
${snap02_put_gff} \
${maker_ips} \
> ${snap02_put_domains_gff}

### Add viewable features for genome browsers (JBrowse, Gbrowse, Web Apollo)
${maker_dir}/iprscan2gff3 \
${maker_ips} \
${snap02_gff} \
> ${snap02_put_domains_visible_gff}

</code></pre>

---

#### RESULTS

Awesome!!! I can't believe this is actually complete!!! It's been a long, long road.

A quick summary of the big picture results:

- 139671 coding sequences

- 142530 exons

- 9468 5' UTRs

- 24680 genes

- 24680 mRNAs

- 6598 3' UTRs

Next, I'd like to evaluate the genome using BUSCO, as well as run a final gene training/modeling with Augustus.

Output folder:

- [20190109_oly_maker_functional_annotation/](https://gannet.fish.washington.edu/Atumefaciens/20190109_oly_maker_functional_annotation/)

GFF (2.3GB):

- [20190109_oly_maker_functional_annotation/20181127_oly_genome_snap02.all.renamed.putative_function.domain_added.gff](https://gannet.fish.washington.edu/Atumefaciens/20190109_oly_maker_functional_annotation/20181127_oly_genome_snap02.all.renamed.putative_function.domain_added.gff)

Proteins FastA (12MB):

- [20190109_oly_maker_functional_annotation/20181127_oly_genome_snap02.all.maker.proteins.renamed.putative_function.fasta](https://gannet.fish.washington.edu/Atumefaciens/20190109_oly_maker_functional_annotation/20181127_oly_genome_snap02.all.maker.proteins.renamed.putative_function.fasta)

Transcripts FastA (32MB):

- [20190109_oly_maker_functional_annotation/20181127_oly_genome_snap02.all.maker.transcripts.renamed.putative_function.fasta](https://gannet.fish.washington.edu/Atumefaciens/20190109_oly_maker_functional_annotation/20181127_oly_genome_snap02.all.maker.transcripts.renamed.putative_function.fasta)
