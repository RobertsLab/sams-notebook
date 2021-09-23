---
layout: post
title: Transcriptome Assessment - BUSCO Metazoa on C.bairdi Transcriptome v4.0 on Mox
date: '2021-03-17 20:27'
tags:
  - BUSCO
  - Chionoecetes bairdi
  - Tanner crab
  - transcriptome
  - mox
categories:
  - Tanner Crab RNAseq
---
[I previously created a _C.bairdi_ _de novo_ transcriptome assembly v4.0 with Trinity from all our _C.bairdi_ RNAseq reads which had BLASTx matches to the _C.opilio_ genome](https://robertslab.github.io/sams-notebook/2021/03/17/Transcriptome-Assembly-C.bairdi-Transcriptome-v4.0-Using-Trinity-on-Mox.html) and decided to assess its "completeness" using BUSCO and the `metazoa_odb9` database.

BUSCO was run with the `--mode transcriptome` option on Mox.

SBATCH script (GitHub):

- [20210317_cbai_busco_transcriptome_v4.0.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210317_cbai_busco_transcriptome_v4.0.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210317_cbai_busco_transcriptome_v4.0
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210317_cbai_busco_transcriptome_v4.0

### C.bairdi transcriptome assembly completeness assessment using BUSCO.
### This is checking cbai_transcriptome_v4.0 fasta

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Load Open MPI module for parallel, multi-node processing
module load icc_19-ompi_3.1.2

# SegFault fix?
export THREADS_DAEMON_MODEL=1


## Input files and settings
busco_db=/gscratch/srlab/sam/data/databases/BUSCO/metazoa_odb9
transcriptome_fasta=/gscratch/srlab/sam/data/C_bairdi/transcriptomes/cbai_transcriptome_v4.0.fasta
augustus_species=fly
threads=40

## Save working directory
wd=$(pwd)

# Extract FastA filename
fasta_name=${transcriptome_fasta##*/}

## Set program paths
augustus_bin=/gscratch/srlab/programs/Augustus-3.3.2/bin
augustus_scripts=/gscratch/srlab/programs/Augustus-3.3.2/scripts
blast_dir=/gscratch/srlab/programs/ncbi-blast-2.8.1+/bin/
busco=/gscratch/srlab/programs/busco-v3/scripts/run_BUSCO.py
hmm_dir=/gscratch/srlab/programs/hmmer-3.2.1/src/

## Augustus configs
augustus_dir=${wd}/augustus
augustus_config_dir=${augustus_dir}/config
augustus_orig_config_dir=/gscratch/srlab/programs/Augustus-3.3.2/config

## BUSCO configs
busco_config_default=/gscratch/srlab/programs/busco-v3/config/config.ini.default
busco_config_ini=${wd}/config.ini

# Export BUSCO config file location
export BUSCO_CONFIG_FILE="${busco_config_ini}"

# Export Augustus variable
export PATH="${augustus_bin}:$PATH"
export PATH="${augustus_scripts}:$PATH"
export AUGUSTUS_CONFIG_PATH="${augustus_config_dir}"


# Copy BUSCO config file
cp ${busco_config_default} "${busco_config_ini}"

# Make Augustus directory if it doesn't exist
if [ ! -d "${augustus_dir}" ]; then
  mkdir --parents "${augustus_dir}"
fi

# Copy Augustus config directory
cp --preserve -r ${augustus_orig_config_dir} "${augustus_dir}"

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


# Run BUSCO/Augustus training
${busco} \
--in ${transcriptome_fasta} \
--out ${fasta_name} \
--lineage_path ${busco_db} \
--mode transcriptome \
--cpu ${threads} \
--long \
--species ${augustus_species} \
--tarzip \
--augustus_parameters='--progress=true'

# Create checksum for potential verification
md5sum "${transcriptome_fasta}" >> "${fasta_name}".checksum.md5
```

---

#### RESULTS

As usual, runtime was very short, <2mins:

![BUSCO runtime on C.bairdi transcriptome v4.0 on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210317_cbai_busco_transcriptome_v4.0_runtime.png?raw=true)

Output folder:

- [20210317_cbai_busco_transcriptome_v4.0/](https://gannet.fish.washington.edu/Atumefaciens/20210317_cbai_busco_transcriptome_v4.0/)

  - FastA MD5 checksum (TXT):

    - [cbai_transcriptome_v4.0.fasta.checksum.md5](https://gannet.fish.washington.edu/Atumefaciens/20210317_cbai_busco_transcriptome_v4.0/cbai_transcriptome_v4.0.fasta.checksum.md5)

  - Short summary (text):

    - [20210317_cbai_busco_transcriptome_v4.0/run_cbai_transcriptome_v4.0.fasta/short_summary_cbai_transcriptome_v4.0.fasta.txt](https://gannet.fish.washington.edu/Atumefaciens/20210317_cbai_busco_transcriptome_v4.0/run_cbai_transcriptome_v4.0.fasta/short_summary_cbai_transcriptome_v4.0.fasta.txt)


    ```
    # BUSCO version is: 3.0.2
    # The lineage dataset is: metazoa_odb9 (Creation date: 2016-02-13, number of species: 65, number of BUSCOs: 978)
    # To reproduce this run: python /gscratch/srlab/programs/busco-v3/scripts/run_BUSCO.py -i /gscratch/srlab/sam/data/C_bairdi/transcriptomes/cbai_transcriptome_v4.0.fasta -o cbai_transcriptome_v4.0.fasta -l /gscratch/srlab/sam/data/databases/BUSCO/metazoa_odb9/ -m transcriptome -c 40 --long -z
    #
    # Summarized benchmarking in BUSCO notation for file /gscratch/srlab/sam/data/C_bairdi/transcriptomes/cbai_transcriptome_v4.0.fasta
    # BUSCO was run in mode: transcriptome

    	C:73.8%[S:45.8%,D:28.0%],F:7.9%,M:18.3%,n:978

    	722	Complete BUSCOs (C)
    	448	Complete and single-copy BUSCOs (S)
    	274	Complete and duplicated BUSCOs (D)
    	77	Fragmented BUSCOs (F)
    	179	Missing BUSCOs (M)
    	978	Total BUSCO groups searched
      ```
