#!/bin/bash
#SBATCH --job-name=bismark_job_array
#SBATCH --account=coenv
#SBATCH --partition=cpu-g2
#SBATCH --output=bismark_job_%A_%a.out
#SBATCH --error=bismark_job_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=100G
#SBATCH --time=72:00:00
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/gitrepos/ceasmallr/output/02.01-bismark-bowtie2-alignment-SLURM-array/

# Execute Roberts Lab bioinformatics container
# Binds home directory
# Binds /gscratch directory
# Directory bindings allow outputs to be written to the hard drive.
apptainer exec \
--home "$PWD" \
--bind /mmfs1/home/ \
--bind /gscratch \
/gscratch/srlab/sr320/srlab-bioinformatics-container-586bf21.sif \
/gscratch/scrubbed/samwhite/gitrepos/ceasmallr/code/02.01-bismark-bowtie2-alignment-SLURM-array.sh
