---
layout: post
title: Genome Assembly - C.bairdi - cbai_v1.0 - Using All NanoPore Data With Flye on Mox
date: '2020-09-17 11:08'
tags:
  - genome assembly
  - Tanner crab
  - Hematodinium
  - Chionoecetes bairdi
  - mox
  - flye
categories:
  - Genome Assembly
---
After [quality filtering the _C.bairdi_ NanoPore data earlier today](https://robertslab.github.io/sams-notebook/2020/09/17/Data-Wrangling-C.bairdi-NanoPore-Quality-Filtering-Using-NanoFilt-on-Mox.html), I performed a _de novo_ assembly using [Flye](https://github.com/fenderglass/Flye) on Mox.

SBATCH script (GitHub):

- [20200917_cbai_flye_nanopore_genome_assembly.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200917_cbai_flye_nanopore_genome_assembly.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_flye_nanopore_genome_assembly
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=25-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200915_cbai_flye_nanopore_genome_assembly

# Script to run Flye long read assembler on all quality filtered (Q7) C.bairdi NanoPore reads
# from 20200917

###################################################################################
# These variables need to be set by user

# Load Anaconda
# Uknown why this is needed, but Anaconda will not run if this line is not included.
. "/gscratch/srlab/programs/anaconda3/etc/profile.d/conda.sh"


# Activate the flye Anaconda environment
conda activate flye-2.8.1_env

# Set number of CPUs to use
threads=28

# Paths to programs
flye=flye

# Input FastQ
fastq=/gscratch/srlab/sam/data/C_bairdi/DNAseq/20200917_cbai_nanopore_all_quality-7.fastq

###################################################################################


# Exit script if any command fails
set -e


# Capture this directory
wd=$(pwd)

# Inititalize arrays
programs_array=()


# Programs array
programs_array=("${flye}")

# Run flye
${flye} \
--nano-raw ${fastq} \
--out-dir ${wd} \
--threads ${threads}

# Generate checksum file
md5sum "${fastq}" > fastq_checksums.md5

# Capture program options
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${programs_array[program]}: "
	echo ""
	${programs_array[program]} -h
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true
done

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

Runtime was very fast; just over 1hr!

![Flye runtime for C.bairdi Q7 NanoPore assembly](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200917_cbai_flye_nanopore_genome_assembly_runtime.png?raw=true)

Output folder:

- [20200917_cbai_flye_nanopore_genome_assembly/](https://gannet.fish.washington.edu/Atumefaciens/20200917_cbai_flye_nanopore_genome_assembly/)

Genome Assembly (FastA; 19MB)

- [20200917_cbai_flye_nanopore_genome_assembly/cbai_genome_v1.0.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200917_cbai_flye_nanopore_genome_assembly/cbai_genome_v1.0.fasta)

  - MD5 checksum (text):

    - `2f3b651bb0b875b0287e71e315cad59a`

NOTE: The output files were named `assembly_*`. At the time I ran this, I didn't realize that was the case, so I had to rename them to reflect the `cba_genome_v1.0` notation after the fact; thus this step is not present in the SBATCH script.

Well, this is pretty exciting! Here's a quick assembly summary (found at the end of the [SLURM output file](https://gannet.fish.washington.edu/Atumefaciens/20200917_cbai_flye_nanopore_genome_assembly/slurm-294008.out)):

```
INFO: Assembly statistics:

	Total length:	19216531
	Fragments:	3294
	Fragments N50:	14130
	Largest frg:	141601
	Scaffolds:	6
	Mean coverage:	17
```
Admittedly, there are definitely some issues with the assembly. For example, here's a portion of the FastA index file:

```
contig_3421	1	11083798	1	2
contig_2582	3	4548025	3	4
contig_3109	46	8747210	46	47
contig_2139	49	3182267	49	50
contig_4287	58	16100814	58	59
contig_3575	66	12248950	60	61
contig_793	69	18935471	60	61
contig_3976	84	14959281	60	61
contig_2281	104	3633003	60	61
contig_4015	104	15091851	60	61
```

Column #2 is the sequence length. The first two "contigs" have lengths of < 5bp! Obviously, this is useless. I know we can just filter out small contigs for subsequent analyses, but it's disconcerting that [Flye](https://github.com/fenderglass/Flye) actually spit these out as "contigs" instead of discarding them. I've [submitted an issue](https://github.com/fenderglass/Flye/issues/304) to see if I can obtain some understanding about why this occurred.

So, where do we go from here? A couple of things:

- Visualize the assembly graphs with something like [Bandage](https://github.com/rrwick/Bandage). I'm hoping this will lead to a better understanding of how these graph assemblies (as opposed to alignment-based assemblies) work.

- Run BUSCO to assess genome "completeness".

- Attempt to separate out _Hematodinium_ sequences.

- Annotate the assembly with GenSAS and/or BLAST or something.
