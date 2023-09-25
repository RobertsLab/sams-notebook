#!/bin/bash
## Job Name
#SBATCH --job-name=20230512-isoform-container-test
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=compute
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=05-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/mmfs1/gscratch/scrubbed/samwhite/outputs/20230512-isoform-container-test

# Load Apptainer module
module load apptainer

export APPTAINERENV_NEWHOME=$(pwd)

# Execute the bedtools-2.31.0.sif container
# Run the bedtools.sh script
apptainer exec \
--home $PWD \
--bind /mmfs1/home/ \
--bind /gscratch/ \
~/apptainers/isoform-expression-hisat2-stringtie.sif \
/gscratch/scrubbed/samwhite/outputs/20230512-isoform-container-test/20230512-isoform-container-test.sh
