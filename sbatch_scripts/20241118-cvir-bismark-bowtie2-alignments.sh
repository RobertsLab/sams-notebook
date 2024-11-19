#!/bin/bash
#SBATCH --job-name=bismark_job_array
#SBATCH --account=srlab
#SBATCH --partition=ckpt
#SBATCH --output=bismark_job_%A_%a.out
#SBATCH --error=bismark_job_%A_%a.err
#SBATCH --array=1-32
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=175G
#SBATCH --time=24:00:00
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/gitrepos/ceasmallr/output/02.00-bismark-bowtie2-alignment/

# Execute Roberts Lab bioinformatics container
# Binds home directory
# Binds /gscratch directory
# Directory bindings allow outputs to be written to the hard drive.
apptainer exec \
--home "$PWD" \
--bind /mmfs1/home/ \
--bind /gscratch \
/gscratch/srlab/sr320/srlab-bioinformatics-container-586bf21.sif \
/mmfs1/home/samwhite/gitrepos/RobertsLab/sams-notebook/sbatch_scripts/20241119-cvir-bismark-bowtie2-alignments.sh
