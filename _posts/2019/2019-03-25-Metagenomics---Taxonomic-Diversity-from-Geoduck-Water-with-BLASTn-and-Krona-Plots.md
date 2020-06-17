---
layout: post
title: Metagenomics - Taxonomic Diversity from Geoduck Water with BLASTn and Krona Plots
date: '2019-03-25 20:26'
tags:
  - geoduck
  - Panopea generosa
  - blastn
  - krona
  - metagenomics
categories:
  - Miscellaneous
---
Continuing on getting the metagenomics sequencing project written up as a manuscript, Steven asked me to provide an overview of the taxonomic makeup of our metagenome assembly in this [GitHub Issue](https://github.com/RobertsLab/resources/issues/547). Earlier today, I [ran analysis using BLASTp data](https://robertslab.github.io/sams-notebook/2019/03/25/Metagenomics-Taxonomic-Diversity-from-Geoduck-Water-with-BLASTp-and-Krona-plots.html). I initiated additional analysis using the MetaGeneMark nucleotide data to run BLASTn on Mox.

- [20190103-mgm-nucleotides.fa](http://gannet.fish.washington.edu/Atumefaciens/20190103_metagenomics_geo_metagenemark/20190103-mgm-nucleotides.fa) (1.6GB)

Here's how the sample names breakdown:

| Sample | Develomental Stage (days post-fertilization) | pH Treatment |
|--------|-------------------------|--------------|
| MG1    | 13                      | 8.2          |
| MG2    | 17                      | 8.2          |
| MG3    | 6                       | 7.1          |
| MG5    | 10                      | 8.2          |
| MG6    | 13                      | 7.1          |
| MG7    | 17                      | 7.1          |

SBATCH script:

- [20190325_blastn_metagenomics_geoduck_metagenemark.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20190325_blastn_metagenomics_geoduck_metagenemark.sh)

<pre><code>
#!/bin/bash
## Job Name
#SBATCH --job-name=blastn_metagenomics
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
#SBATCH --workdir=/gscratch/scrubbed/samwhite/outputs/20190325_blastn_metagenomics_geoduck_metagenemark

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Document programs in PATH (primarily for program version ID)

date >> system_path.log
echo "" >> system_path.log
echo "System PATH for $SLURM_JOB_ID" >> system_path.log
echo "" >> system_path.log
printf "%0.s-" {1..10} >> system_path.log
echo ${PATH} | tr : \\n >> system_path.log


wd="$(pwd)"


# Paths to input/output files
blastn_out="${wd}/blastn.outfmt6"
blastdb_dir="/gscratch/srlab/blastdbs/ncbi-nr-nt-v5"
blast_db="${blastdb_dir}/nt"
fasta="/gscratch/srlab/sam/data/metagenomics/P_generosa/assemblies/20190103-mgm-nucleotides.fa"

# Paths to programs
blast_dir="/gscratch/srlab/programs/ncbi-blast-2.8.1+/bin"
blastn="${blast_dir}/blastn"

export BLASTDB=${blastdb_dir}

# Run blastx on Trinity fasta
${blastn} \
-query ${fasta} \
-db ${blast_db} \
-max_target_seqs 1 \
-outfmt "6 std staxids" \
-evalue 1e-10 \
-num_threads 28 \
> ${blastn_out}

</code></pre>


After the BLASTn, I followed that up by making a Krona plot using the taxonomic info pulled via BLASTn. This was run locally on my computer (swoose).

Krona plot script:

- [krona_tax_plots_blast.sh](http://gannet.fish.washington.edu/Atumefaciens/20190325_blastn_metagenomics_geoduck_metagenemark/krona_tax_plots_blast.sh)


<pre><code>
#!/bin/env bash

# Bash script for creating Krona plot of metagenomics taxonomies from BLAST outputs.

# BLAST output format is expected to be: "6 std staxids"

# Input/output files
blast_out="blastn.outfmt6"
krona_out="krona_megahit_MGM_blastn.html"
krona_tax_list="krona_tax.lst"
krona_stderr="krona_stderr.txt" # Krona standard error capture
krona_stdout="krona_stdout.txt" # Krona standard out capture

# Programs
krona="/home/sam/programs/KronaTools-2.7/bin/ktImportTaxonomy"

## Extract NCBI taxon IDs from BLAST output
### Uses awk associative array to pull out unique entries with highest bitscore and unqique NCBI tax IDs
### BLAST output is sorted by bitscore for multiple matches for a single query
### Pipe unique entries to second awk command
### Set ';' and tab as field delimiters. Prevents issues with taxon ID column having multiple entries for multi-strain matching
### Prints a tab-delimited ouptut file containing the query ID and the taxon ID
awk -F'[;\t]' '!seen[$1,$13]++' ${blast_out} \
| awk '{print $1 "\t" $13}' \
> ${krona_tax_list}

## Create Krona plot, specifying output filename
${krona} \
-o ${krona_out} \
${krona_tax_list} \
1> ${krona_stdout} \
2> ${krona_stderr}

</code></pre>

---

#### RESULTS

Output folder:

- [20190325_blastn_metagenomics_geoduck_metagenemark/](http://gannet.fish.washington.edu/Atumefaciens/20190325_blastn_metagenomics_geoduck_metagenemark/)

BLASTn output (tab-delimited text):

- [/20190325_blastn_metagenomics_geoduck_metagenemark/blastn.outfmt6](http://gannet.fish.washington.edu/Atumefaciens/20190325_blastn_metagenomics_geoduck_metagenemark/blastn.outfmt6)

Krona plot (HTML):

- [20190325_blastn_metagenomics_geoduck_metagenemark/krona_megahit_MGM_blastn.html](http://gannet.fish.washington.edu/Atumefaciens/20190325_blastn_metagenomics_geoduck_metagenemark/krona_megahit_MGM_blastn.html)

The BLASTn took about 6hrs to complete on Mox, using a single node. The Krona plot above is an interactive web page and provides a really nice way to dive into the taxonomic abundances of this data set.

Now, time to delve into exploring differences between the different treatments in this experiment and ssee how their taxonomy compares.
