#!/bin/bash
## Job Name
#SBATCH --job-name=20221026-rhodes-marine_mammals-16s-silva-138-99-seqs-515-806
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=7-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20221026-rhodes-marine_mammals-16s-silva-138-99-seqs-515-806



###################################################################################
# These variables need to be set by user
threads=28
base=$(pwd)
ref=/gscratch/srlab/sam/data/databases/silva

BASE=$base
RAW=$ref/MiSeq_files_for_Gannet
TRIM_OUT=$base/trimmed
PANDA_OUT=$base/joined
FILTER_OUT=$base/filtered
CONVERT_OUT=$base/converted
CHIMERA_OUT=$base/chimera_checked
CLUSTER_OUT=$base/clustered
CLASSIFY_OUT=$base/classified
metadata=$base/metadata


# Specific to clustering
CLUSTER_PER=99
MYREF=$ref/silva-138-99-seqs-515-806.qza
MYTAXONOMY=$ref/silva-138-99-tax-515-806.qza

FINAL_OTU=$base/final_otu
METADATADIR=/gscratch/srlab/sam/data/databases/silva
METADATA=${METADATADIR}/Marine-Mammal-MiSeq-metadata.txt

###################################################################################


# Exit script if a command fails
set -e

# Load Anaconda
# Uknown why this is needed, but Anaconda will not run if this line is not included.
. "/gscratch/srlab/programs/anaconda3/etc/profile.d/conda.sh"

# Activate NF-core conda environment
conda activate qiime2-2022.8

# Make all output directories
mkdir \
--parents \
"${BASE}" \
"${TRIM_OUT}" \
"${PANDA_OUT}" \
"${FILTER_OUT}" \
"${CLASSIFY_OUT}" \
"${CONVERT_OUT}" \
"${CLUSTER_OUT}" \
"${CHIMERA_OUT}" \
"${metadata}" \
"${FINAL_OTU}"



## Get list of samples
if [[ -e ${BASE}/sample_ids.txt ]]; then
    rm "${BASE}"/sample_ids.txt
fi

for file in ${RAW}/*R1*
do
    NAME=$(echo "${file}" | awk -F "/" '{print $NF}' | awk -F ".R1" '{print $1}')
    echo "${NAME}"
    echo "${NAME}" >> "${BASE}"/sample_ids.txt
done

SAMPLE_COUNT=$(wc "${BASE}"/sample_ids.txt | awk '{print $1}')
echo -e "\nSample Count = ${SAMPLE_COUNT}"
##

## Trimmomatic
for NAME in $(cat "${BASE}"/sample_ids.txt)
do
    trimmomatic \
        PE -phred33 \
        -threads ${threads} \
        -trimlog "${TRIM_OUT}"/"${NAME}".trimmomatic.log \
        ${RAW}/"${NAME}"_R1_001.fastq.gz \
        ${RAW}/"${NAME}"_R2_001.fastq.gz \
        "${TRIM_OUT}"/"${NAME}".trimmed.paired.R1.fq \
        "${TRIM_OUT}"/"${NAME}".trimmed.unpaired.R1.fq \
        "${TRIM_OUT}"/"${NAME}".trimmed.paired.R2.fq \
        "${TRIM_OUT}"/"${NAME}".trimmed.unpaired.R2.fq \
        ILLUMINACLIP:/home/sam/programs/Trimmomatic-0.39/adapters/NexteraPE-PE.fa:2:30:10 \
        LEADING:3 \
        TRAILING:3 \
        SLIDINGWINDOW:8:10 \
        MINLEN:100 \
        > "${TRIM_OUT}"/"${NAME}".trimmomatic.stats.txt 2>&1
done

##


## Generate list of sample ids that passed trimming
if [ -f "${BASE}"/sample_ids.pass_trimmed.txt ]; then
    rm "${BASE}"/sample_ids.pass_trimmed.txt
fi

for file in $(ls -1 "${TRIM_OUT}"/*trimmed.paired.R1.fq)
do
    NAME=$(echo "${file}" | awk -F "/" '{print $NF}' | awk -F ".trimmed" '{print $1}')
    echo "${NAME}"
    echo "${NAME}" >> "${BASE}"/sample_ids.pass_trimmed.txt
done

SAMPLE_COUNT=$(wc "${BASE}"/sample_ids.pass_trimmed.txt | awk '{print $1}')
echo -e "\nSample Count = ${SAMPLE_COUNT}"
##

## Joining - pandaseq

for NAME in $(cat "${BASE}"/sample_ids.pass_trimmed.txt)
do
    pandaseq \
        -T 8 \
        -g "${PANDA_OUT}"/"${NAME}".pandaseq.log \
        -f "${TRIM_OUT}"/"${NAME}".trimmed.paired.R1.fq \
        -r "${TRIM_OUT}"/"${NAME}".trimmed.paired.R2.fq \
        -w "${PANDA_OUT}"/"${NAME}".joined.fa

    "${ref}"/seq_dist.pl \
        "${PANDA_OUT}"/"${NAME}".joined.fa \
        > "${PANDA_OUT}"/"${NAME}".joined.lengths.txt
done

# Generate list of samples that passed the joining step
if [ -f "${BASE}"/sample_ids.pass_joined.txt ]; then
    rm "${BASE}"/sample_ids.pass_joined.txt
fi

for file in $(ls -1 "${PANDA_OUT}"/*joined.fa)
do
    NAME=$(echo "${file}" | awk -F "/" '{print $NF}' | awk -F ".joined" '{print $1}')
    echo "${NAME}"
    echo "${NAME}" >> "${BASE}"/sample_ids.pass_joined.txt
done

SAMPLE_COUNT=$(wc "${BASE}"/sample_ids.pass_joined.txt | awk '{print $1}')
echo -e "\nSample Count = ${SAMPLE_COUNT}"
##

## Stats for each sample after joining
# Run the R script to generate the stats
"${ref}"/seq_stats.R "${PANDA_OUT}"
##

## Filtering and renaming samples

# Loop through the samples and filter the fasta files
for NAME in $(cat "${BASE}"/sample_ids.pass_joined.txt)
do
    "${ref}"/seq_rename_and_filter.pl \
        "${PANDA_OUT}"/"${NAME}".joined.fa \
        "${NAME}" \
        7 7 400 \
        > "${FILTER_OUT}"/"${NAME}".filtered.fa
done

# Generate list of samples that passed the filtering step
if [ -f "${BASE}"/sample_ids.pass_filtered.txt ]; then
    rm "${BASE}"/sample_ids.pass_filtered.txt
fi

for file in $(ls -1 "${FILTER_OUT}"/*.filtered.fa)
do
    NAME=$(echo "${file}" | awk -F "/" '{print $NF}' | awk -F ".filtered" '{print $1}')
    echo "${NAME}"
    echo "${NAME}" >> "${BASE}"/sample_ids.pass_filtered.txt
done

SAMPLE_COUNT=$(wc "${BASE}"/sample_ids.pass_filtered.txt | awk '{print $1}')
echo -e "\nSample Count = ${SAMPLE_COUNT}"
##

## Start of QIIME2 stuff

# Merge the filtered fasta files into a single file for import
cat "${FILTER_OUT}"/*filtered.fa >> "${CONVERT_OUT}"/all.sequences.filtered.fa

# Import fasta file into QIIME2 as a qza file
qiime \
    tools import \
    --input-path "${CONVERT_OUT}"/all.sequences.filtered.fa \
    --output-path "${CONVERT_OUT}"/all.sequences.filtered.qza \
    --type 'SampleData[Sequences]'

# Dereplicate the qza file to generate the frequency table qza file
qiime \
    vsearch dereplicate-sequences \
    --i-sequences "${CONVERT_OUT}"/all.sequences.filtered.qza \
    --o-dereplicated-table "${CONVERT_OUT}"/rep-seqs.table.qza \
    --o-dereplicated-sequences "${CONVERT_OUT}"/rep-seqs.qza

# Clustering with open reference
qiime \
    vsearch cluster-features-open-reference \
    --i-table "${CONVERT_OUT}"/rep-seqs.table.qza \
    --i-sequences "${CONVERT_OUT}"/rep-seqs.qza \
    --i-reference-sequences ${MYREF} \
    --p-perc-identity 0.${CLUSTER_PER} \
    --o-clustered-table "${CLUSTER_OUT}"/table-or-${CLUSTER_PER}.qza \
    --o-clustered-sequences "${CLUSTER_OUT}"/rep-seqs-or-${CLUSTER_PER}.qza \
    --o-new-reference-sequences "${CLUSTER_OUT}"/new-ref-seqs-or-${CLUSTER_PER}.qza \
    --p-threads 0


# Clustering with closed reference
qiime \
    vsearch cluster-features-closed-reference \
    --i-table "${CONVERT_OUT}"/rep-seqs.table.qza \
    --i-sequences "${CONVERT_OUT}"/rep-seqs.qza \
    --i-reference-sequences ${MYREF} \
    --p-perc-identity 0.${CLUSTER_PER} \
    --o-clustered-table "${CLUSTER_OUT}"/table-cr-${CLUSTER_PER}.qza \
    --o-clustered-sequences "${CLUSTER_OUT}"/rep-seqs-cr-${CLUSTER_PER}.qza \
    --o-unmatched-sequences "${CLUSTER_OUT}"/unmatched-ref-seqs-cr-${CLUSTER_PER}.qza \
    --p-threads ${threads}

# Chimera Check
qiime \
    vsearch uchime-denovo \
    --i-table "${CLUSTER_OUT}"/table-or-${CLUSTER_PER}.qza \
    --i-sequences "${CLUSTER_OUT}"/rep-seqs-or-${CLUSTER_PER}.qza \
    --o-chimeras "${CHIMERA_OUT}"/chimeras.qza \
    --o-nonchimeras "${CHIMERA_OUT}"/nonchimeras.qza \
    --o-stats "${CHIMERA_OUT}"/chimera-check-stats.qza

# Use the non-chimeric sequences to exlude chimeras & 
# borderline sequences from the clustered table & sequence files
qiime \
    feature-table filter-features \
    --i-table "${CLUSTER_OUT}"/table-or-${CLUSTER_PER}.qza \
    --m-metadata-file "${CHIMERA_OUT}"/nonchimeras.qza \
    --o-filtered-table "${CHIMERA_OUT}"/table-nonchimeric-wo-borderline.qza

qiime \
    feature-table filter-seqs \
    --i-data "${CLUSTER_OUT}"/rep-seqs-or-${CLUSTER_PER}.qza \
    --m-metadata-file "${CHIMERA_OUT}"/nonchimeras.qza \
    --o-filtered-data "${CHIMERA_OUT}"/rep-seqs-nonchimeric-wo-borderline.qza

qiime \
    feature-table summarize \
    --i-table "${CHIMERA_OUT}"/table-nonchimeric-wo-borderline.qza \
    --o-visualization "${CHIMERA_OUT}"/table-nonchimeric-wo-borderline.qzv


# Examine chimera filtering statistics
qiime metadata tabulate \
  --m-input-file "${CHIMERA_OUT}"/chimera-check-stats.qza \
  --o-visualization "${CHIMERA_OUT}"/chimera-check-stats.qzv

# Classify OTUs with VSEARCH consensus classifier using reference file
qiime feature-classifier classify-consensus-vsearch \
    --i-query "${CHIMERA_OUT}"/nonchimeras.qza \
    --i-reference-reads ${MYREF} \
    --i-reference-taxonomy ${MYTAXONOMY} \
    --p-maxaccepts 10 \
    --p-perc-identity 0.8 \
    --p-strand "both" \
    --p-min-consensus 0.51 \
    --p-threads ${threads} \
    --o-classification "${CLASSIFY_OUT}"/rep-seqs-classified-by-Silva.qza \
    --output-dir "${CLASSIFY_OUT}"/rep-seqs-unspecified-by-Silva

## Import metadata for viewing with QIIME2
metadata_no_path=${METADATA##*/}
metadata_no_ext=${metadata_no_path%.*}
qiime metadata tabulate \
  --m-input-file ${METADATA} \
  --o-visualization ${metadata}/"${metadata_no_ext}".qzv

## Filter out control samples & low frequency OTUs
qiime feature-table filter-samples \
  --i-table "${CHIMERA_OUT}"/table-nonchimeric-wo-borderline.qza \
  --m-metadata-file ${METADATA} \
  --o-filtered-table "${FINAL_OTU}"/table-wo-controls-OTUs.qza
  
qiime feature-table summarize \
  --i-table "${FINAL_OTU}"/table-wo-controls-OTUs.qza \
  --o-visualization "${FINAL_OTU}"/table-wo-controls-OTUs.qzv
  
qiime feature-table filter-features \
  --i-table  "${FINAL_OTU}"/table-wo-controls-OTUs.qza \
  --p-min-frequency 1 \
  --o-filtered-table "${FINAL_OTU}"/table-final-OTUs.qza

qiime feature-table summarize \
  --i-table "${FINAL_OTU}"/table-final-OTUs.qza \
  --o-visualization "${FINAL_OTU}"/table-final-OTUs.qzv

## Create taxonomic barplots
qiime taxa barplot \
  --i-table "${FINAL_OTU}"/table-final-OTUs.qza \
  --i-taxonomy "${CLASSIFY_OUT}"/rep-seqs-classified-by-Silva.qza \
  --m-metadata-file ${METADATA} \
  --o-visualization "${FINAL_OTU}"/Silva-barplots.qzv


###################################################################################
# Capture program options
if [[ "${#programs_array[@]}" -gt 0 ]]; then
  echo "Logging program options..."
  for program in "${!programs_array[@]}"
  do
    {
    echo "Program options for ${program}: "
    echo ""
    # Handle samtools help menus
    if [[ "${program}" == "samtools_index" ]] \
    || [[ "${program}" == "samtools_sort" ]] \
    || [[ "${program}" == "samtools_view" ]]
    then
      ${programs_array[$program]}

    # Handle DIAMOND BLAST menu
    elif [[ "${program}" == "diamond" ]]; then
      ${programs_array[$program]} help

    # Handle NCBI BLASTx menu
    elif [[ "${program}" == "blastx" ]]; then
      ${programs_array[$program]} -help
    fi
    ${programs_array[$program]} -h
    echo ""
    echo ""
    echo "----------------------------------------------"
    echo ""
    echo ""
  } &>> program_options.log || true

    # If MultiQC is in programs_array, copy the config file to this directory.
    if [[ "${program}" == "multiqc" ]]; then
      cp --preserve ~/.multiqc_config.yaml multiqc_config.yaml
    fi
  done
  echo "Finished logging programs options."
  echo ""
fi


# Document programs in PATH (primarily for program version ID)
echo "Logging system \$PATH..."
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log
echo "Finished logging system $PATH."