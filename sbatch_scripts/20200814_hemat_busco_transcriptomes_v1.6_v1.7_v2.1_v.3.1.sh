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

# Array of the various comparisons to evaluate
# Each condition in each comparison should be separated by a "-"
transcriptomes_array=(
"${transcriptomes_dir}"/hemat_transcriptome_v1.6.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v1.7.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v2.1.fasta \
"${transcriptomes_dir}"/hemat_transcriptome_v3.1.fasta
)

# Establish variables for more readable code
transcriptomes_dir=/gscratch/srlab/sam/data/Hematodinium/transcriptomes

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
