---
layout: post
title: Trimming - O.lurida BGI FastQs with FastP on Mox
date: '2021-05-18 10:48'
tags: 
  - fastp
  - mox
  - Ostrea lurida
  - Olympia oyster
  - trimming
categories: 
  - Olympia Oyster Genome Sequencing
---
[After attempting to submit our _Ostrea lurida_ (Olympia oyster) genome assembly annotations (via GFF) to NCBI](https://robertslab.github.io/sams-notebook/2021/05/13/Genome-Submission-Validation-of-Olurida_v081.fa-and-Annotated-GFFs-Prior-to-Submission-to-NCBI.html), the submission process also highlighted some short comings of the `Olurida_v081` assembly. When getting ready to submit the genome annotations to NCBI, I was required to calculate the genome coverage we had. NCBI suggested to calculate this simply by counting the number of bases sequenced and divide it by the genome size. Doing this resulted in an estimated coverage of ~55X coverage, yet we have significant stretches of Ns throughout the assembly. I understand why this is still technically possible, but it's just sticking in my craw. So, I've decided to set up a quick assembly to see what I can come up with. Of note, the [canonical assembly we've been using relied on the scaffolded assembly provided by BGI](https://robertslab.github.io/sams-notebook/2017/11/30/genome-assembly-olympia-oyster-illumina-pacbio-using-pb-jelly-wbgi-scaffold-assembly-2.html); we never attempted our own assembly from the raw data.

To start, I needed to trim the data. I ran the BGI Illumina sequencing data through [`fastp`](https://github.com/OpenGene/fastp) on Mox.

SBATCH script (GitHub):

- [0210518_olur_fastp_bgi.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210518_olur_fastp_bgi.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210518_olur_fastp_bgi
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210518_olur_fastp_bgi


### Fastp 10x Genomics data used for P.generosa genome assembly by Phase Genomics.
### In preparation for use in BlobToolKit

### Expects input filenames to be in format: *.fastq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set number of CPUs to use
threads=40

# Input/output files
trimmed_checksums=trimmed_fastq_checksums.md5
raw_reads_dir=/gscratch/srlab/sam/data/O_lurida/DNAseq
fastq_checksums=raw_fastq_checksums.md5

# Paths to programs
fastp=/gscratch/srlab/programs/fastp-0.20.0/fastp
multiqc=/gscratch/srlab/programs/anaconda3/bin/multiqc

## Inititalize arrays
fastq_array_R1=()
fastq_array_R2=()


# Programs associative array
declare -A programs_array
programs_array=(
[fastp]="${fastp}" \
[multiqc]="${multiqc}"
)


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability
module load intel-python3_2017

# Capture date
timestamp=$(date +%Y%m%d)

# Sync raw FastQ files to working directory
rsync --archive --verbose \
"${raw_reads_dir}"/1*.fq.gz .

# Create arrays of fastq R1 files and sample names
for fastq in 1*_1*.fq.gz
do
  fastq_array_R1+=("${fastq}")
done

# Create array of fastq R2 files
for fastq in 1*_2*.fq.gz
do
  fastq_array_R2+=("${fastq}")
done


# Run fastp on files
# Trim 10bp from 5' from each read
# Adds JSON report output for downstream usage by MultiQC
for index in "${!fastq_array_R1[@]}"
do
  # Remove .fastq.gz from end of file names
  R1_sample_name=$(echo "${fastq_array_R1[index]}" | sed 's/.fq.gz//')
  R2_sample_name=$(echo "${fastq_array_R2[index]}" | sed 's/.fq.gz//')

  # Get sample name without R1/R2 labels
  sample_name=$(echo "${fastq_array_R1[index]}" | sed 's/_[12].*//')

  echo ""
  echo "fastp started on ${sample_name} FastQs."

  # Run fastp
  # Specifies reports in HTML and JSON formats
  ${fastp} \
  --in1 ${fastq_array_R1[index]} \
  --in2 ${fastq_array_R2[index]} \
  --detect_adapter_for_pe \
  --thread ${threads} \
  --html "${sample_name}".fastp-trim."${timestamp}".report.html \
  --json "${sample_name}".fastp-trim."${timestamp}".report.json \
  --out1 "${R1_sample_name}".fastp-trim."${timestamp}".fq.gz \
  --out2 "${R2_sample_name}".fastp-trim."${timestamp}".fq.gz

  echo "fastp completed on ${sample_name} FastQs"
  echo ""

  # Generate md5 checksums for newly trimmed files
  {
  md5sum "${R1_sample_name}".fastp-trim."${timestamp}".fq.gz
  md5sum "${R2_sample_name}".fastp-trim."${timestamp}".fq.gz
  } >> "${trimmed_checksums}"


  # Create MD5 checksum for reference
  {
    md5sum "${fastq_array_R1[index]}"
    md5sum "${fastq_array_R2[index]}"
  }  >> ${fastq_checksums}

  # Remove original FastQ files
  rm "${fastq_array_R1[index]}" "${fastq_array_R2[index]}"
done

# Run MultiQC
${programs_array[multiqc]} .

###################################################################################

# Capture program options
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

# Document programs in PATH (primarily for program version ID)
{
  date
  echo ""
  echo "System PATH for $SLURM_JOB_ID"
  echo ""
  printf "%0.s-" {1..10}
  echo "${PATH}" | tr : \\n
} >> system_path.log

echo "Finished logging system PATH"
```


---

#### RESULTS

No runtime for this, as UW email system was down.

Next up, use the hybrid assembler [wengan](https://github.com/adigenova/wengan) to generate a new assembly!

Output folder:

- [20210518_olur_fastp_bgi/](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/)

#### HTML Reports

- [`MultiQC`](https://multiqc.info/) Report:

  - [multiqc_report.html](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/multiqc_report.html)

- [`fastp`](https://github.com/OpenGene/fastp) Reports:

  - [151114_I191_FCH3Y35BCXX_L1_wHAIPI023992-37.fastp-trim.20210518.report.html](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/151114_I191_FCH3Y35BCXX_L1_wHAIPI023992-37.fastp-trim.20210518.report.html)

  - [151114_I191_FCH3Y35BCXX_L2_wHAMPI023991-66.fastp-trim.20210518.report.html](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/151114_I191_FCH3Y35BCXX_L2_wHAMPI023991-66.fastp-trim.20210518.report.html)

  - [151118_I137_FCH3KNJBBXX_L5_wHAXPI023905-96.fastp-trim.20210518.report.html](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/151118_I137_FCH3KNJBBXX_L5_wHAXPI023905-96.fastp-trim.20210518.report.html)

  - [160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCABDLAAPEI-62.fastp-trim.20210518.report.html](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCABDLAAPEI-62.fastp-trim.20210518.report.html)

  - [160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCACDTAAPEI-75.fastp-trim.20210518.report.html](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCACDTAAPEI-75.fastp-trim.20210518.report.html)

  - [160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCABDLAAPEI-62.fastp-trim.20210518.report.html](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCABDLAAPEI-62.fastp-trim.20210518.report.html)

  - [160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCACDTAAPEI-75.fastp-trim.20210518.report.html](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCACDTAAPEI-75.fastp-trim.20210518.report.html)

  - [160103_I137_FCH3V5YBBXX_L5_WHOSTibkDCAADWAAPEI-74.fastp-trim.20210518.report.html](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L5_WHOSTibkDCAADWAAPEI-74.fastp-trim.20210518.report.html)

  - [160103_I137_FCH3V5YBBXX_L6_WHOSTibkDCAADWAAPEI-74.fastp-trim.20210518.report.html](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L6_WHOSTibkDCAADWAAPEI-74.fastp-trim.20210518.report.html)

#### Trimmed FastQs

- [151114_I191_FCH3Y35BCXX_L1_wHAIPI023992-37_1.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/151114_I191_FCH3Y35BCXX_L1_wHAIPI023992-37_1.fastp-trim.20210518.fq.gz) (6.9G)

  - MD5: `b59cfc6267f1ab18d46363de4c8478ca`

- [151114_I191_FCH3Y35BCXX_L1_wHAIPI023992-37_2.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/151114_I191_FCH3Y35BCXX_L1_wHAIPI023992-37_2.fastp-trim.20210518.fq.gz) (7.2G)

  - MD5: `5622f0ba614b2fd243b9fb3361c632ff`

- [151114_I191_FCH3Y35BCXX_L2_wHAMPI023991-66_1.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/151114_I191_FCH3Y35BCXX_L2_wHAMPI023991-66_1.fastp-trim.20210518.fq.gz) (6.8G)

  - MD5: `b5ca846f985d4371320fb880cdb2aefe`

- [151114_I191_FCH3Y35BCXX_L2_wHAMPI023991-66_2.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/151114_I191_FCH3Y35BCXX_L2_wHAMPI023991-66_2.fastp-trim.20210518.fq.gz) (7.1G)

  - MD5: `21bd1320eaa436849b3ba8d2bde1a91f`

- [151118_I137_FCH3KNJBBXX_L5_wHAXPI023905-96_1.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/151118_I137_FCH3KNJBBXX_L5_wHAXPI023905-96_1.fastp-trim.20210518.fq.gz) (4.0G)

  - MD5: `3e7e27d331c6cb7a131f07e0190a9906`

- [151118_I137_FCH3KNJBBXX_L5_wHAXPI023905-96_2.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/151118_I137_FCH3KNJBBXX_L5_wHAXPI023905-96_2.fastp-trim.20210518.fq.gz) (4.2G)

  - MD5: `7a0b51fb7cc94948fe65f0e9779fde9f`

- [160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCABDLAAPEI-62_1.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCABDLAAPEI-62_1.fastp-trim.20210518.fq.gz) (2.7G)

  - MD5: `9041d909cc4650677273fe313d923e9f`

- [160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCABDLAAPEI-62_2.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCABDLAAPEI-62_2.fastp-trim.20210518.fq.gz) (3.0G)

  - MD5: `c44165a404f9d2eab99d352d34918ebb`

- [160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCACDTAAPEI-75_1.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCACDTAAPEI-75_1.fastp-trim.20210518.fq.gz) (1.4G)

  - MD5: `6e2070b91d3872817ffe1600f8098cc7`

- [160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCACDTAAPEI-75_2.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L3_WHOSTibkDCACDTAAPEI-75_2.fastp-trim.20210518.fq.gz) (1.6G)

  - MD5: `8acc523663ceebb40c793c21a29554f9`

- [160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCABDLAAPEI-62_1.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCABDLAAPEI-62_1.fastp-trim.20210518.fq.gz) (2.7G)

  - MD5: `65c924c07b3a67fcf73cf2dfbfb5385c`

- [160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCABDLAAPEI-62_2.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCABDLAAPEI-62_2.fastp-trim.20210518.fq.gz) (3.0G)

  - MD5: `83a8d688bb2ed8b1f2b20a409894f291`

- [160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCACDTAAPEI-75_1.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCACDTAAPEI-75_1.fastp-trim.20210518.fq.gz) (1.4G)

  - MD5: `aa21c7a4661f9a609d48f0c1838a4227`

- [160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCACDTAAPEI-75_2.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L4_WHOSTibkDCACDTAAPEI-75_2.fastp-trim.20210518.fq.gz) (1.6G)

  - MD5: `7378a4889fe9387731a4763fef89dcbd`

- [160103_I137_FCH3V5YBBXX_L5_WHOSTibkDCAADWAAPEI-74_1.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L5_WHOSTibkDCAADWAAPEI-74_1.fastp-trim.20210518.fq.gz) (3.0G)

  - MD5: `cac2ae3705c0ee9050803eb33b7c2c2f`

- [160103_I137_FCH3V5YBBXX_L5_WHOSTibkDCAADWAAPEI-74_2.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L5_WHOSTibkDCAADWAAPEI-74_2.fastp-trim.20210518.fq.gz) (3.3G)

  - MD5: `4604149dad5455d2700a5026ea53e275`

- [160103_I137_FCH3V5YBBXX_L6_WHOSTibkDCAADWAAPEI-74_1.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L6_WHOSTibkDCAADWAAPEI-74_1.fastp-trim.20210518.fq.gz) (2.8G)

  - MD5: `544761c0318393021b1f45eb00bfcf3b`

- [160103_I137_FCH3V5YBBXX_L6_WHOSTibkDCAADWAAPEI-74_2.fastp-trim.20210518.fq.gz](https://gannet.fish.washington.edu/Atumefaciens/20210518_olur_fastp_bgi/160103_I137_FCH3V5YBBXX_L6_WHOSTibkDCAADWAAPEI-74_2.fastp-trim.20210518.fq.gz) (3.2G)

  - MD5: `349d7a9d5e250ddbd89f159485b5c904`
