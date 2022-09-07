#!/bin/bash
## Job Name
#SBATCH --job-name=20180829_trinity
## Allocation Definition 
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=30-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --workdir=/gscratch/scrubbed/samwhite/20180827_trinity_geoduck_RNAseq

# Load Python Mox module for Python module availability

module load intel-python3_2017

# Document programs in PATH (primarily for program version ID)

date >> system_path.log
echo "" >> system_path.log
echo "System PATH for $SLURM_JOB_ID" >> system_path.log
echo "" >> system_path.log
printf "%0.s-" {1..10} >> system_path.log
echo ${PATH} | tr : \\n >> system_path.log


# Run Trinity
/gscratch/srlab/programs/trinityrnaseq-Trinity-v2.8.3/Trinity \
--trimmomatic \
--seqType fq \
--max_memory 500G \
--CPU 28 \
--left \
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-1_S3_L001_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-2_S11_L002_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-3_S19_L003_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-4_S27_L004_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-5_S35_L005_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-6_S43_L006_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-7_S51_L007_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-8_S59_L008_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-1_S1_L001_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-2_S9_L002_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-3_S17_L003_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-4_S25_L004_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-5_S33_L005_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-6_S41_L006_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-7_S49_L007_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-8_S57_L008_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-1_S2_L001_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-2_S10_L002_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-3_S18_L003_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-4_S26_L004_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-5_S34_L005_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-6_S42_L006_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-7_S50_L007_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-8_S58_L008_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-1_S6_L001_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-2_S14_L002_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-3_S22_L003_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-4_S30_L004_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-5_S38_L005_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-6_S46_L006_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-7_S54_L007_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-8_S62_L008_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-1_S7_L001_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-2_S15_L002_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-3_S23_L003_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-4_S31_L004_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-5_S39_L005_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-6_S47_L006_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-7_S55_L007_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-8_S63_L008_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-1_S4_L001_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-2_S12_L002_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-3_S20_L003_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-4_S28_L004_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-5_S36_L005_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-6_S44_L006_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-7_S52_L007_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-8_S60_L008_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-1_S5_L001_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-2_S13_L002_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-3_S21_L003_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-4_S29_L004_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-5_S37_L005_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-6_S45_L006_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-7_S53_L007_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-8_S61_L008_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-1_S8_L001_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-2_S16_L002_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-3_S24_L003_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-4_S32_L004_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-5_S40_L005_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-6_S48_L006_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-7_S56_L007_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-8_S64_L008_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geo_Pool_F_GGCTAC_L006_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geo_Pool_M_CTTGTA_L006_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L001_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L002_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L001_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L002_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L001_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L002_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L001_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L002_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L001_R1_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L002_R1_001.fastq.gz \
--right \
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-1_S3_L001_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-2_S11_L002_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-3_S19_L003_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-4_S27_L004_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-5_S35_L005_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-6_S43_L006_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-7_S51_L007_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-ctenidia-RNA-8_S59_L008_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-1_S1_L001_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-2_S9_L002_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-3_S17_L003_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-4_S25_L004_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-5_S33_L005_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-6_S41_L006_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-7_S49_L007_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-gonad-RNA-8_S57_L008_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-1_S2_L001_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-2_S10_L002_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-3_S18_L003_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-4_S26_L004_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-5_S34_L005_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-6_S42_L006_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-7_S50_L007_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-heart-RNA-8_S58_L008_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-1_S6_L001_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-2_S14_L002_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-3_S22_L003_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-4_S30_L004_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-5_S38_L005_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-6_S46_L006_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-7_S54_L007_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-123-8_S62_L008_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-1_S7_L001_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-2_S15_L002_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-3_S23_L003_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-4_S31_L004_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-5_S39_L005_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-6_S47_L006_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-7_S55_L007_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-ambient-exposure-RNA-EPI-124-8_S63_L008_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-1_S4_L001_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-2_S12_L002_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-3_S20_L003_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-4_S28_L004_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-5_S36_L005_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-6_S44_L006_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-7_S52_L007_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-115-8_S60_L008_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-1_S5_L001_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-2_S13_L002_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-3_S21_L003_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-4_S29_L004_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-5_S37_L005_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-6_S45_L006_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-7_S53_L007_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-juvenile-OA-exposure-RNA-EPI-116-8_S61_L008_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-1_S8_L001_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-2_S16_L002_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-3_S24_L003_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-4_S32_L004_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-5_S40_L005_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-6_S48_L006_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-7_S56_L007_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geoduck-larvae-day5-RNA-EPI-99-8_S64_L008_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geo_Pool_F_GGCTAC_L006_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Geo_Pool_M_CTTGTA_L006_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L001_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA1-A1-NR006_S1_L002_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L001_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA3-C1-NR012_S2_L002_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L001_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA5-E1-NR005_S3_L002_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L001_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA7-G1-NR019_S4_L002_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L001_R2_001.fastq.gz,\
/gscratch/scrubbed/samwhite/data/P_generosa/RNAseq/Trueseq-stranded-mRNA-libraries-GeoRNA8-H1-NR021_S5_L002_R2_001.fastq.gz
