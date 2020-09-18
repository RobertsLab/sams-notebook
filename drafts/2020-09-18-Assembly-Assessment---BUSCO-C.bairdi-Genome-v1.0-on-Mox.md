---
layout: post
title: Assembly Assessment - BUSCO C.bairdi Genome v1.0 on Mox
date: '2020-09-18 05:39'
tags:
  - Chionoecetes bairdi
  - Tanner crab
  - mox
  - BUSCO
  - genome
  - assembly
categories:
  - Miscellaneous
---
After using [Flye](https://github.com/fenderglass/Flye) to perform a [_de novo_ assembly of our Q7 filtered NanoPore sequencing data on 20200917](https://robertslab.github.io/sams-notebook/2020/09/17/Genome-Assembly-C.bairdi-cbai_v1.0-Using-All-NanoPore-Data-With-Flye-on-Mox.html), I decided to check the "completeness" of the assembly using [BUSCO](https://busco.ezlab.org/) on Mox.

SBATCH script (GitHub):

- [20200918_cbai_genome_v1.0_busco_.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200918_cbai_genome_v1.0_busco_.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_genome_v1.0_busco
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=3-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200918_cbai_genome_v1.0_busco
###################################################################################





# These variables need to be set by user

## Save working directory
wd=$(pwd)

# Genomes directory
genomes_dir=/gscratch/srlab/sam/data/C_bairdi/genomes

# Genomes array
genomes_array=(
"${genomes_dir}"/cbai_genome_v1.0.fasta \
)



## Input files and settings
busco_db=/gscratch/srlab/sam/data/databases/BUSCO/metazoa_odb9
augustus_species=fly
threads=28

# Programs associative array
declare -A programs_array
programs_array=(
[busco]="/gscratch/srlab/programs/busco-v3/scripts/run_BUSCO.py"
)


## Set program paths
augustus_bin=/gscratch/srlab/programs/Augustus-3.3.2/bin
augustus_orig_config_dir=/gscratch/srlab/programs/Augustus-3.3.2/config
augustus_scripts=/gscratch/srlab/programs/Augustus-3.3.2/scripts
blast_dir=/gscratch/srlab/programs/ncbi-blast-2.8.1+/bin/
hmm_dir=/gscratch/srlab/programs/hmmer-3.2.1/src/

# Export Augustus variable
export PATH="${augustus_bin}:$PATH"
export PATH="${augustus_scripts}:$PATH"

## BUSCO configs
busco_config_default=/gscratch/srlab/programs/busco-v3/config/config.ini.default
busco_config_ini=${wd}/config.ini

# Export BUSCO config file location
export BUSCO_CONFIG_FILE="${busco_config_ini}"

# Copy BUSCO config file
cp ${busco_config_default} "${busco_config_ini}"

# Edit BUSCO config file
## Set paths to various programs
### The use of the % symbol sets the delimiter sed uses for arguments.
### Normally, the delimiter that most examples use is a slash "/".
### But, we need to expand the variables into a full path with slashes, which screws up sed.
### Thus, the use of % symbol instead (it could be any character that is NOT present in the expanded variable; doesn't have to be "%").
sed -i "/^;cpu/ s/1/${threads}/" "${busco_config_ini}"
sed -i "/^tblastn_path/ s%tblastn_path = /usr/bin/%path = ${blast_dir}%" "${busco_config_ini}"
sed -i "/^makeblastdb_path/ s%makeblastdb_path = /usr/bin/%path = ${blast_dir}%" "${busco_config_ini}"
sed -i "/^augustus_path/ s%augustus_path = /home/osboxes/BUSCOVM/augustus/augustus-3.2.2/bin/%path = ${augustus_bin}%" "${busco_config_ini}"
sed -i "/^etraining_path/ s%etraining_path = /home/osboxes/BUSCOVM/augustus/augustus-3.2.2/bin/%path = ${augustus_bin}%" "${busco_config_ini}"
sed -i "/^gff2gbSmallDNA_path/ s%gff2gbSmallDNA_path = /home/osboxes/BUSCOVM/augustus/augustus-3.2.2/scripts/%path = ${augustus_scripts}%" "${busco_config_ini}"
sed -i "/^new_species_path/ s%new_species_path = /home/osboxes/BUSCOVM/augustus/augustus-3.2.2/scripts/%path = ${augustus_scripts}%" "${busco_config_ini}"
sed -i "/^optimize_augustus_path/ s%optimize_augustus_path = /home/osboxes/BUSCOVM/augustus/augustus-3.2.2/scripts/%path = ${augustus_scripts}%" "${busco_config_ini}"
sed -i "/^hmmsearch_path/ s%hmmsearch_path = /home/osboxes/BUSCOVM/hmmer/hmmer-3.1b2-linux-intel-ia32/binaries/%path = ${hmm_dir}%" "${busco_config_ini}"

###################################################################################

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Load Open MPI module for parallel, multi-node processing
module load icc_19-ompi_3.1.2

# SegFault fix?
export THREADS_DAEMON_MODEL=1

for genome in "${!genomes_array[@]}"
do

  # Remove path from genome using parameter substitution
  genome_name="${genomes_array[$genome]##*/}"

  ## Augustus config directories
  augustus_dir=${wd}/${genome_name}_augustus
  augustus_config_dir=${augustus_dir}/config


  export AUGUSTUS_CONFIG_PATH="${augustus_config_dir}"


  # Make Augustus directory if it doesn't exist
  if [ ! -d "${augustus_dir}" ]; then
    mkdir --parents "${augustus_dir}"
  fi

  # Copy Augustus config directory
  cp --preserve -r ${augustus_orig_config_dir} "${augustus_dir}"


  # Run BUSCO/Augustus training
  ${programs_array[busco]} \
  --in ${genomes_array[$genome]} \
  --out ${genome_name} \
  --lineage_path ${busco_db} \
  --mode genome \
  --cpu ${threads} \
  --long \
  --species ${augustus_species} \
  --tarzip \
  --augustus_parameters='--progress=true'

  # Capture FastA checksums for verification
  echo ""
  echo "Generating checksum for ${genome_name}"
  md5sum "${genomes_array[$genome]}" > "${genome_name}".checksum.md5
  echo "Finished generating checksum for ${genome_name}"
  echo ""

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

# Capture program options
for program in "${!programs_array[@]}"
do
	{
  echo "Program options for ${program}: "
	echo ""
	${programs_array[$program]} --help
	echo ""
	echo ""
	echo "----------------------------------------------"
	echo ""
	echo ""
} &>> program_options.log || true
done
```


---

#### RESULTS

Output folder:

- [20200918_cbai_genome_v1.0_busco/](https://gannet.fish.washington.edu/Atumefaciens/20200918_cbai_genome_v1.0_busco/)

  - Summary file (text):

    - [20200918_cbai_genome_v1.0_busco/run_cbai_genome_v1.0.fasta/short_summary_cbai_genome_v1.0.fasta.txt](https://gannet.fish.washington.edu/Atumefaciens/20200918_cbai_genome_v1.0_busco/run_cbai_genome_v1.0.fasta/short_summary_cbai_genome_v1.0.fasta.txt)

    ```
    # BUSCO version is: 3.0.2
# The lineage dataset is: metazoa_odb9 (Creation date: 2016-02-13, number of species: 65, number of BUSCOs: 978)
# To reproduce this run: python /gscratch/srlab/programs/busco-v3/scripts/run_BUSCO.py -i /gscratch/srlab/sam/data/C_bairdi/genomes/cbai_genome_v1.0.fasta -o cbai_genome_v1.0.fasta -l /gscratch/srlab/sam/data/databases/BUSCO/metazoa_odb9/ -m genome -c 28 --long -z -sp fly --augustus_parameters '--progress=true'
#
# Summarized benchmarking in BUSCO notation for file /gscratch/srlab/sam/data/C_bairdi/genomes/cbai_genome_v1.0.fasta
# BUSCO was run in mode: genome

	C:0.4%[S:0.3%,D:0.1%],F:0.3%,M:99.3%,n:978

	4	Complete BUSCOs (C)
	3	Complete and single-copy BUSCOs (S)
	1	Complete and duplicated BUSCOs (D)
	3	Fragmented BUSCOs (F)
	971	Missing BUSCOs (M)
	978	Total BUSCO groups searched
    ```

The results are a tad disappointing (would've been awesome if we had actually gotten a nearly complete genome), but not terribly surprising. Crab/crustacean genomes are known to be rather large, the NanoPore runs didn't generate a ton of data, and the assembly didn't produce any appreciably large scaffolds/contigs.

Despite this, I'm still interested in seeing what a graph-based assembly looks like using a visualization package like [Bandage](https://github.com/rrwick/Bandage) to gain a better understanding of what to expect.

It would also be great to perform some additional NanoPore sequencing. The flowcells aren't terribly expensive, the library prep/sequencing is fast, and the downstream analysis is pretty quick and painless (assuming what I've done so far is the appropriate way to process this data).
