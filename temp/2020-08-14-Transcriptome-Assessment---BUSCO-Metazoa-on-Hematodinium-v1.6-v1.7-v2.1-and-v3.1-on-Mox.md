---
layout: post
title: Transcriptome Assessment - BUSCO Metazoa on Hematodinium v1.6 v1.7 v2.1 and v3.1 on Mox
date: '2020-08-14 20:06'
tags:
  - BUSCO
  - metazoa
  - mox
  - transcriptome
  - hematodinium
categories:
  - Miscellaneous
---
Needed to assess the _Hematodinium sp._ transcriptomes that I've assembled to determine their "completeness" using [BUSCO](https://busco.ezlab.org/).

- [hemat_transcriptome_v1.6.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.6.fasta_trinity_out_dir/hemat_transcriptome_v1.6.fasta) (38MB; from [20200814](https://robertslab.github.io/sams-notebook/2020/08/14/Transcriptome-Assembly-Hematodinium-Transcriptomes-v1.6-and-v1.7-with-Trinity-on-Mox.html))

- [hemat_transcriptome_v1.7.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_trinity_v1.6_v1.7/hemat_transcriptome_v1.7.fasta_trinity_out_dir/hemat_transcriptome_v1.7.fasta) (22MB; from [20200814](https://robertslab.github.io/sams-notebook/2020/08/14/Transcriptome-Assembly-Hematodinium-Transcriptomes-v1.6-and-v1.7-with-Trinity-on-Mox.html))

- [hemat_transcriptome_v2.1.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200605_cbai_v2.0_v3.0_megan_seq_extractions/hemat_transcriptome_v2.1.fasta) (65MB; from [20200605](https://robertslab.github.io/sams-notebook/2020/06/05/Sequence-Extractions-C.bairdi-Transcriptomes-v2.0-and-v3.0-Excluding-Alveolata-with-MEGAN6-on-Swoose.html))

- [hemat_transcriptome_v3.1.fasta](https://gannet.fish.washington.edu/Atumefaciens/20200605_cbai_v2.0_v3.0_megan_seq_extractions/hemat_transcriptome_v3.1.fasta) (65MB; from [20200605](https://robertslab.github.io/sams-notebook/2020/06/05/Sequence-Extractions-C.bairdi-Transcriptomes-v2.0-and-v3.0-Excluding-Alveolata-with-MEGAN6-on-Swoose.html))

All of the above transcriptomes were assembled with different combinations of the crab RNAseq data we generated. Here's a link to an overview of the various assemblies:

- [hemat_transcriptome_comp](https://docs.google.com/spreadsheets/d/1A81cFdFw5Mlks5DWMmq0-8eVqyTXqmoCsHNWs95N_p4/edit?usp=sharing) (Google Sheet)

SBATCH script (GitHub):

- [20200814_hemat_busco_transcriptomes_v1.6_v1.7_v2.1_v.3.1.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20200814_hemat_busco_transcriptomes_v1.6_v1.7_v2.1_v.3.1.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=cbai_busco_megan_transcriptomes
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20200814_hemat_busco_transcriptomes_v1.6_v1.7_v2.1_v.3.1

###################################################################################
# These variables need to be set by user

## Save working directory
wd=$(pwd)

# Establish variables for more readable code
transcriptomes_dir=/gscratch/srlab/sam/data/Hematodinium/transcriptomes

# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
transcriptomes_array=(
"${transcriptomes_dir}"/hemat_transcriptome_v1.6.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v1.7.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v2.1.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v3.1.fasta
)



## Input files and settings
busco_db=/gscratch/srlab/sam/data/databases/BUSCO/metazoa_odb9
augustus_species=fly
threads=28

# Programs array
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

for transcriptome in "${!transcriptomes_array[@]}"
do

  # Remove path from transcriptome using parameter substitution
  transcriptome_name="${transcriptomes_array[$transcriptome]##*/}"

  ## Augustus config directories
  augustus_dir=${wd}/${transcriptome_name}_augustus
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
  --in ${transcriptomes_array[$transcriptome]} \
  --out ${transcriptome_name} \
  --lineage_path ${busco_db} \
  --mode transcriptome \
  --cpu ${threads} \
  --long \
  --species ${augustus_species} \
  --tarzip \
  --augustus_parameters='--progress=true'

  # Capture FastA checksums for verification
  cho ""
  echo "Generating checksum for ${transcriptome_name}"
  md5sum "${transcriptomes_array[$transcriptome]}" > "${transcriptome_name}".checksum.md5
  echo "Finished generating checksum for ${transcriptome_name}"
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

Just under 7mins to assess the four transcriptomes:

![BUSCO runtime](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20200814_hemat_diamond_blastx_v1.6_v1.7_v2.1_v3.1_runtimes.png?raw=true)

Output folder:

- [20200814_hemat_busco_transcriptomes_v1.6_v1.7_v2.1_v.3.1/](https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_busco_transcriptomes_v1.6_v1.7_v2.1_v.3.1/)

All data below has been added to a transcriptome comparison spreadsheet:

- [hemat_transcriptome_comp](https://docs.google.com/spreadsheets/d/1A81cFdFw5Mlks5DWMmq0-8eVqyTXqmoCsHNWs95N_p4/edit?usp=sharing) (Google Sheet)


##### `hemat_transcriptome_v1.6.fasta` BUSCO Short Summary

- [20200814_hemat_busco_transcriptomes_v1.6_v1.7_v2.1_v.3.1/run_hemat_transcriptome_v1.6.fasta/short_summary_hemat_transcriptome_v1.6.fasta.txt](https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_busco_transcriptomes_v1.6_v1.7_v2.1_v.3.1/run_hemat_transcriptome_v1.6.fasta/short_summary_hemat_transcriptome_v1.6.fasta.txt)

```
# BUSCO version is: 3.0.2
# The lineage dataset is: metazoa_odb9 (Creation date: 2016-02-13, number of species: 65, number of BUSCOs: 978)
# To reproduce this run: python /gscratch/srlab/programs/busco-v3/scripts/run_BUSCO.py -i /gscratch/srlab/sam/data/Hematodinium/transcriptomes/hemat_transcriptome_v1.6.fasta -o hemat_transcriptome_v1.6.fasta -l /gscratch/srlab/sam/data/databases/BUSCO/metazoa_odb9/ -m transcriptome -c 28 --long -z
#
# Summarized benchmarking in BUSCO notation for file /gscratch/srlab/sam/data/Hematodinium/transcriptomes/hemat_transcriptome_v1.6.fasta
# BUSCO was run in mode: transcriptome

	C:91.8%[S:64.9%,D:26.9%],F:6.0%,M:2.2%,n:978

	898	Complete BUSCOs (C)
	635	Complete and single-copy BUSCOs (S)
	263	Complete and duplicated BUSCOs (D)
	59	Fragmented BUSCOs (F)
	21	Missing BUSCOs (M)
	978	Total BUSCO groups searched
```


##### `hemat_transcriptome_v1.7.fasta` BUSCO Short Summary

- [https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_busco_transcriptomes_v1.6_v1.7_v2.1_v.3.1/run_hemat_transcriptome_v1.7.fasta/short_summary_hemat_transcriptome_v1.7.fasta.txt](https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_busco_transcriptomes_v1.6_v1.7_v2.1_v.3.1/run_hemat_transcriptome_v1.7.fasta/short_summary_hemat_transcriptome_v1.7.fasta.txt)

```
# BUSCO version is: 3.0.2
# The lineage dataset is: metazoa_odb9 (Creation date: 2016-02-13, number of species: 65, number of BUSCOs: 978)
# To reproduce this run: python /gscratch/srlab/programs/busco-v3/scripts/run_BUSCO.py -i /gscratch/srlab/sam/data/Hematodinium/transcriptomes/hemat_transcriptome_v1.7.fasta -o hemat_transcriptome_v1.7.fasta -l /gscratch/srlab/sam/data/databases/BUSCO/metazoa_odb9/ -m transcriptome -c 28 --long -z
#
# Summarized benchmarking in BUSCO notation for file /gscratch/srlab/sam/data/Hematodinium/transcriptomes/hemat_transcriptome_v1.7.fasta
# BUSCO was run in mode: transcriptome

	C:86.5%[S:65.5%,D:21.0%],F:8.3%,M:5.2%,n:978

	846	Complete BUSCOs (C)
	641	Complete and single-copy BUSCOs (S)
	205	Complete and duplicated BUSCOs (D)
	81	Fragmented BUSCOs (F)
	51	Missing BUSCOs (M)
	978	Total BUSCO groups searched
```


##### `hemat_transcriptome_v2.1.fasta` BUSCO Short Summary

- [https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_busco_transcriptomes_v1.6_v1.7_v2.1_v.3.1/run_hemat_transcriptome_v2.1.fasta/short_summary_hemat_transcriptome_v2.1.fasta.txt](https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_busco_transcriptomes_v1.6_v1.7_v2.1_v.3.1/run_hemat_transcriptome_v2.1.fasta/short_summary_hemat_transcriptome_v2.1.fasta.txt)

```
# BUSCO version is: 3.0.2
# The lineage dataset is: metazoa_odb9 (Creation date: 2016-02-13, number of species: 65, number of BUSCOs: 978)
# To reproduce this run: python /gscratch/srlab/programs/busco-v3/scripts/run_BUSCO.py -i /gscratch/srlab/sam/data/Hematodinium/transcriptomes/hemat_transcriptome_v2.1.fasta -o hemat_transcriptome_v2.1.fasta -l /gscratch/srlab/sam/data/databases/BUSCO/metazoa_odb9/ -m transcriptome -c 28 --long -z
#
# Summarized benchmarking in BUSCO notation for file /gscratch/srlab/sam/data/Hematodinium/transcriptomes/hemat_transcriptome_v2.1.fasta
# BUSCO was run in mode: transcriptome

	C:33.7%[S:6.2%,D:27.5%],F:2.9%,M:63.4%,n:978

	330	Complete BUSCOs (C)
	61	Complete and single-copy BUSCOs (S)
	269	Complete and duplicated BUSCOs (D)
	28	Fragmented BUSCOs (F)
	620	Missing BUSCOs (M)
	978	Total BUSCO groups searched
```

##### `hemat_transcriptome_v3.1.fasta` BUSCO Short Summary

- [https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_busco_transcriptomes_v1.6_v1.7_v2.1_v.3.1/run_hemat_transcriptome_v3.1.fasta/short_summary_hemat_transcriptome_v3.1.fasta.txt](https://gannet.fish.washington.edu/Atumefaciens/20200814_hemat_busco_transcriptomes_v1.6_v1.7_v2.1_v.3.1/run_hemat_transcriptome_v3.1.fasta/short_summary_hemat_transcriptome_v3.1.fasta.txt)

```
# BUSCO version is: 3.0.2
# The lineage dataset is: metazoa_odb9 (Creation date: 2016-02-13, number of species: 65, number of BUSCOs: 978)
# To reproduce this run: python /gscratch/srlab/programs/busco-v3/scripts/run_BUSCO.py -i /gscratch/srlab/sam/data/Hematodinium/transcriptomes/hemat_transcriptome_v3.1.fasta -o hemat_transcriptome_v3.1.fasta -l /gscratch/srlab/sam/data/databases/BUSCO/metazoa_odb9/ -m transcriptome -c 28 --long -z
#
# Summarized benchmarking in BUSCO notation for file /gscratch/srlab/sam/data/Hematodinium/transcriptomes/hemat_transcriptome_v3.1.fasta
# BUSCO was run in mode: transcriptome

	C:34.3%[S:6.3%,D:28.0%],F:3.2%,M:62.5%,n:978

	336	Complete BUSCOs (C)
	62	Complete and single-copy BUSCOs (S)
	274	Complete and duplicated BUSCOs (D)
	31	Fragmented BUSCOs (F)
	611	Missing BUSCOs (M)
	978	Total BUSCO groups searched
```
